//
//  TTStubHTTPClient.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTHTTPClient.h"

@interface TTStubHTTPClient : TTHTTPClient
@property (nonatomic, strong) NSDictionary *fetchUserResponse;
@property (nonatomic, strong) NSArray *fetchTracksResponse;
@property (nonatomic, strong) NSError *fetchUserError;
@property (nonatomic, strong) NSError *fetchTracksError;
@property (nonatomic, assign) BOOL didCallNetwork;
@end
