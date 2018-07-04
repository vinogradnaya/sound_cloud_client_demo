//
//  TTSoundCloudManager+TTTests.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTSoundCloudManager.h"

typedef void(^TTFetchCompletion)(id responseObject,  NSError *error);

@interface TTSoundCloudManager (TTTests)
@property (nonatomic, copy) TTFetchCompletion fetchCompletion;
@end
