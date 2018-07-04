//
//  TTImageView.m
//  TTChallenge
//
//  Created by Katerina Vinogradnaya on 1/27/15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTImageView.h"
#import "TTSoundCloudManager.h"
#import "TTImageCache.h"
#import "TTConstants.h"

@interface TTImageView ()
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (copy, nonatomic) NSString *urlString;
@end

@implementation TTImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
}

- (void)setImageWithURL:(NSString *)urlString {
    [self setImageWithURL:urlString completion:nil];
}

- (void)setImageWithURL:(NSString *)urlString
             completion:(TTImageViewCompletion)completion {

    if (urlString == nil) {
        self.image = nil;
        if (completion) {
            NSError *error = [NSError errorWithDomain:TTImageViewErrorDomain
                                                 code:TTErrorCodeWrongInputError
                                             userInfo:nil];
            completion (nil, error);
        }
        return;
    }

    UIImage *cachedImage = [[TTImageCache sharedObject] imageForURL:urlString];
    if (cachedImage) {
        self.image = cachedImage;
        if (completion != nil) {
            completion(cachedImage, nil);
        }
        return;
    }

    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
    }

    self.urlString = urlString;

    if (urlString) {
        __weak typeof(self) weakSelf = self;

        self.task = [[TTSoundCloudManager sharedManager] getImageWithURL:urlString completion:^(UIImage *downloadedImage, NSString *responseURLString, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if ([strongSelf.urlString isEqualToString:responseURLString]) {
                        strongSelf.image = downloadedImage;
                        CATransition *transition = [CATransition animation];
                        transition.duration = .6f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [strongSelf.layer addAnimation:transition forKey:nil];
                    }
                }
                if (completion) {
                    completion(downloadedImage, error);
                }
            });
        }];
    }
}
@end
