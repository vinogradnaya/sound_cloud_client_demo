//
//  TTUserBuilder.m
//  TTChallenge
//
//  Created by keksiy on 07.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTUserBuilder.h"
#import "TTCoreDataManager.h"
#import "TTUser.h"
#import "TTParsedUser.h"
#import "TTParsedTrack.h"
#import "TTDefines.h"
#import "TTConstants.h"

@interface TTUserBuilder ()
@property (nonatomic, strong) TTParsedUser *parsedUser;
@property (nonatomic, copy) NSArray *parsedTracks;
@property (nonatomic, copy) NSArray *parsedTrackIDs;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@property (nonatomic, strong) TTCoreDataManager *coreDataManager;
@end

@implementation TTUserBuilder

#pragma mark - Initialization

- (instancetype)initWithCoreDataManager:(TTCoreDataManager *)coreDataManager
{
    self = [super init];
    if (self) {
        self.concurrentQueue = dispatch_queue_create("com.tt.challenge.userbuilder.concurrentDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
        self.coreDataManager = coreDataManager != nil? coreDataManager : [TTCoreDataManager sharedManager];
    }

    return self;
}

- (instancetype)init
{
    return [self initWithCoreDataManager:[TTCoreDataManager sharedManager]];
}

#pragma mark - Creal Data

- (void)clearBuilderData
{
    self.parsedUser = nil;
    self.parsedTracks = nil;
    self.parsedTrackIDs = nil;
}

#pragma mark - Parse Data
#pragma mark - Parse User Data

- (void)addUserDataFromDictionary:(NSDictionary *)dictionary
                       completion:(TTUserBuilderAddCompletion)completion
{
    NSError *error = nil;

    if (dictionary == nil) {
        error = [NSError errorWithDomain: TTUserBuilderErrorDomain
                                     code:TTErrorCodeParsingError
                                 userInfo: nil];
        if (completion) {
            completion (error);
        }
        return;
    }

    TTParsedUser *user = [TTParsedUser instanceFromDictionary:dictionary
                                                        error:&error];
    TTLog(@"parsed user: \n%@", user);

    dispatch_barrier_async(self.concurrentQueue, ^{
        self.parsedUser = user;
        dispatch_async(self.concurrentQueue, ^{
            if (completion) {
                completion (error);
            }
        });
    });
}

#pragma mark - Parse Tracks Data

- (void)addFavoriteTracksDataFromArray:(NSArray *)array
                            completion:(TTUserBuilderAddCompletion)completion
{
    NSError *error = nil;

    if (array == nil) {
        error = [NSError errorWithDomain: TTUserBuilderErrorDomain
                                    code:TTErrorCodeParsingError
                                userInfo: nil];
        if (completion) {
            completion (error);
        }
        return;
    }

    NSMutableArray *parsedTracks = [NSMutableArray new];
    NSMutableArray *parsedTrackIDs = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(NSDictionary *trackDictionary, NSUInteger index, BOOL *stop) {
        TTParsedTrack *track = [TTParsedTrack instanceFromDictionary:trackDictionary];
        if (track != nil) {
            [parsedTracks addObject:track];
            [parsedTrackIDs addObject:track.scID];
        }
    }];

    TTLog(@"parsed tracks count: %lu", (unsigned long)[parsedTracks count]);

    dispatch_barrier_sync(self.concurrentQueue, ^{
        self.parsedTracks = [parsedTracks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:TTCustomManagedObjectIDKey ascending:YES]]];
        self.parsedTrackIDs = parsedTrackIDs;
        dispatch_async(self.concurrentQueue, ^{
            if (completion) {
                completion (error);
            }
        });
    });
}

#pragma mark - Build User

- (TTUser *)builFromCache
{
    TTUser *user = [self.coreDataManager cachedUser];
    return user;
}

- (TTUser *)buildWithError:(NSError **)error
{
    TTUser *user = nil;
    NSError *userProcessingError = nil;
    NSError *tracksProcessingError = nil;

    if (self.parsedUser != nil) {
        // if we have new user data - update cache
        user = [self.coreDataManager processUserWithParsedInfo:self.parsedUser
                                                         error:&userProcessingError];
    } else {
        // if no new user data - build from cache
        user = [self builFromCache];
    }

    if (self.parsedTracks != nil) {
        // if we have new tracks data - update cache
        tracksProcessingError = [self.coreDataManager processTracksWithParsedInfo:self.parsedTracks
                                                                        parsedIds:self.parsedTrackIDs];
    }

    if (userProcessingError || tracksProcessingError) {
        *error = [NSError errorWithDomain:TTUserBuilderErrorDomain
                                     code:TTErrorCodeSavingError
                                 userInfo:nil];
        TTLog(@"Error saving to Core Data = %@", userProcessingError.localizedDescription);
        TTLog(@"Error saving to Core Data = %@", tracksProcessingError.localizedDescription);
    }

    [self clearBuilderData];

    return user;
}

@end
