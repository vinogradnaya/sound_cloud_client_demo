//
//  TTGradientBackgroundView.h
//  TTChallenge
//
//  Created by keksiy on 24.09.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTImageView;

typedef void(^TTGradientViewLoadCompletion)(UIColor *color, NSError *error);

@interface TTGradientBackgroundView : UIView
+ (instancetype)buildViewWithFrame:(CGRect)frame
                        scrollView:(UIScrollView *)scrollView;
- (void)customizeForImageWithURL:(NSString *)imageURL
                      completion:(TTGradientViewLoadCompletion)completion;
@end
