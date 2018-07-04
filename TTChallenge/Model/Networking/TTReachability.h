//
//  TTReachability.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

extern NSString *TTReachabilityChangedNotification;

typedef enum : NSInteger {
    TTNetworkStatusNotReachable = 0,
    TTNetworkStatusReachableViaWiFi,
    TTNetworkStatusReachableViaWWAN
} TTNetworkStatus;

@interface TTReachability : NSObject

+ (instancetype)sharedObject;
- (BOOL)startMonitoring;
- (void)stopMonitoring;
- (BOOL)isReachable;

@end
