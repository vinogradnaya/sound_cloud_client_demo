//
//  TTParsedTrack.h
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTParsedTrack : NSObject
@property (nonatomic, strong, readonly) NSNumber * scID;
@property (nonatomic, strong, readonly) NSNumber * duration;
@property (nonatomic, strong, readonly) NSNumber * releaseYear;
@property (nonatomic, copy, readonly) NSString * title;
@property (nonatomic, copy, readonly) NSString * artist;
@property (nonatomic, copy, readonly) NSString * artworkURL;
@property (nonatomic, copy, readonly) NSString * streamURL;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary;

@end
