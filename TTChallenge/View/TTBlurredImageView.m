//
//  TTBlurredImageView.m
//  TTChallenge
//
//  Created by keksiy on 24.09.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTBlurredImageView.h"
#import "UIImageEffects.h"

@implementation TTBlurredImageView

- (void)setImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurredImage = [UIImageEffects imageByApplyingLightEffectToImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            [super setImage:blurredImage];
        });
    });

}

@end
