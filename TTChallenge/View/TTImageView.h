//
//  TTImageView.h
//  TTChallenge
//
//  Created by Katerina Vinogradnaya on 1/27/15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TTImageViewCompletion)(UIImage *image, NSError *error);

@interface TTImageView : UIImageView

- (void)setImageWithURL:(NSString *)urlString;
- (void)setImageWithURL:(NSString *)urlString
             completion:(TTImageViewCompletion)completion;

@end
