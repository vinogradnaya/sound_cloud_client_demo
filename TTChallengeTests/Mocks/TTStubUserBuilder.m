//
//  TTStubUserBuilder.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTStubUserBuilder.h"

@implementation TTStubUserBuilder

- (void)addUserDataFromDictionary:(NSDictionary *)dictionary completion:(TTUserBuilderAddCompletion)completion
{
    if (completion) {
        completion(self.addingUserError);
    }
}

- (void)addFavoriteTracksDataFromArray:(NSArray *)array completion:(TTUserBuilderAddCompletion)completion
{
    if (completion) {
        completion(self.addingTracksError);
    }
}

- (TTUser *)buildWithError:(NSError *__autoreleasing *)error
{
    *error = self.buildError;
    return self.user;
}

- (TTUser *)builFromCache
{
    return self.user;
}

@end
