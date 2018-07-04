//
//  TTParsedUser.m
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTParsedUser.h"
#import "NSDictionary+TTExtras.h"
#import "TTConstants.h"

@interface TTParsedUser ()
@property (nonatomic, copy, readwrite) NSString * username;
@property (nonatomic, copy, readwrite) NSString * avatarURL;
@property (nonatomic, copy, readwrite) NSString * country;
@property (nonatomic, copy, readwrite) NSString * name;
@property (nonatomic, copy, readwrite) NSString * city;
@property (nonatomic, copy, readwrite) NSString * caption;
@property (nonatomic, strong, readwrite) NSNumber * favoriteTracksCount;
@property (nonatomic, strong, readwrite) NSNumber * followersCount;
@property (nonatomic, strong, readwrite) NSNumber * followingsCount;
@property (nonatomic, strong, readwrite) NSNumber * scID;
@end

@implementation TTParsedUser
- (NSString *)description
{
    NSString *d = [NSString stringWithFormat:@"id: %@\nusername: %@\navatarURL: %@\nname: %@\ncountry: %@\ncity: %@\ncaption: %@\nfavoriteTracksCount: %@\nfollowersCount: %@\nfollowingsCount: %@", self.scID, self.username, self.avatarURL, self.name, self.country, self.city, self.caption, self.favoriteTracksCount, self.followersCount, self.followingsCount];

    return d;
}

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary
                                 error:(NSError *__autoreleasing *)error
{
    NSNumber *userID = [dictionary objectNotNullForKey:@"id"];
    NSString *username = [dictionary objectNotNullForKey:@"username"];

    if (userID == nil|| username == nil) {
        *error = [NSError errorWithDomain: TTParsedUserErrorDomain
                                     code:TTErrorCodeParsingError
                                 userInfo: nil];
        return nil;
    }

    TTParsedUser *user = [TTParsedUser new];
    user.scID = userID;
    user.username = username;
    user.name = [dictionary objectNotNullForKey:@"full_name"];
    user.caption = [dictionary objectNotNullForKey:@"description"];
    user.country = [dictionary objectNotNullForKey:@"country"];
    user.city = [dictionary objectNotNullForKey:@"city"];
    NSString *avatarURL = [dictionary objectNotNullForKey:@"avatar_url"];
    user.avatarURL = [avatarURL stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];

    user.favoriteTracksCount = [dictionary objectNotNullForKey:@"public_favorites_count"];
    user.followersCount = [dictionary objectNotNullForKey:@"followers_count"];
    user.followingsCount = [dictionary objectNotNullForKey:@"followings_count"];

    return user;
}
@end
