//
//  TTMockObserver.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTFetchObserver.h"

@class TTUser;

@interface TTMockObserver : NSObject <TTFetchObserver>
@property (nonatomic, assign) BOOL didNotifyObserver;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) TTUser *user;
@end
