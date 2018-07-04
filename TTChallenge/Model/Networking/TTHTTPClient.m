//
//  TTHTTPClient.m
//  TTChallenge
//
//  Created by keksiy on 06.10.15.
//  Copyright (c) 2015 vinogradnaya. All rights reserved.
//

#import "TTHTTPClient.h"
#import "TTDefines.h"
#import "TTConstants.h"

@interface TTHTTPClient ()
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation TTHTTPClient

#pragma mark - Initialization

- (instancetype)init
{
    return [self initWithBaseURL:nil session:nil];
}

- (instancetype)initWithBaseURL:(NSString *)baseURL session:(NSURLSession *)session
{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.session = (session != nil)? session : [self createSession];
    }
    return self;
}

#pragma mark - Data Loading

- (void)getDataWithURL:(NSString *)urlString
            parameters:(NSDictionary *)parameters
            completion:(TTHTTPClientGetCompletion)completion
{
    NSMutableURLRequest *request = [self requestWithURL:urlString
                                             httpMethod:@"GET"
                                             parameters:parameters];
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request
                                                    completion:completion];
    [dataTask resume];
}

#pragma mark - NSURLSession Tasks Creation

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                completion:(TTHTTPClientGetCompletion)completion
{
    NSURLSessionDataTask *dataTask =
    [self.session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error) {
                            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
                            NSError *jsonError = nil;
                            if (httpResp.statusCode == 200) {
                                NSDictionary *responseJSON = nil;
                                if (data != nil) {
                                    responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&jsonError];

                                }
                                if (completion != nil) {
                                    completion(responseJSON, jsonError);
                                }
                            } else if (httpResp.statusCode > 200 && httpResp.statusCode < 300) {
                                if (completion != nil) {
                                    completion(nil, nil);
                                }
                            } else {
                                NSMutableDictionary* errorDetails = [NSMutableDictionary new];

                                NSString *errorDescription =
                                [NSString stringWithFormat:@"%@ returned status code %d", request.URL, (int)httpResp.statusCode];
                                
                                [errorDetails setValue:errorDescription
                                                forKey:NSLocalizedDescriptionKey];
                
                                NSDictionary* jsonFailureReason =
                                [NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:&jsonError];
                
                                if (jsonFailureReason != nil) {
                                    NSString *failureReasonCode =
                                    [jsonFailureReason objectForKey:@"ErrorCode"];
                                    if (failureReasonCode != nil) {
                                        [errorDetails setValue:failureReasonCode
                                                        forKey:NSLocalizedFailureReasonErrorKey];
                                    }
                                }
                
                                NSError *responseError =
                                [NSError errorWithDomain:TTHTTPErrorDomain
                                                    code:(int)httpResp.statusCode
                                                userInfo:errorDetails];
                
                                if (completion != nil) {
                                    completion(nil, responseError);
                                }
                            }
                        } else {
                            if (completion != nil) {
                                completion(nil, error);
                            }
                        }
                    }];
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)dowloadDataWithURL:(NSString *)urlString
                                      completion:(TTHTTPClientDownloadCompletion)completion
{
    if (urlString == nil) {
        if (completion) {
            NSError *error = [[NSError alloc] initWithDomain:TTHTTPErrorDomain
                                                        code:TTErrorCodeWrongInputError
                                                    userInfo:@{@"message" : @"URL String can not be nil"}];
            completion (nil, nil, error);
        }
        return nil;
    }

    NSURL *url = [NSURL URLWithString:urlString];

    if (url == nil) {
        if (completion) {
            NSError *error = [[NSError alloc] initWithDomain:TTHTTPErrorDomain
                                                        code:TTErrorCodeWrongInputError
                                                    userInfo:@{@"message" : @"invalid URL String"}];
            completion (nil, nil, error);
        }
        return nil;
    }

    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *downloadedData = nil;
        if (!error) {
            downloadedData = [NSData dataWithContentsOfURL:location];
        }

        if (completion) {
            completion (downloadedData, response, error);
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}


#pragma mark - NSURLRequest Creation

- (NSMutableURLRequest *)requestWithURL:(NSString *)urlString
                             httpMethod:(NSString *)httpMethod
                             parameters:(NSDictionary *)parameters
{
    NSMutableString *finalURLString =
    [NSMutableString stringWithFormat:@"%@://%@/%@", @"http", self.baseURL, urlString];
    
    NSURL *requestURL = nil;
    
    if ([parameters count] > 0) {
        NSString *stringFromParams = [self queryStringFromParameters:parameters];
        finalURLString = [NSMutableString stringWithFormat:@"%@%@", finalURLString, stringFromParams];
    }

    TTLog(@"Request URL: %@", finalURLString);

    requestURL = [NSURL URLWithString:finalURLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    
    [request setHTTPMethod:httpMethod];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

#pragma mark - Session Creation

- (NSURLSession *)createSession
{
    NSURLSessionConfiguration *configuration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue new]];
    return session;
}

#pragma mark - Utils

- (NSString *)queryStringFromParameters:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [NSMutableString new];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}

- (NSString *)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

@end
