//
//  TTImageCache.h
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTImageCache : NSObject

// get signleton
+ (instancetype)sharedObject;

// designated initialiser with dependency injection
- (instancetype)initWithCache:(NSCache *)cache;

// get image by URL if it exists in cache
- (UIImage *)imageForURL:(NSString *)URLString;

// add image to cache
- (void)registerImage:(UIImage *)image forURL:(NSString *)URLString;

@end
