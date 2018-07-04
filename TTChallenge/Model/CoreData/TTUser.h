//
//  TTUser.h
//  TTChallenge
//
//  Created by keksiy on 07.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface TTUser : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * favoriteTracksCount;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * followingsCount;
@property (nonatomic, retain) NSNumber * scID;
@property (nonatomic, retain) NSSet *favoriteTracks;

@end

@interface TTUser (CoreDataGeneratedAccessors)

- (void)addFavoriteTracksObject:(NSManagedObject *)value;
- (void)removeFavoriteTracksObject:(NSManagedObject *)value;
- (void)addFavoriteTracks:(NSSet *)values;
- (void)removeFavoriteTracks:(NSSet *)values;

@end
