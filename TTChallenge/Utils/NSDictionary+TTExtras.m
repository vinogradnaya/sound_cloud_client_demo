//
//  NSDictionary+TTExtras.m
//  TTChallenge
//
//  Created by keksiy on 07.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "NSDictionary+TTExtras.h"

@implementation NSDictionary (TTExtras)

- (id)objectNotNullForKey:(id)key
{
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;

    return object;
}

@end
