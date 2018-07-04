//
//  TTDataManager.h
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTHTTPClient;
@class TTReachability;
@class TTUserBuilder;

@protocol TTFetchObserver;

typedef void(^TTImageDownloadCompletion)(UIImage *downloadedImage, NSString *responseURLString,  NSError *error);

@interface TTSoundCloudManager : NSObject
// get singleton
+ (instancetype)sharedManager;

// designated initialiser with dependency injection
- (instancetype)initWithAPIClient:(TTHTTPClient *)client
                     reachability:(TTReachability *)reachability
                          builder:(TTUserBuilder *)builder;

// add observer to get notified when data finished loading and parsing
- (void)addObserver:(id <TTFetchObserver>)observer;

// load data: user profile & list of favorite tracks if there is no cache
- (void)fetchDataIfNeeded;

// download images
- (NSURLSessionDownloadTask *)getImageWithURL:(NSString *)urlString
                                   completion:(TTImageDownloadCompletion)completion;

@end
