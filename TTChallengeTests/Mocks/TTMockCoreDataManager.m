//
//  TTMockCoreDataManager.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTMockCoreDataManager.h"
#import "TTUser.h"
#import "TTParsedUser.h"

@implementation TTMockCoreDataManager

- (TTUser *)cachedUser
{
    return self.user;
}

- (NSError *)processCachedUser:(TTUser *)user withParsedInfo:(TTParsedUser *)parsedUser
{
    self.user.scID = parsedUser.scID;
    self.user.username = parsedUser.username;
    return self.error;
}

- (NSError *)processTracksWithParsedInfo:(NSArray *)parsedTracks
                               parsedIds:(NSArray *)parsedTrackIDs
{
    self.tracks = [parsedTracks copy];
    return self.error;
}

@end
