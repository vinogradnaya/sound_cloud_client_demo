//
//  TTImageCache.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTImageCache.h"

@interface TTImageCache ()
@property (nonatomic, strong) NSCache *defaultImageCache;
@end

@implementation TTImageCache

+ (instancetype)sharedObject
{
    static TTImageCache *sImageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sImageCache = [TTImageCache new];
    });
    return sImageCache;
}

- (instancetype)initWithCache:(NSCache *)cache
{
    self = [super init];
    if (self) {
        self.defaultImageCache = (cache != nil)? cache : [NSCache new];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification * __unused notification) {
                            [self clearCache];
                        }];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithCache:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearCache];
}

- (void)clearCache
{
    [self.defaultImageCache removeAllObjects];
}

- (UIImage *)imageForURL:(NSString *)URLString
{
    if (!URLString) {
        return nil;
    }

    UIImage *image = [self.defaultImageCache objectForKey:URLString];
    return image;
}

-(void)registerImage:(UIImage *)image
              forURL:(NSString *)URLString
{
    
    if (!image || !URLString) {
        return;
    }
    
    [self.defaultImageCache setObject:image forKey:URLString];
}

@end
