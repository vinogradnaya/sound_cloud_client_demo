//
//  TTParsedTrack.m
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTParsedTrack.h"
#import "NSDictionary+TTExtras.h"
#import "TTConstants.h"

@interface TTParsedTrack ()
@property (nonatomic, strong, readwrite) NSNumber * scID;
@property (nonatomic, strong, readwrite) NSNumber * duration;
@property (nonatomic, strong, readwrite) NSNumber * releaseYear;
@property (nonatomic, copy, readwrite) NSString * title;
@property (nonatomic, copy, readwrite) NSString * artist;
@property (nonatomic, copy, readwrite) NSString * artworkURL;
@property (nonatomic, copy, readwrite) NSString * streamURL;
@end


@implementation TTParsedTrack

- (NSString *)description
{
    NSString *d = [NSString stringWithFormat:@"id: %@\nduration: %@\ntitle: %@\nreleaseYear: %@\nartist: %@\nartworkURL: %@\nstreamURL: %@", self.scID, self.duration, self.title, self.releaseYear, self.artist, self.artworkURL, self.streamURL];

    return d;
}

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil) {
        return nil;
    }

    NSNumber *scID = [dictionary objectNotNullForKey:@"id"];
    if (scID == nil) {
        return nil;
    }

    TTParsedTrack *track = [TTParsedTrack new];
    track.scID = scID;
    track.title = [dictionary objectNotNullForKey:@"title"];
    track.releaseYear = [dictionary objectNotNullForKey:@"release_year"];
    track.duration = [dictionary objectNotNullForKey:@"duration"];
    track.artworkURL = [dictionary objectNotNullForKey:@"artwork_url"];

    NSString *streamURL = [dictionary objectNotNullForKey:@"stream_url"];
    track.streamURL = [self stringURLbyAddingClientIDToString:streamURL];

    NSDictionary *artist = [dictionary objectNotNullForKey:@"user"];
    track.artist = [artist objectNotNullForKey:@"username"];

    return track;
}

+ (NSString *)stringURLbyAddingClientIDToString:(NSString *)string
{
    return [NSString stringWithFormat:@"%@?client_id=%@", string, TTSoundCloudClientID];
}
@end
