//
//  TTNSURLSessionMock.h
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TTMockDataTaskCompletionHadler)(NSData *, NSURLResponse *, NSError *);
typedef void(^TTMockDownloadTaskCompletionHadler)(NSURL *, NSURLResponse *, NSError *);

@interface TTMockDataResponse : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
- (instancetype)initWithData:(NSData *)data
                    response:(NSURLResponse *)response
                       error:(NSError *)error;
@end

@interface TTMockDownloadResponse : NSObject
@property (nonatomic, strong) NSURL *location;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
- (instancetype)initWithLocation:(NSURL *)location
                        response:(NSURLResponse *)response
                           error:(NSError *)error;
@end

@interface TTMockSession : NSURLSession
@property (nonatomic, strong) TTMockDataResponse *mockDataResponse;
@property (nonatomic, strong) TTMockDownloadResponse *mockDownloadResponse;
@property (nonatomic, strong) NSURLRequest *request;
@end

