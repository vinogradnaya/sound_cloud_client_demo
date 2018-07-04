//
//  TTUserSectionHeaderView.m
//  TTChallenge
//
//  Created by keksiy on 11.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTUserSectionHeaderView.h"
#import "TTUser.h"

@interface TTUserSectionHeaderView ()
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingsLabel;
@property (nonatomic, weak) IBOutlet UILabel *favoriteTracksLabel;

@end


@implementation TTUserSectionHeaderView

+ (instancetype)buildViewWithFrame:(CGRect)frame
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TTUserSectionHeaderView class])
                                                      owner:self
                                                    options:nil];

    TTUserSectionHeaderView* view = [nibViews objectAtIndex: 0];
    view.frame = frame;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    return view;
}

- (void)setUser:(TTUser *)user
{
    _user = user;

    if (_user != nil) {
        self.usernameLabel.text = _user.username;
        self.locationLabel.text = [NSString stringWithFormat:@"%@%@ %@", _user.city, _user.country != nil? @"," : @"", _user.country];
        self.followersLabel.text = [NSString stringWithFormat:@"%d", [_user.followersCount intValue]];
        self.followingsLabel.text = [NSString stringWithFormat:@"%d", [_user.followingsCount intValue]];
        self.favoriteTracksLabel.text = [NSString stringWithFormat:@"%d", [_user.favoriteTracksCount intValue]];
    }
}

@end
