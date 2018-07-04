//
//  TTStubReachability.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTStubReachability.h"

@implementation TTStubReachability

- (BOOL)startMonitoring
{
    self.didCallStartMonitoring = YES;
    return YES;
}

- (void)stopMonitoring
{
    self.didCallStopMonitoring = YES;
}

- (BOOL)isReachable
{
    return self.mockIsReachable;
}

@end
