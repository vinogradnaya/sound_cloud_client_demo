//
//  TTParsedUserTests.m
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTParsedUser.h"

@interface TTParsedUserTests : XCTestCase
@property (nonatomic, strong) TTParsedUser *user;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@end

@implementation TTParsedUserTests

- (void)setUp {
    [super setUp];

    NSDictionary *dToParse = @{@"id": @(3156285),
                               @"kind":@"user",
                               @"permalink":@"madonna",
                               @"username":@"username",
                               @"last_modified":@"2015/04/23 22:43:52 +0000",
                               @"uri":@"https://api.soundcloud.com/users/3156285",
                               @"permalink_url":@"http://soundcloud.com/madonna",
                               @"avatar_url":@"https://i1.sndcdn.com/avatars-000121797780-8fj2ls-large.jpg",
                               @"country":@"United States",
                               @"first_name":@"First",
                               @"last_name":@"Last",
                               @"full_name":@"Full Name",
                               @"description":@"This is user description",
                               @"city":@"New York",
                               @"discogs_name":[NSNull null],
                               @"myspace_name":[NSNull null],
                               @"website":@"http://smarturl.it/RebelHeart",
                               @"website_title":@"Pre-Order The New Album",
                               @"online":@"false",
                               @"track_count":@34,
                               @"playlist_count":@0,
                               @"plan":@"Pro Plus",
                               @"public_favorites_count":@2,
                               @"followers_count":@1507527,
                               @"followings_count":@20};
    self.parameters = [[NSMutableDictionary alloc] initWithDictionary:dToParse];

    NSError *error = nil;
    self.user = [TTParsedUser instanceFromDictionary:dToParse error:&error];
}

- (void)tearDown {
    self.parameters = nil;
    self.user = nil;
    [super tearDown];
}

- (void)testParsedUserHasID {
    XCTAssertEqualObjects(self.user.scID, @(3156285), @"Parsed User should have an ID");
}

- (void)testParsedUserHasName {
    XCTAssertEqualObjects(self.user.name, @"Full Name", @"Parsed User should have a fullname");
}

- (void)testParsedUserHasUsername {
    XCTAssertEqualObjects(self.user.username, @"username", @"Parsed User should have a username");
}

- (void)testParsedUserHasAvatarURL {
    XCTAssertEqualObjects(self.user.avatarURL, @"https://i1.sndcdn.com/avatars-000121797780-8fj2ls-t500x500.jpg", @"Parsed User should have an avatar URL");
}

- (void)testParsedUserHasCountry {
    XCTAssertEqualObjects(self.user.country, @"United States", @"Parsed User should have a country");
}

- (void)testParsedUserHasCity {
    XCTAssertEqualObjects(self.user.city, @"New York", @"Parsed User should have a city");
}

- (void)testParsedUserHasCaption {
    XCTAssertEqualObjects(self.user.caption, @"This is user description", @"Parsed User should have a caption");
}

- (void)testParsedUserHasFavoriteTracksCount {
    XCTAssertEqualObjects(self.user.favoriteTracksCount, @2, @"Parsed User should have a favorite tracks count");
}

- (void)testParsedUserHasFollowersCount {
    XCTAssertEqualObjects(self.user.followersCount, @1507527, @"Parsed User should have a followers count");
}

- (void)testParsedUserHasFollowingsCount {
    XCTAssertEqualObjects(self.user.followingsCount, @20, @"Parsed User should have a followings count");
}

- (void)testParsedUserIsNilWhenPassedDictionaryIsNil {
    NSError *error = nil;
    TTParsedUser *user = [TTParsedUser instanceFromDictionary:nil error:&error];
    XCTAssertNil(user, @"returned value should be nil, if there is no dictionary");
}

- (void)testErrorIsReturnedWhenPassedDictionaryIsNil {
    NSError *error = nil;
    [TTParsedUser instanceFromDictionary:nil error:&error];
    XCTAssertNotNil(error, @"should return error, if there is no dictionary, we can not override cached user with nil parameters");
}

- (void)testParsedUserIsNilWhenUsernameNil {
    [self.parameters setObject:[NSNull null] forKey:@"username"];
    NSError *error = nil;
    TTParsedUser *user = [TTParsedUser instanceFromDictionary:self.parameters error:&error];
    XCTAssertNil(user, @"returned value should be nil, we can not create user with no username");
}

- (void)testParsedUserIsNilWhenIDNil {
    [self.parameters setObject:[NSNull null] forKey:@"id"];
    NSError *error = nil;
    TTParsedUser *user = [TTParsedUser instanceFromDictionary:self.parameters error:&error];
    XCTAssertNil(user, @"returned value should be nil, we can not create user with no id");
}

- (void)testErrorIsReturnedWhenUsernameNil {
    [self.parameters setObject:[NSNull null] forKey:@"username"];
    NSError *error = nil;
    [TTParsedUser instanceFromDictionary:self.parameters error:&error];
    XCTAssertNotNil(error, @"should return error, if there is no username");
}

- (void)testErrorIsReturnedWhenIDNil {
    [self.parameters setObject:[NSNull null] forKey:@"id"];
    NSError *error = nil;
    [TTParsedUser instanceFromDictionary:self.parameters error:&error];
    XCTAssertNotNil(error, @"should return error, if there is no id");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
