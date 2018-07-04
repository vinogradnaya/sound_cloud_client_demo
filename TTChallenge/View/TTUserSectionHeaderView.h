//
//  TTUserSectionHeaderView.h
//  TTChallenge
//
//  Created by keksiy on 11.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTUser;

@interface TTUserSectionHeaderView : UIView
@property (nonatomic, weak) IBOutlet UIView *backgroundColor;
@property (nonatomic, strong) TTUser *user;

+ (instancetype)buildViewWithFrame:(CGRect)frame;

@end
