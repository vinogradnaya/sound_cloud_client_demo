//
//  TTDataManager.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTSoundCloudManager.h"
#import "TTFetchObserver.h"
#import "TTHTTPClient.h"
#import "TTImageCache.h"
#import "TTReachability.h"
#import "TTUserBuilder.h"
#import "TTDefines.h"
#import "TTConstants.h"
#import "TTSoundCloudManager+TTTests.h"

typedef void(^TTLoadDataCompletion)(NSError *error);

typedef NS_ENUM(NSInteger, TTDataManagerState)
{
    TTDataManagerStateIdle,
    TTDataManagerStateLoadingData,
    TTDataManagerStateCanceled
};

//API Endpoints
static NSString *const kTTGetUserDataURL = @"users/178689868";
static NSString *const kTTGetUserFavoriteTracksURL = @"users/178689868/favorites";
static NSString *const kTTBaseURL = @"api.soundcloud.com";

//Helpers
static const NSInteger kTTSuggestedNumberOfObservers = 2;
static const NSTimeInterval kTTTwoMinutesInterval = 120;

@interface TTSoundCloudManager ()
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@property (nonatomic, strong) NSMutableArray *observers;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) TTHTTPClient *client;
@property (nonatomic, strong) TTUserBuilder *builder;
@property (nonatomic, strong) TTReachability *reachability;
@property (atomic, assign) TTDataManagerState state;
@end

@implementation TTSoundCloudManager
#pragma mark - Initialization

+ (instancetype)sharedManager
{
    static TTSoundCloudManager *sDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      sDataManager = [TTSoundCloudManager new];
                  });

    return sDataManager;
}

- (instancetype)initWithAPIClient:(TTHTTPClient *)client
                     reachability:(TTReachability *)reachability
                          builder:(TTUserBuilder *)builder
{
    self = [super init];
    if (self) {
        self.concurrentQueue = dispatch_queue_create("com.tt.challenge.scmanager.concurrentDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
        self.state = TTDataManagerStateIdle;
        self.observers = [[NSMutableArray alloc] initWithCapacity:kTTSuggestedNumberOfObservers];

        // dependency injection
        self.builder = (builder != nil)? builder : [TTUserBuilder new];
        self.client = (client != nil)? client : [[TTHTTPClient alloc] initWithBaseURL:kTTBaseURL session:nil];
        self.reachability = (reachability != nil)? reachability : [TTReachability sharedObject];

        // observe reachability notification
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:TTReachabilityChangedNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *note) {
                            [self networkStatusDidChange:note];
                        }];

    }
    return self;
}

- (instancetype)init
{
    return [self initWithAPIClient:nil reachability:nil builder:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Add Observers

- (void)addObserver:(id<TTFetchObserver>)observer
{
    TTAssert([observer conformsToProtocol:@protocol(TTFetchObserver)], @"Observer must conform to TTFetchObserver protocol");
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self.observers addObject:observer];
    });
}

#pragma mark - Notify Observers

- (void)notifyDidFetchUser:(TTUser *)user error:(NSError *)error
{
    [self.observers enumerateObjectsUsingBlock:^(id <TTFetchObserver> observer, NSUInteger index, BOOL *stop) {
        [observer didFetchUser:user error:error];
    }];
}

#pragma mark - Fetching Data

- (void)fetchDataIfNeeded
{
    //if we already have cached data, don't call API, but set the timer
    TTUser *user = [self.builder builFromCache];
    if (user != nil) {
        [self finishFetchWithData:user error:nil];
    } else {
        [self fetchData];
    }
}

- (void)fetchData
{
    BOOL canFetchData = [self evaluateFetchingConditions];

    if (!canFetchData) {
        return;
    }

    self.state = TTDataManagerStateLoadingData;

    __block NSError *userDataLoadError = nil;
    __block NSError *userFavoriteTracksLoadError = nil;

    dispatch_group_t downloadGroup = dispatch_group_create();

    dispatch_group_enter(downloadGroup);
    [self fetchUserDataWithCompletion:^(NSError *error) {
        userDataLoadError = error;
        dispatch_group_leave(downloadGroup);
    }];

    dispatch_group_enter(downloadGroup);
    [self fetchUserFavoriteTracksWithCompletion:^(NSError *error) {
        userFavoriteTracksLoadError = error;
        dispatch_group_leave(downloadGroup);
    }];

    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        NSError *overallError = nil;
        if (userDataLoadError || userFavoriteTracksLoadError) {
            overallError = [[NSError alloc] initWithDomain:TTSoundCloudManagerErrorDomain
                                                      code:TTErrorCodeFetchError
                                                  userInfo:@{@"errorMessage" : @"Error occured loading data"}];
        }

        TTUser *user = nil;
        if (!overallError) {
            user = [self.builder buildWithError:&overallError];
        }

        [self finishFetchWithData:user error:overallError];

        // used for testing
        if (self.fetchCompletion) {
            self.fetchCompletion(user, overallError);
        }
    });
}

