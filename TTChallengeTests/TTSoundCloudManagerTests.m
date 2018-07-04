//
//  TTSoundCloudManagerTests.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTUser.h"
#import "TTSoundCloudManager.h"
#import "TTSoundCloudManager+TTTests.h"
#import "TTMockObserver.h"
#import "TTStubReachability.h"
#import "TTStubHTTPClient.h"
#import "TTStubUserBuilder.h"

@interface TTSoundCloudManagerTests : XCTestCase
@property (nonatomic, strong) TTUser *user;
@property (nonatomic, strong) TTSoundCloudManager *manager;
@property (nonatomic, strong) TTMockObserver *observer;
@property (nonatomic, strong) TTStubReachability *reachability;
@property (nonatomic, strong) TTStubHTTPClient *client;
@property (nonatomic, strong) TTStubUserBuilder *builder;
@end

@implementation TTSoundCloudManagerTests

- (void)setUp {
    [super setUp];
    self.user = [self createUser];
    self.client = [TTStubHTTPClient new];
    self.reachability = [TTStubReachability new];
    self.reachability.mockIsReachable = YES;
    self.builder = [TTStubUserBuilder new];
    self.observer = [TTMockObserver new];
    self.manager = [[TTSoundCloudManager alloc] initWithAPIClient:self.client
                                                     reachability:self.reachability
                                                          builder:self.builder];
    [self.manager addObserver:self.observer];
    // observer if added asyncronously, so we need to make a timeout
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

- (TTUser *)createUser
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles: nil];
    NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
    [ctx setPersistentStoreCoordinator: coord];
    TTUser *user = [[TTUser alloc] initWithEntity:[NSEntityDescription entityForName:@"TTUser" inManagedObjectContext:ctx] insertIntoManagedObjectContext:ctx];
    return user;
}

- (void)tearDown {
    self.user = nil;
    self.client = nil;
    self.reachability = nil;
    self.builder = nil;
    self.manager = nil;
    self.observer = nil;
    [super tearDown];
}

- (void)testNetworkIsNotCalledWhenCacheExists
{
    self.builder.user = self.user;
    [self.manager fetchDataIfNeeded];
    XCTAssertFalse(self.client.didCallNetwork, @"should not call network if there is data in cache");
}

- (void)testNetworkCalledWhenNoCache
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    [self.manager fetchDataIfNeeded];
    XCTAssertTrue(self.client.didCallNetwork, @"should call network if there is no data in cache");
}

- (void)testNotifyObserverWhenReceivedData
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    XCTAssertTrue(self.reachability.mockIsReachable, @"network should be reachable");
    TTSoundCloudManager *manager = self.manager;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    __weak typeof(self)weakSelf = self;
    manager.fetchCompletion = ^void(id responseObject, NSError *error) {
        [expectation fulfill];
        XCTAssertTrue(weakSelf.observer.didNotifyObserver, @"should notify observer when data received");
    };
    [manager fetchDataIfNeeded];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testNotifyObserverWhenErrorOccuredWhileFetchingUser
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    XCTAssertTrue(self.reachability.mockIsReachable, @"network should be reachable");
    self.client.fetchUserError = [NSError new];
    TTSoundCloudManager *manager = self.manager;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    __weak typeof(self)weakSelf = self;
    manager.fetchCompletion = ^void(id responseObject, NSError *error) {
        [expectation fulfill];
        XCTAssertNotNil(weakSelf.observer.error, @"should notify observer about error");
    };
    [manager fetchDataIfNeeded];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testNotifyObserverWhenErrorOccuredWhileFetchingTracks
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    XCTAssertTrue(self.reachability.mockIsReachable, @"network should be reachable");
    self.client.fetchTracksError = [NSError new];
    TTSoundCloudManager *manager = self.manager;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    __weak typeof(self) weakSelf = self;
    manager.fetchCompletion = ^void(id responseObject, NSError *error) {
        [expectation fulfill];
        XCTAssertNotNil(weakSelf.observer.error, @"should notify observer about error");
    };
    [manager fetchDataIfNeeded];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testNotifyObserverWhenErrorOccuredParsingUser
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    XCTAssertTrue(self.reachability.mockIsReachable, @"network should be reachable");
    self.builder.addingUserError = [NSError new];
    TTSoundCloudManager *manager = self.manager;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    __weak typeof(self) weakSelf = self;
    manager.fetchCompletion = ^void(id responseObject, NSError *error) {
        [expectation fulfill];
        XCTAssertNotNil(weakSelf.observer.error, @"should notify observer about error");
    };
    [manager fetchDataIfNeeded];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}

- (void)testNotifyObserverWhenErrorOccuredParsingTracks
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    XCTAssertTrue(self.reachability.mockIsReachable, @"network should be reachable");
    self.builder.addingTracksError = [NSError new];
    TTSoundCloudManager *manager = self.manager;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    __weak typeof(self) weakSelf = self;
    manager.fetchCompletion = ^void(id responseObject, NSError *error) {
        [expectation fulfill];
        XCTAssertNotNil(weakSelf.observer.error, @"should notify observer about error");
    };
    [manager fetchDataIfNeeded];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testNotifyObserverWhenNetworkNotReachable
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    self.reachability.mockIsReachable = NO;
    [self.manager fetchDataIfNeeded];
    XCTAssertTrue(self.observer.didNotifyObserver, @"should notify observer when no network");
}

- (void)testDoesNotCallNetworkWhenNotReachable
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    self.reachability.mockIsReachable = NO;
    [self.manager fetchDataIfNeeded];
    XCTAssertFalse(self.client.didCallNetwork, @"should not call network when there is no connection");
}

- (void)testStartsWaitingForNetworkIfNotReachable
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    self.reachability.mockIsReachable = NO;
    [self.manager fetchDataIfNeeded];
    XCTAssertTrue(self.reachability.didCallStartMonitoring, @"should start monitoring if no network");
}

- (void)testReloadsDataIfFailedDueToNetworkAbsence
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    self.reachability.mockIsReachable = NO;
    [self.manager fetchDataIfNeeded];
    self.reachability.mockIsReachable = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTReachabilityChangedNotification object:@(TTNetworkStatusReachableViaWiFi)];
    XCTAssertTrue(self.client.didCallNetwork, @"should start monitoring if no network");
}

- (void)testStopsReachabilityMonitoring
{
    XCTAssertNil(self.builder.user, @"cache should be empty");
    self.reachability.mockIsReachable = NO;
    [self.manager fetchDataIfNeeded];
    self.reachability.mockIsReachable = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTReachabilityChangedNotification object:@(TTNetworkStatusReachableViaWiFi)];
    XCTAssertTrue(self.reachability.didCallStopMonitoring, @"should stop monitoring");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
