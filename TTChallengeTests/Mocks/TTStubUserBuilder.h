//
//  TTStubUserBuilder.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTUserBuilder.h"

@interface TTStubUserBuilder : TTUserBuilder
@property (nonatomic, strong) NSError *addingUserError;
@property (nonatomic, strong) NSError *addingTracksError;
@property (nonatomic, strong) NSError *buildError;
@property (nonatomic, strong) TTUser *user;

@end
