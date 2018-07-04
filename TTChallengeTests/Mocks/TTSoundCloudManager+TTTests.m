//
//  TTSoundCloudManager+TTTests.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTSoundCloudManager+TTTests.h"
#import <objc/runtime.h>

@implementation TTSoundCloudManager (TTTests)
- (TTFetchCompletion)fetchCompletion
{
    return objc_getAssociatedObject(self, @selector(fetchCompletion));
}

- (void)setFetchCompletion:(TTFetchCompletion)fetchCompletion
{
    objc_setAssociatedObject(self, @selector(fetchCompletion), fetchCompletion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
