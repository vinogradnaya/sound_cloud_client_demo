//
//  TTCoreDataManager.m
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTCoreDataManager.h"
#import "TTDefines.h"
#import "TTUser.h"
#import "TTTrack.h"
#import "TTParsedUser.h"
#import "TTParsedTrack.h"
#import "TTConstants.h"

NSString * const TTUserEntityName = @"TTUser";
NSString * const TTTrackEntityName = @"TTTrack";
NSString * const TTCustomManagedObjectIDKey = @"scID";

@interface TTCoreDataManager ()
@end

@implementation TTCoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initialization

+ (instancetype)sharedManager
{
    static TTCoreDataManager *sCoreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      sCoreDataManager = [TTCoreDataManager new];
                  });

    return sCoreDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self managedObjectContext];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:UIApplicationWillTerminateNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification * __unused notification) {
                            [self saveContext];
                        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data Stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "vinogradnaya.TTChallenge" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TTChallenge" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TTChallenge.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    @try {
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    @catch (NSException *exception) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:TTCoreDataManagerErrorDomain code:TTErrorCodeSavingError userInfo:dict];
        TTLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (NSError *)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __block NSError *error = nil;
    if (managedObjectContext != nil) {
        [managedObjectContext performBlockAndWait:^{
            if ([managedObjectContext hasChanges]) {
                @try {
                    [managedObjectContext save:&error];
                }
                @catch (NSException * e) {
                    TTLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
        }];
    }
    return error;
}

#pragma mark - Core Data User

- (TTUser *)cachedUser
{
    TTUser *user = nil;
    NSArray *results = [self managedObjectsForClass:TTUserEntityName
                                        sortedByKey:nil
                                    usingArrayOfIds:nil
                                       inArrayOfIds:YES
                              includePropertyValues:YES];
    if ([results count] > 0) {
        user = [results firstObject];
    }

    return user;
}

- (TTUser *)processUserWithParsedInfo:(TTParsedUser *)parsedUser
                                error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *context = self.managedObjectContext;
    __block TTUser *user = [self cachedUser];

    __weak typeof(self) weakSelf = self;
    [context performBlockAndWait:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (user == nil) {
            user = [strongSelf insertNewUserWithParsedInfo:parsedUser];
        } else {
            [strongSelf updateCachedUser:user withParsedInfo:parsedUser];
        }
    }];

    NSError *saveError = [self saveContext];
    *error = saveError;

    return user;
}

