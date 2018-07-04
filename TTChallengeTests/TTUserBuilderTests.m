//
//  TTUserBuilderTests.m
//  TTChallenge
//
//  Created by keksiy on 10.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TTUserBuilder.h"
#import "TTMockCoreDataManager.h"
#import "TTUser.h"

@interface TTUserBuilderTests : XCTestCase
@property (nonatomic, strong) TTUserBuilder *builder;
@property (nonatomic, strong) TTMockCoreDataManager *mockCoreDataManager;
@end

@implementation TTUserBuilderTests

- (void)setUp {
    [super setUp];
    TTUser *user = [self createUser];
    self.mockCoreDataManager = [TTMockCoreDataManager new];
    self.mockCoreDataManager.user = user;
    self.mockCoreDataManager.tracks = nil;
    self.builder = [[TTUserBuilder alloc] initWithCoreDataManager:self.mockCoreDataManager];
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
    self.builder = nil;
    self.mockCoreDataManager = nil;
    [super tearDown];
}

- (void)testAddingReceivedUserDataUsedDuringBuild
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    TTUserBuilder *builder = self.builder;
    __weak typeof(self) weakSelf = self;
    [builder addUserDataFromDictionary:@{@"id" : @1111,
                                              @"username" : @"username"} completion:^(NSError *error) {
                                                  [expectation fulfill];
                                                  TTUser *user = [weakSelf.builder buildWithError:nil];
                                                  XCTAssertEqualObjects(user.username, @"username", @"should pass username");
                                                  XCTAssertEqualObjects(user.scID, @1111, @"should pass id");
                                              }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testAddingReceivedTracksDataUsedDuringBuild
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    TTUserBuilder *builder = self.builder;
    __weak typeof(self) weakSelf = self;

    [builder addFavoriteTracksDataFromArray:@[@{@"id" : @1111}, @{@"id" : @2222}]
                                 completion:^(NSError *error) {
                                     [expectation fulfill];
                                     [weakSelf.builder buildWithError:nil];
                                     XCTAssertEqual([weakSelf.mockCoreDataManager.tracks count], 2, @"should now have equal number of objects");
                                 }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testAddingNoDataReturnsCachedData
{
    self.mockCoreDataManager.user.username = @"madonna";
    self.mockCoreDataManager.tracks = @[[NSObject new], [NSObject new]];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    TTUser *user = [self.builder buildWithError:nil];
    XCTAssertEqualObjects(user.username, @"madonna", @"should pass cached username");
    XCTAssertEqual([self.mockCoreDataManager.tracks count], 2, @"should not override cache");
}

- (void)testAddingNewTracksDataOverridesCachedData
{
    self.mockCoreDataManager.tracks = @[[NSObject new], [NSObject new], [NSObject new], [NSObject new]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    TTUserBuilder *builder = self.builder;
    __weak typeof(self) weakSelf = self;

    [builder addFavoriteTracksDataFromArray:@[@{@"id" : @1111}, @{@"id" : @2222}] completion:^(NSError *error) {
        [expectation fulfill];
        [weakSelf.builder buildWithError:nil];
        XCTAssertEqual([weakSelf.mockCoreDataManager.tracks count], 2, @"should override cache");
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testAddingNewUserDataOverridesCachedData
{
    self.mockCoreDataManager.user.username = @"madonna";

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];

    TTUserBuilder *builder = self.builder;
    __weak typeof(self) weakSelf = self;

    [builder addUserDataFromDictionary:@{@"id" : @1111,
                                              @"username" : @"username"} completion:^(NSError *error) {
                                                  [expectation fulfill];
                                                  TTUser *user = [weakSelf.builder buildWithError:nil];
                                                  XCTAssertEqualObjects(user.username, @"username", @"should pass new username");
                                              }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
