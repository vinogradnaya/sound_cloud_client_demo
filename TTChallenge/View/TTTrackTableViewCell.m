//
//  TTTrackTableViewCell.m
//  TTChallenge
//
//  Created by keksiy on 11.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTTrackTableViewCell.h"
#import "TTImageView.h"
#import "TTDefines.h"

@interface TTTrackTableViewCell ()
@property (nonatomic, weak) IBOutlet TTImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@end

@implementation TTTrackTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat width = SCREEN_SIZE.width;
    self.titleLabel.preferredMaxLayoutWidth = width;
    self.artistLabel.preferredMaxLayoutWidth = width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.artistLabel.text = nil;
    self.titleLabel.text = nil;
    self.artworkImageView.image = nil;
    self.track = nil;
}

- (void)setTrack:(TTTrack *)track
{
    if (_track != track) {
        _track = track;

        if (_track != nil) {
            [self.artworkImageView setImageWithURL:_track.artworkURL];
            self.titleLabel.text = _track.title;
            self.artistLabel.text = _track.artist;
        }
    }
}

@end
