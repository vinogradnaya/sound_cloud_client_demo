//
//  NSString+TTExtras.m
//  TTChallenge
//
//  Created by keksiy on 12.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "NSString+TTExtras.h"

@implementation NSString (TTExtras)
+ (NSString *)stringFromErrorCode:(TTErrorCode)errorCode
{
    NSString *errorString = nil;

    switch (errorCode) {
        case TTErrorCodeFetchError:
            errorString = @"Error occured while loading data";
            break;
        case TTErrorCodeNetworkError:
            errorString = @"No Internet Connection";
            break;
        case TTErrorCodeParsingError:
            errorString = @"Error occured parsing data";
            break;
        case TTErrorCodeSavingError:
            errorString = @"Error occured saving data";
            break;
        default:
            errorString = @"Error occured";
            break;
    }

    return errorString;
}
@end