- (TTUser *)insertNewUserWithParsedInfo:(TTParsedUser *)parsedUser
{
    NSManagedObjectContext *context = self.managedObjectContext;

    NSEntityDescription *entityDescription =
    [NSEntityDescription entityForName:TTUserEntityName
                inManagedObjectContext:context];
    TTUser *user = [[TTUser alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];

    [self updateCachedUser:user withParsedInfo:parsedUser];

    return user;
}

- (void)updateCachedUser:(TTUser *)user withParsedInfo:(TTParsedUser *)parsedUser
{
    user.scID                   = parsedUser.scID;
    user.username               = parsedUser.username;
    user.name                   = parsedUser.name;
    user.caption                = parsedUser.caption;
    user.country                = parsedUser.country;
    user.city                   = parsedUser.city;
    user.avatarURL              = parsedUser.avatarURL;
    user.favoriteTracksCount    = parsedUser.favoriteTracksCount;
    user.followingsCount        = parsedUser.followingsCount;
    user.followersCount         = parsedUser.followersCount;
}

#pragma mark - Core Data Tracks

- (NSArray *)cachedTracks
{
    NSArray *tracks = [self managedObjectsForClass:TTTrackEntityName
                                       sortedByKey:TTCustomManagedObjectIDKey
                                   usingArrayOfIds:nil
                                      inArrayOfIds:NO
                             includePropertyValues:YES];

    return tracks;
}

- (NSError *)processTracksWithParsedInfo:(NSArray *)parsedTracks
                               parsedIds:(NSArray *)parsedTrackIDs
{
    if (parsedTracks == nil) {
        NSError *invalidDataError = [NSError errorWithDomain:TTCoreDataManagerErrorDomain
                                                        code:TTErrorCodeParsingError
                                                    userInfo:nil];
        return invalidDataError;
    }

    NSError *saveError = nil;
    saveError = [self deleteCachedTracksThatAreNotInParsedTracks:parsedTrackIDs];

    if (!saveError) {
        saveError = [self processCachedTracksWithParsedInfo:parsedTracks];
    }

    return saveError;
}

- (NSError *)deleteCachedTracksThatAreNotInParsedTracks:(NSArray *)parsedTracks
{
    NSArray *tracksToDelete = [self managedObjectsForClass:TTTrackEntityName
                                               sortedByKey:nil
                                           usingArrayOfIds:parsedTracks
                                              inArrayOfIds:NO
                                     includePropertyValues:NO];

    NSError *error = [self deleteObjects:tracksToDelete];
    return error;
}

- (NSError *)processCachedTracksWithParsedInfo:(NSArray *)parsedTracks
{
    NSArray *cachedTracks = [self managedObjectsForClass:TTTrackEntityName
                                             sortedByKey:TTCustomManagedObjectIDKey
                                         usingArrayOfIds:nil
                                            inArrayOfIds:YES
                                   includePropertyValues:YES];

    NSManagedObjectContext *context = self.managedObjectContext;

    __weak typeof(self) weakSelf = self;

    [context performBlockAndWait:^{
        __strong typeof(self) strongSelf = weakSelf;
        __block NSInteger cachedTrackIndex = 0;
        [parsedTracks enumerateObjectsUsingBlock:^(TTParsedTrack *parsedTrack, NSUInteger index, BOOL *stop) {
            TTTrack *track = nil;
            //check if we reached the end of the cached tracks
            if (cachedTrackIndex < [cachedTracks count]) {
                // get the cached track
                track = cachedTracks[cachedTrackIndex];
                // if cached track id is equal to the parsed track, update it and move to the next one
                if ([track.scID integerValue] == [parsedTrack.scID integerValue]) {
                    [strongSelf updateCachedTrack:track withParsedInfo:parsedTrack];
                    cachedTrackIndex ++;
                } else {
                    // otherwise insert a new track into Core Data
                    [strongSelf insertNewTrackWithParsedInfo:parsedTrack];
                }
            } else {
                // if we have reached the end of the cached tracks - just insert all the new tracks into Core Data
                [strongSelf insertNewTrackWithParsedInfo:parsedTrack];
            }
        }];
    }];

    NSError *saveError = [self saveContext];
    return saveError;
}

- (void)insertNewTrackWithParsedInfo:(TTParsedTrack *)parsedTrack
{
    NSManagedObjectContext *context = self.managedObjectContext;

    NSEntityDescription *entityDescription =
    [NSEntityDescription entityForName:TTTrackEntityName
                inManagedObjectContext:context];

    TTTrack *track = [[TTTrack alloc] initWithEntity:entityDescription
                      insertIntoManagedObjectContext:context];
    track.timestamp     = [NSDate date];

    [self updateCachedTrack:track withParsedInfo:parsedTrack];
}

- (void)updateCachedTrack:(TTTrack *)track withParsedInfo:(TTParsedTrack *)parsedTrack
{
    track.scID          = parsedTrack.scID;
    track.title         = parsedTrack.title;
    track.releaseYear   = parsedTrack.releaseYear;
    track.artist        = parsedTrack.artist;
    track.artworkURL    = parsedTrack.artworkURL;
    track.streamURL     = parsedTrack.streamURL;
    track.duration      = parsedTrack.duration;
}

#pragma mark - Delete Objects

- (NSError *)deleteObjects:(NSArray *)objects
{
    NSManagedObjectContext *context = self.managedObjectContext;

    [context performBlockAndWait:^{
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
    }];

    NSError *error = [self saveContext];

    return error;
}

#pragma mark - Fetch Objects

- (NSArray *)managedObjectsForClass:(NSString *)className
                        sortedByKey:(NSString *)key
                    usingArrayOfIds:(NSArray *)idArray
                       inArrayOfIds:(BOOL)inIds
              includePropertyValues:(BOOL)includePropertyValues
{
    __block NSArray *results = nil;
    NSManagedObjectContext *context = self.managedObjectContext;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];

    if ([idArray count] > 0) {
        NSPredicate *predicate;
        if (inIds) {
            predicate = [NSPredicate predicateWithFormat:@"scID IN %@", idArray];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"NOT (scID IN %@)", idArray];
        }
        [fetchRequest setPredicate:predicate];
    }

    [fetchRequest setIncludesPropertyValues:includePropertyValues];

    if (key != nil) {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:key
                                                                         ascending:YES]]];
    }

    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [context executeFetchRequest:fetchRequest error:&error];
        if (error) {
            TTLog(@"Error fetching %@ from Core Data = %@", className, error.localizedDescription);
        }
    }];
    
    return results;
}

@end