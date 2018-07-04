//
//  TTReachability.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2014 vinogradnaya. All rights reserved.
//

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

#import "TTReachability.h"

NSString *TTReachabilityChangedNotification = @"kTTNetworkReachabilityChangedNotification";

@interface TTReachability () {
	SCNetworkReachabilityRef _reachabilityRef;
}
@property (nonatomic, assign) BOOL monitoringInRunning;
- (TTNetworkStatus)networkStatus;
@end

static void TTReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    if (info != NULL && [(__bridge NSObject*) info isKindOfClass: [TTReachability class]]) {
        TTReachability* noteObject = (__bridge TTReachability *)info;
        
        TTNetworkStatus status = [noteObject networkStatus];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: TTReachabilityChangedNotification object:@(status)];
    }
}

@implementation TTReachability

+ (instancetype)sharedObject
{
    static TTReachability *sReachability = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,
                  ^{
                      sReachability = [TTReachability build];
                  });
    
	return sReachability;
}

+ (instancetype)build
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
	TTReachability* returnValue = NULL;
    
	if (reachability != NULL) {
		returnValue = [[self alloc] init];
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
            returnValue.monitoringInRunning = NO;
		}
	}
	return returnValue;
}

- (void)dealloc
{
	[self stopMonitoring];
	if (_reachabilityRef != NULL) {
		CFRelease(_reachabilityRef);
	}
}

#pragma mark - Start and stop notifier

- (BOOL)startMonitoring
{
    if (self.monitoringInRunning) {
        return YES;
    }
    
    BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
	if (SCNetworkReachabilitySetCallback(_reachabilityRef, TTReachabilityCallback, &context)){
		if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
			returnValue = YES;
		}
	}
    
    self.monitoringInRunning = returnValue;
	return self.monitoringInRunning;
}

- (void)stopMonitoring
{
	if (_reachabilityRef != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        self.monitoringInRunning = NO;
	}
}

#pragma mark - Network Flag Handling

- (BOOL)isReachable
{
    TTNetworkStatus status = [self networkStatus];
    return status != TTNetworkStatusNotReachable;
}

- (TTNetworkStatus)networkStatus
{
	TTNetworkStatus returnValue = TTNetworkStatusNotReachable;
    
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
            returnValue = [self networkStatusForFlags:flags];
        }
    }
    
	return returnValue;
}

- (TTNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// The target host is not reachable.
		return TTNetworkStatusNotReachable;
	}
    
    TTNetworkStatus returnValue = TTNetworkStatusNotReachable;
    
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = TTNetworkStatusReachableViaWiFi;
	}
    
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = TTNetworkStatusReachableViaWiFi;
        }
    }
    
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = TTNetworkStatusReachableViaWWAN;
	}
    
	return returnValue;
}

@end