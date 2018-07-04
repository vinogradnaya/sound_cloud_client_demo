//
//  TTParsedTrackTests.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTParsedTrack.h"

@interface TTParsedTrackTests : XCTestCase
@property (nonatomic, strong) TTParsedTrack *track;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@end

@implementation TTParsedTrackTests

- (void)setUp {
    [super setUp];
    NSDictionary *dToParse = @{@"kind":@"track",
                               @"id":@214807095,
                               @"created_at":@"2015/07/15 09:28:35 +0000",
                               @"user_id":@3156285,
                               @"commentable":@"true",
                               @"state":@"finished",
                               @"original_content_size":@12675656,
                               @"last_modified":@"2015/08/20 15:50:55 +0000",
                               @"sharing":@"public",
                               @"tag_list":@"",
                               @"permalink":@"vogue",
                               @"streamable":@"true",
                               @"embeddable_by":@"all",
                               @"downloadable":@"false",
                               @"purchase_url":[NSNull null],
                               @"label_id":[NSNull null],
                               @"purchase_title":[NSNull null],
                               @"genre":@"Pop",
                               @"title":@"Vogue",
                               @"description":[NSNull null],
                               @"label_name":@"Warner Bros.",
                               @"release":[NSNull null],
                               @"track_type":[NSNull null],
                               @"key_signature":[NSNull null],
                               @"isrc":[NSNull null],
                               @"video_url":[NSNull null],
                               @"bpm":[NSNull null],
                               @"release_year":@2009,
                               @"release_month":@9,
                               @"release_day":@18,
                               @"original_format":@"mp3",
                               @"license":@"all-rights-reserved",
                               @"uri":@"https://api.soundcloud.com/tracks/214807095",
                               @"user":@{
                                   @"id":@3156285,
                                   @"kind":@"user",
                                   @"permalink":@"madonna",
                                   @"username":@"Madonna",
                                   @"last_modified":@"2015/04/23 22:43:52 +0000",
                                   @"uri":@"https://api.soundcloud.com/users/3156285",
                                   @"permalink_url":@"http://soundcloud.com/madonna",
                                   @"avatar_url":@"https://i1.sndcdn.com/avatars-000121797780-8fj2ls-large.jpg"},
                               @"permalink_url":@"http://soundcloud.com/madonna/vogue",
                               @"artwork_url":@"https://i1.sndcdn.com/ci-mroL46k5K2Iu-0-large.jpg",
                               @"stream_url":@"https://api.soundcloud.com/tracks/214807095/stream",
                               @"playback_count":@47277,
                               @"download_count":@0,
                               @"favoritings_count":@782,
                               @"comment_count":@3,
                               @"attachments_uri":@"https://api.soundcloud.com/tracks/214807095/attachments",
                               @"waveform_url":@"https://wave.sndcdn.com/OZkiDONaXXHj_m_p90.png",
                               @"duration":@90000,
                               @"policy":@"SNIP",
                               @"monetization_model":@"NOT_APPLICABLE"};
    self.parameters = [[NSMutableDictionary alloc] initWithDictionary:dToParse];
    self.track = [TTParsedTrack instanceFromDictionary:dToParse];
}

- (void)tearDown {
    self.track = nil;
    self.parameters = nil;
    [super tearDown];
}

- (void)testParsedTrackHasID {
    XCTAssertEqualObjects(self.track.scID, @214807095, @"Parsed Track should have an ID");
}

- (void)testParsedTrackHasTitle {
    XCTAssertEqualObjects(self.track.title, @"Vogue", @"Parsed Track should have a title");
}

- (void)testParsedTrackHasArtist {
    XCTAssertEqualObjects(self.track.artist, @"Madonna", @"Parsed Track should have an artist name");
}

- (void)testParsedTrackHasDuration {
    XCTAssertEqualObjects(self.track.duration, @90000, @"Parsed Track should have a duration");
}

- (void)testParsedTrackHasReleaseYear {
    XCTAssertEqualObjects(self.track.releaseYear, @2009, @"Parsed Track should have a release year");
}

- (void)testParsedTrackHasArtworkURL {
    XCTAssertEqualObjects(self.track.artworkURL, @"https://i1.sndcdn.com/ci-mroL46k5K2Iu-0-large.jpg", @"Parsed Track should have artwork URL");
}

- (void)testParsedTrackHasCorrectStreamURLWithClientID {
    XCTAssertEqualObjects(self.track.streamURL, @"https://api.soundcloud.com/tracks/214807095/stream?client_id=4010038b2d63e0399b85dc32a64a78f7", @"Parsed Track should have correct stream URL");
}

- (void)testParsedTrackIsNilWhenPassedDictionaryIsNil {
    TTParsedTrack *track = [TTParsedTrack instanceFromDictionary:nil];
    XCTAssertNil(track, @"returned value should be nil, if there is no dictionary");
}

- (void)testParsedTrackIsNilWhenPassedNilID {
    [self.parameters setObject:[NSNull null] forKey:@"id"];
    TTParsedTrack *track = [TTParsedTrack instanceFromDictionary:self.parameters];
    XCTAssertNil(track, @"returned value should be nil, if there is no id");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
