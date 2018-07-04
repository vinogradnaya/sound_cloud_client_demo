//
//  ViewController.h
//  TTChallenge
//
//  Created by keksiy on 05.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTFetchObserver.h"

@class TTSoundCloudManager;

@interface TTMainViewController : UIViewController <TTFetchObserver>
@property (nonatomic, strong) TTSoundCloudManager *dataManager;
@end

