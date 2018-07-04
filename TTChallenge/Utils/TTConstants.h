//
//  TTConstants.h
//  TTChallenge
//
//  Created by keksiy on 12.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

// errors
typedef NS_ENUM(NSInteger, TTErrorCode)
{
    TTErrorCodeFetchError,
    TTErrorCodeParsingError,
    TTErrorCodeSavingError,
    TTErrorCodeNetworkError,
    TTErrorCodeWrongInputError,
    TTErrorCodeUknownError
};

extern NSString * const TTCoreDataManagerErrorDomain;
extern NSString * const TTHTTPErrorDomain;
extern NSString * const TTImageViewErrorDomain;
extern NSString * const TTParsedUserErrorDomain;
extern NSString * const TTSoundCloudManagerErrorDomain;
extern NSString * const TTUserBuilderErrorDomain;

// sound cloud id
extern NSString *const TTSoundCloudClientID;

