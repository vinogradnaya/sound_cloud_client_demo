//
//  TTHTTPClient.h
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TTHTTPClientGetCompletion)(id responseObject, NSError *error);
typedef void(^TTHTTPClientDownloadCompletion)(NSData *downloadedData, NSURLResponse *response,  NSError *error);

@interface TTHTTPClient : NSObject

// default initialiser with dependency injection
- (instancetype)initWithBaseURL:(NSString *)baseURL session:(NSURLSession *)session;

// get arbitrary data providing the API endpoint
- (void)getDataWithURL:(NSString *)urlString
            parameters:(NSDictionary *)parameters
            completion:(TTHTTPClientGetCompletion)completion;

// download data providing the complete URL
- (NSURLSessionDownloadTask *)dowloadDataWithURL:(NSString *)urlString
                                      completion:(TTHTTPClientDownloadCompletion)completion;
@end
