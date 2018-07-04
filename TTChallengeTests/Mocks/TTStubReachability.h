//
//  TTStubReachability.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTReachability.h"

@interface TTStubReachability : TTReachability
@property (nonatomic, assign) BOOL didCallStartMonitoring;
@property (nonatomic, assign) BOOL didCallStopMonitoring;
@property (nonatomic, assign) BOOL mockIsReachable;
@end
