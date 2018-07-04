//
//  TTNSURLSessionMock.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTMockSession.h"

@interface TTMockDataResponse ()
@end

@implementation TTMockDataResponse
- (instancetype)initWithData:(NSData *)data
                    response:(NSURLResponse *)response
                       error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.data = data;
        self.response = response;
        self.error = error;
    }

    return self;
}

@end

@implementation TTMockDownloadResponse
- (instancetype)initWithLocation:(NSURL *)location
                        response:(NSURLResponse *)response
                           error:(NSError *)error{
    self = [super init];
    if (self) {
        self.location = location;
        self.response = response;
        self.error = error;
    }

    return self;
}

@end


@interface TTMockDataTask : NSURLSessionDataTask
@property (nonatomic, copy) TTMockDataTaskCompletionHadler completionHandler;
@property (nonatomic, strong) TTMockDataResponse *mockResponse;
@end

@implementation TTMockDataTask

- (instancetype)initWithResponse:(TTMockDataResponse *)response
               completionHandler:(TTMockDataTaskCompletionHadler)completionHandler
{
    self = [super init];

    if (self) {
        self.completionHandler = completionHandler;
        self.mockResponse = response;
    }

    return self;
}

- (void)resume
{
    self.completionHandler(self.mockResponse.data, self.mockResponse.response, self.mockResponse.error);
}
@end

@interface TTMockDownloadTask : NSURLSessionDownloadTask
@property (nonatomic, copy) TTMockDownloadTaskCompletionHadler completionHandler;
@property (nonatomic, strong) TTMockDownloadResponse *mockResponse;
@end

@implementation TTMockDownloadTask

- (instancetype)initWithResponse:(TTMockDownloadResponse *)response
               completionHandler:(TTMockDownloadTaskCompletionHadler)completionHandler
{
    self = [super init];

    if (self) {
        self.completionHandler = completionHandler;
        self.mockResponse = response;
    }

    return self;
}

- (void)resume
{
    self.completionHandler(self.mockResponse.location, self.mockResponse.response, self.mockResponse.error);
}

@end


@interface TTMockSession ()
@end

@implementation TTMockSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler
{
    self.request = request;
    TTMockDataTask *task = [[TTMockDataTask alloc] initWithResponse:self.mockDataResponse
                                          completionHandler:completionHandler];
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
                                completionHandler:(void (^)(NSURL *, NSURLResponse *, NSError *))completionHandler
{
    TTMockDownloadTask *task = [[TTMockDownloadTask alloc] initWithResponse:self.mockDownloadResponse completionHandler:completionHandler];
    return task;
}

@end