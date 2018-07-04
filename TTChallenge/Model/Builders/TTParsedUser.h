//
//  TTParsedUser.h
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTParsedUser : NSObject
@property (nonatomic, copy, readonly) NSString * username;
@property (nonatomic, copy, readonly) NSString * avatarURL;
@property (nonatomic, copy, readonly) NSString * country;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSString * city;
@property (nonatomic, copy, readonly) NSString * caption;
@property (nonatomic, strong, readonly) NSNumber * favoriteTracksCount;
@property (nonatomic, strong, readonly) NSNumber * followersCount;
@property (nonatomic, strong, readonly) NSNumber * followingsCount;
@property (nonatomic, strong, readonly) NSNumber * scID;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary
                                 error:(NSError **)error;

@end
