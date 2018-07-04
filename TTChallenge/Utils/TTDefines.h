//
//  TTDefines.h
//  TTChallenge
//
//  Created by keksiy on 07.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#ifndef TTChallenge_TTDefines_h
#define TTChallenge_TTDefines_h

#define TTAssert(expression, ...) \
    do { \
        if(!(expression)) { \
            NSString *__TTAssert_temp_string = [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat: @"" __VA_ARGS__]]; \
            NSLog(@"%@", __TTAssert_temp_string); \
            abort(); \
        } \
    } while(0)

#ifdef DEBUG
#define TTLog(x, ...) NSLog(@"\n%s \n%d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TTLog(x, ...)
#endif

#define SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#define SCREEN_SIZE (SCREEN_BOUNDS.size)

#endif
