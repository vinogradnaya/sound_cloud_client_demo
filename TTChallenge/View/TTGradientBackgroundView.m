//
//  TTGradientBackgroundView.m
//  TTChallenge
//
//  Created by keksiy on 24.09.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTGradientBackgroundView.h"
#import "TTImageView.h"
#import "UIImageEffects.h"
#import "UIImage+TTExtras.h"
#import "TTBlurredImageView.h"
#import "TTDefines.h"

static NSString *const kTTObservableKeyPath = @"contentOffset";

@interface TTGradientBackgroundView ()
@property (nonatomic, weak) IBOutlet TTImageView *imageView;
@property (nonatomic, weak) IBOutlet TTBlurredImageView *blurredView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIColor *gradientColor;
@property (nonatomic, strong) CAGradientLayer *bottomGradient;
@end

@implementation TTGradientBackgroundView

+ (instancetype)buildViewWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TTGradientBackgroundView class])
                                                      owner:self
                                                    options:nil];

    TTGradientBackgroundView* view = [nibViews objectAtIndex: 0];
    view.frame = frame;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    view.scrollView = scrollView;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)customizeForImageWithURL:(NSString *)imageURL
                      completion:(TTGradientViewLoadCompletion)completion {
    if ([imageURL isEqualToString:self.imageURL] && self.gradientColor != nil) {
        if (completion) {
            completion (self.gradientColor, nil);
        }
        return;
    }

    self.imageURL = imageURL;

    __weak typeof(self) weakSelf = self;
    [self.imageView setImageWithURL:imageURL completion:^(UIImage *image, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf customizeForImage:image
                               completion:completion];
        } else {
            if (completion) {
                completion (nil, error);
            }
        }
    }];
}

- (void)customizeForImage:(UIImage *)image
               completion:(TTGradientViewLoadCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *gradientColor = [image averageColor];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self customizeForImage:image
                              color:gradientColor];
            if (completion) {
                completion (gradientColor, nil);
            }
        });
    });
}

- (void)customizeForImage:(UIImage *)image
                    color:(UIColor *)color {
    self.backgroundColor = color;
    self.contentView.backgroundColor = color;
    self.gradientColor = color;
    self.blurredView.image = image;
    [self addBottomGradientWithColor:color];
}

- (void)setUp {
    [self addTopGradient];
    [self setUpContentView];
}

- (void)setUpContentView {
    [self setUpImageViews];
    [self transformContentView];
}

- (void)setUpImageViews {
    self.blurredView.alpha = 0;
}

- (void)transformContentView {
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, -SCREEN_SIZE.height / 4, 0);
    self.contentView.layer.transform = transform;
}

- (void)addTopGradient {
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 70);
    topGradient.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
    topGradient.opacity = 0.6;
    [self.layer addSublayer:topGradient];
}

- (void)addBottomGradientWithColor:(UIColor *)color {

    if ([self.bottomGradient superlayer] != nil) {
        [self.bottomGradient removeFromSuperlayer];
    }

    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height);
    bottomGradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[color CGColor]];
    bottomGradient.locations = @[@(0.4), @(1.0)];

    bottomGradient.opacity = 1.f;
    self.bottomGradient = bottomGradient;
    [self.contentView.layer addSublayer:self.bottomGradient];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        [_scrollView removeObserver:self forKeyPath:kTTObservableKeyPath];
        _scrollView = scrollView;
        [_scrollView addObserver:self forKeyPath:kTTObservableKeyPath options:0 context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.scrollView && [keyPath isEqualToString:kTTObservableKeyPath]) {
        CGFloat offset = self.scrollView.contentOffset.y + self.scrollView.contentInset.top;
        [self setBlurLevelForOffset:offset];
        [self setTransformForOffset:offset];
    }
}

- (void)setBlurLevelForOffset:(CGFloat)offset {
    CGFloat alpha = MIN(1, MAX(0, offset / self.scrollView.contentInset.top * 2));
    self.blurredView.alpha = alpha;
}

- (void)setTransformForOffset:(CGFloat)offset {
    CATransform3D transform = CATransform3DIdentity;

    if (offset < 0) {
        CGFloat scaleFactor = -(offset) / (self.bounds.size.height);
        CGFloat sizeVariation = ((self.bounds.size.height * (1.0 + scaleFactor)) - self.bounds.size.height)/2.0;
        transform = CATransform3DTranslate(transform, 0, sizeVariation, 0);
        transform = CATransform3DScale(transform, 1.0 + scaleFactor, 1.0 + scaleFactor, 0);
    } else {
        transform = CATransform3DTranslate(transform, 0, MAX(-([UIScreen mainScreen].bounds.size.height), -offset), 0);
    }

    self.layer.transform = transform;
}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:kTTObservableKeyPath];
}

@end
