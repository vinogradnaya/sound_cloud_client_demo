//
//  NSString+TTExtras.h
//  TTChallenge
//
//  Created by keksiy on 12.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTConstants.h"

@interface NSString (TTExtras)
+ (NSString *)stringFromErrorCode:(TTErrorCode)errorCode;
@end
