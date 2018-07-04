//
//  TTTrack.h
//  TTChallenge
//
//  Created by keksiy on 09.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TTUser;

@interface TTTrack : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artworkURL;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * releaseYear;
@property (nonatomic, retain) NSString * streamURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * scID;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) TTUser *user;

@end
