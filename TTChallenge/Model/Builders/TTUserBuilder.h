//
//  TTUserBuilder.h
//  TTChallenge
//
//  Created by keksiy on 07.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;
@class TTCoreDataManager;

typedef void(^TTUserBuilderAddCompletion)(NSError *error);

@interface TTUserBuilder : NSObject

// designated initialiser for dependency injection
- (instancetype)initWithCoreDataManager:(TTCoreDataManager *)coreDataManager;

// parses User Data, reports error if any.
- (void)addUserDataFromDictionary:(NSDictionary *)dictionary
                       completion:(TTUserBuilderAddCompletion)completion;

// parses Favorite Tracks Data, reports error if any.
- (void)addFavoriteTracksDataFromArray:(NSArray *)array
                            completion:(TTUserBuilderAddCompletion)completion;
;

// If there is no data for update: returns cached user if any.
// If has data for update, and there is no user in cache - creates new one in cache.  otherwise - updates cache with the receive data
- (TTUser *)buildWithError:(NSError **)error;
- (TTUser *)builFromCache;

@end
