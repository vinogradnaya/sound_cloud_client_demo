//
//  TTMockCoreDataManager.h
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTCoreDataManager.h"

@interface TTMockCoreDataManager : TTCoreDataManager
@property (nonatomic, strong) TTUser *user;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray *tracks;
@end