- (void)fetchUserDataWithCompletion:(TTLoadDataCompletion)completion
{
    TTUserBuilder *builder = self.builder;
    [self.client getDataWithURL:kTTGetUserDataURL
                     parameters:self.parameters
                     completion:^(id responseObject, NSError *error) {
                         if (error == nil) {
                             [builder addUserDataFromDictionary:responseObject
                                                     completion:completion];
                         } else {
                             if (completion) {
                                 completion (error);
                             }
                         }
                     }];
}

- (void)fetchUserFavoriteTracksWithCompletion:(TTLoadDataCompletion)completion
{
    TTUserBuilder *builder = self.builder;
    [self.client getDataWithURL:kTTGetUserFavoriteTracksURL
                     parameters:self.parameters
                     completion:^(id responseObject, NSError *error) {
                         if (error == nil) {
                             [builder addFavoriteTracksDataFromArray:responseObject
                                                          completion:completion];
                         } else {
                             if (completion) {
                                 completion (error);
                             }
                         }
                     }];
}

- (void)finishFetchWithData:(TTUser *)user error:(NSError *)error
{
    self.state = TTDataManagerStateIdle;
    [self notifyDidFetchUser:user error:error];
    [self scheduleFetchWithInterval:kTTTwoMinutesInterval];
}

- (void)scheduleFetchWithInterval:(NSTimeInterval)interval
{
    //force the timer to be scheduled on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fetchData)
                                       userInfo:nil
                                        repeats:NO];
    });
}

#pragma mark - Evaluate Fetch Conditions

- (BOOL)evaluateFetchingConditions
{
    BOOL allowed = YES;

    if (![self evaluateStatus]) {
        allowed = NO;
    } else if (![self evaluateNetwork]) {
        allowed = NO;
        NSError *error = [NSError errorWithDomain:TTSoundCloudManagerErrorDomain
                                             code:TTErrorCodeNetworkError
                                         userInfo:nil];
        [self cancelFetchWithError:error];
    }

    return allowed;
}

- (BOOL)evaluateStatus
{
    BOOL isNotLoadingData = (self.state != TTDataManagerStateLoadingData);
    return isNotLoadingData;
}

- (BOOL)evaluateNetwork
{
    BOOL isReachable = [self.reachability isReachable];
    return isReachable;
}

- (void)cancelFetchWithError:(NSError *)error
{
    self.state = TTDataManagerStateCanceled;
    [self.reachability startMonitoring];
    [self notifyDidFetchUser:nil error:error];
}

#pragma mark - Reachability Notification

- (void)networkStatusDidChange:(NSNotification *)notification
{
    TTNetworkStatus status = [notification.object integerValue];
    if (status != TTNetworkStatusNotReachable) {
        [self.reachability stopMonitoring];
        if (self.state == TTDataManagerStateCanceled) {
            [self fetchData];
        }
    }
}

#pragma mark - Image Download

- (NSURLSessionDownloadTask *)getImageWithURL:(NSString *)urlString
                                   completion:(TTImageDownloadCompletion)completion
{
    TTImageCache *imageCache = [TTImageCache sharedObject];
    NSURLSessionDownloadTask *task = [self.client dowloadDataWithURL:urlString completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        UIImage *downloadedImage = nil;
        if (!error) {
            downloadedImage = [UIImage imageWithData: downloadedData];
            [imageCache registerImage:downloadedImage forURL:urlString];
        }

        if (completion) {
            completion (downloadedImage, [response.URL absoluteString], error);
        }
    }];

    return task;
}

#pragma mark - Properties

- (NSMutableDictionary *)parameters
{
    if (_parameters != nil) {
        return _parameters;
    }

    NSDictionary *defaultParams = @{@"client_id" : TTSoundCloudClientID};
    _parameters = [[NSMutableDictionary alloc] initWithDictionary:defaultParams];
    return _parameters;
}

@end
