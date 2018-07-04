//
//  TTStubHTTPClient.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTStubHTTPClient.h"
#import "TTSoundCloudManager.h"

@implementation TTStubHTTPClient

- (void)getDataWithURL:(NSString *)urlString
            parameters:(NSDictionary *)parameters
            completion:(TTHTTPClientGetCompletion)completion
{
    self.didCallNetwork = YES;
    
    if ([urlString isEqualToString:@"users/178689868"]) {
        if (completion) {
            completion (self.fetchUserResponse, self.fetchUserError);
        }
    } else if ([urlString isEqualToString:@"users/178689868/favorites"]) {
        if (completion) {
            completion (self.fetchTracksResponse, self.fetchTracksError);
        }
    }
}

@end
