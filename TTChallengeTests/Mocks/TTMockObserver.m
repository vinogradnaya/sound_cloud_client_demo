//
//  TTMockObserver.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTMockObserver.h"

@implementation TTMockObserver

- (void)didFetchUser:(TTUser *)user error:(NSError *)error
{
    self.didNotifyObserver = YES;
    self.error = error;
    self.user = user;
}

@end
