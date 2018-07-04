//
//  TTFetchObserver.h
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;

@protocol TTFetchObserver <NSObject>

// will be called when user data loading & parsing is finished
- (void)didFetchUser:(TTUser *)user error:(NSError *)error;

@end
