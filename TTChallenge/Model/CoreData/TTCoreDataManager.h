//
//  TTCoreDataManager.h
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TTUser;
@class TTParsedUser;

extern NSString * const TTUserEntityName;
extern NSString * const TTTrackEntityName;
extern NSString * const TTCustomManagedObjectIDKey;

@interface TTCoreDataManager : NSObject
@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedManager;

// return data from cache
- (TTUser *)cachedUser;
- (NSArray *)cachedTracks;

// update data in cache with new data
- (TTUser *)processUserWithParsedInfo:(TTParsedUser *)parsedUser
                                error:(NSError **)error;
- (NSError *)processTracksWithParsedInfo:(NSArray *)parsedTracks
                               parsedIds:(NSArray *)parsedTrackIDs;
@end
