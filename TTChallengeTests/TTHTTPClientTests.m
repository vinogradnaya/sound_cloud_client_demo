//
//  TTHTTPClientTests.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTMockSession.h"
#import "TTHTTPClient.h"

@interface TTHTTPClientTests : XCTestCase
@property (nonatomic, strong) TTMockSession *mockSession;
@property (nonatomic, strong) TTMockDataResponse *mockDataResponse;
@property (nonatomic, strong) TTMockDownloadResponse *mockDownloadResponse;
@property (nonatomic, strong) TTHTTPClient *client;
@end

@implementation TTHTTPClientTests

- (void)setUp {
    [super setUp];
    self.mockSession = [[TTMockSession alloc] init];
    self.mockSession.mockDataResponse = self.mockDataResponse;
    self.mockSession.mockDownloadResponse = self.mockDownloadResponse;
    self.client = [[TTHTTPClient alloc] initWithBaseURL:@"api.soundcloud.com"
                                                session:self.mockSession];
}

- (void)tearDown {
    self.mockSession = nil;
    self.mockDataResponse = nil;
    self.mockDownloadResponse = nil;
    self.client = nil;
    [super tearDown];
}

#pragma mark - Properties

- (TTMockDataResponse *)mockDataResponse
{
    if (_mockDataResponse != nil) {
        return _mockDataResponse;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"username" : @"madonna",
                                                                 @"name" : @"Madonna",
                                                                 @"id" : @"1111"}
                                                       options:0
                                                         error:nil];

    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL new]
                                                          statusCode:200
                                                         HTTPVersion:nil
                                                        headerFields:nil];

    _mockDataResponse = [[TTMockDataResponse alloc] initWithData:jsonData
                                                            response:response
                                                           error:nil];
    return _mockDataResponse;
}

- (TTMockDownloadResponse *)mockDownloadResponse
{
    if (_mockDownloadResponse != nil) {
        return _mockDownloadResponse;
    }

    NSURL *location = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"png"];

    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL new]
                                                          statusCode:200
                                                         HTTPVersion:nil
                                                        headerFields:nil];

    _mockDownloadResponse = [[TTMockDownloadResponse alloc] initWithLocation:location
                                                                    response:response
                                                                       error:nil];
    return _mockDownloadResponse;
}

#pragma mark - Data Tests

- (void)testThatClientCreatesValidURL {
    [self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
        XCTAssertEqualObjects(@"http://api.soundcloud.com/users/3156285?client_id=4010038b2d63e0399b85dc32a64a78f7", [self.mockSession.request.URL absoluteString]);
    }];
}

- (void)testThatClientReturnsValidDataWhenNoError {
    [self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
        XCTAssertEqualObjects(responseObject[@"username"], @"madonna");
    }];
}

- (void)testThatClientCanHandleNilData {
    self.mockDataResponse.data = nil;
    XCTAssertNoThrow([self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
    }]);
}

- (void)testThatClientReportsErrorWhenErrorOccured {
    self.mockDataResponse.error = [NSError new];
    [self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testThatClientReportsErrorWhenStatusCodeMoreThanFourHundred {
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL new]
                                                          statusCode:400
                                                         HTTPVersion:nil
                                                        headerFields:nil];
    self.mockDataResponse.response = response;
    [self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testThatClientDoesNotReturnDataWhenError {
    self.mockDataResponse.error = [NSError new];
    [self.client getDataWithURL:@"users/3156285" parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
        XCTAssertNil(responseObject);
    }];
}

- (void)testThatClientAllowsNilAPIEndpoint {
    XCTAssertNoThrow([self.client getDataWithURL:nil parameters:@{@"client_id" : @"4010038b2d63e0399b85dc32a64a78f7"} completion:^(id responseObject, NSError *error) {
    }]);
}

- (void)testThatClientAllowsNilParameters {
    XCTAssertNoThrow([self.client getDataWithURL:@"users/3156285" parameters:nil completion:^(id responseObject, NSError *error) {
    }]);
}

- (void)testThatClientAllowsNilCompletion {
    XCTAssertNoThrow([self.client getDataWithURL:@"users/3156285" parameters:nil completion:nil]);
}

#pragma mark - Download Tests

- (void)testThatClientReturnsDownloadDataWhenNoError {
    [self.client dowloadDataWithURL:@"http://www.dube.com/balls/images/ManipulationBall_Red.jpg" completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(downloadedData);
    }];
}

- (void)testThatClientReturnsDownloadErrorWhenNoURLPassed {
    [self.client dowloadDataWithURL:nil completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testThatClientReturnsDownloadErrorWhenWrongURLPassed {
    [self.client dowloadDataWithURL:@"wrong url" completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testThatClientReturnsDownloadErrorWhenErrorOccured {
    self.mockDownloadResponse.error = [NSError new];
    [self.client dowloadDataWithURL:nil completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testThatClientReturnsDownloadResponse {
    [self.client dowloadDataWithURL:@"http://www.dube.com/balls/images/ManipulationBall_Red.jpg" completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(response);
    }];
}

- (void)testThatClientReturnsDownloadTask {
    NSURLSessionDownloadTask *task = [self.client dowloadDataWithURL:@"http://www.dube.com/balls/images/ManipulationBall_Red.jpg" completion:^(NSData *downloadedData, NSURLResponse *response, NSError *error) {
    }];

    XCTAssertNotNil(task);
}

- (void)testThatClientAllowsNilDownloadCompletion {
    XCTAssertNoThrow([self.client dowloadDataWithURL:@"http://www.dube.com/balls/images/ManipulationBall_Red.jpg" completion:nil]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
