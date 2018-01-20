//
//  DLHttp.m
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import "DLHttp.h"

@implementation DLHttp

+ (void)synWithGetURLString:(NSString *)urlStr
            withHeaderField:(NSDictionary *)headerFieldDict
        withTimeoutInterval:(NSTimeInterval)timeoutInterval
               shouldEncode:(BOOL)shouldEncode
          completionHandler:(DLHttpCompletionHandler)handler{
    if (!urlStr) {
        urlStr = @"";
    }
    
    NSURL *url = nil;
    if (shouldEncode) {
        url = [self encodeURLWithString:urlStr];
    } else {
        url = [NSURL URLWithString:urlStr];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    if (headerFieldDict) {
        NSArray *keys = [headerFieldDict allKeys];
        for (NSString *key in keys) {
            [request setValue:[headerFieldDict valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (timeoutInterval > 0) {
        request.timeoutInterval = timeoutInterval;
    }
    
    NSURLResponse *urlResponce = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponce error:&error];
    
    if (!handler) {
        return;
    }
    
    if(error){
#ifdef DEBUG
        NSLog(@"error:\n%@",error);
#endif
        error = [NSError errorWithDomain:@"DLHttpErrorDomian"
                                    code:error.code
                                userInfo:error.userInfo];
        
    }
    
    if (handler) {
        handler(data, error, (NSHTTPURLResponse *)urlResponce);
    }
}

+ (void)asynWithGetURLString:(NSString *)urlStr
             withHeaderField:(NSDictionary *)headerFieldDict
         withTimeoutInterval:(NSTimeInterval)timeoutInterval
              withForeground:(BOOL)foreground
                shouldEncode:(BOOL)shouldEncode
           completionHandler:(DLHttpCompletionHandler)handler{
    if (!urlStr) {
        urlStr = @"";
    }
    
    NSURL *url = nil;
    if (shouldEncode) {
        url = [self encodeURLWithString:urlStr];
    } else {
        url = [NSURL URLWithString:urlStr];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    if (headerFieldDict) {
        NSArray *keys = [headerFieldDict allKeys];
        for (NSString *key in keys) {
            [request setValue:[headerFieldDict valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (timeoutInterval > 0) {
        request.timeoutInterval = timeoutInterval;
    }
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *urlResponce,
                                               NSData *data,
                                               NSError *error)
     {
         if (!handler) {
             return;
         }
         
         if(error){
#ifdef DEBUG
             NSLog(@"error:\n%@",error);
#endif
             error = [NSError errorWithDomain:@"DLHttpErrorDomian"
                                         code:error.code
                                     userInfo:error.userInfo];
             
         }
         
         if (foreground){
             dispatch_async(dispatch_get_main_queue(), ^{
                 handler(data, error, (NSHTTPURLResponse *)urlResponce);
             });
         }
         else{
             handler(data, error, (NSHTTPURLResponse *)urlResponce);
         }
     }];
}

+ (void)synWithPostURLString:(NSString *)urlStr
                    withData:(NSData *)postData
             withHeaderField:(NSDictionary *)headerFieldDict
         withTimeoutInterval:(NSTimeInterval)timeoutInterval
              withForeground:(BOOL)foreground
             shouldURLEncode:(BOOL)shouldEncode
           completionHandler:(DLHttpCompletionHandler)handler{
    if (!urlStr) {
        urlStr = @"";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url = nil;
    if (shouldEncode) {
        url = [self encodeURLWithString:urlStr];
    } else {
        url = [NSURL URLWithString:urlStr];
    }
    
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]]
   forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    if (headerFieldDict) {
        NSArray *keys = [headerFieldDict allKeys];
        for (NSString *key in keys) {
            [request setValue:[headerFieldDict valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (request.timeoutInterval > 0) {
        request.timeoutInterval = timeoutInterval;
    }
    
    NSURLResponse *urlResponce = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponce error:&error];
    
    if (!handler) {
        return;
    }
    
    if(error){
#ifdef DEBUG
        NSLog(@"error:\n%@",error);
#endif
        error = [NSError errorWithDomain:@"DLHttpErrorDomian"
                                    code:error.code
                                userInfo:error.userInfo];
        
    }
    
    if (foreground) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data, error, (NSHTTPURLResponse *)urlResponce);
        });
    }else{
        handler(data,error,(NSHTTPURLResponse *)urlResponce);
    }
}


+ (void)asynWithPostURLString:(NSString *)urlStr
                     withData:(NSData *)postData
              withHeaderField:(NSDictionary *)headerFieldDict
          withTimeoutInterval:(NSTimeInterval)timeoutInterval
               withForeground:(BOOL)foreground
              shouldUrlEncode:(BOOL)shouldEncode
            completionHandler:(DLHttpCompletionHandler)handler{
    if (!urlStr) {
        urlStr = @"";
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url = [NSURL URLWithString:urlStr];
    if (shouldEncode) {
        url = [self encodeURLWithString:urlStr];
    }
    
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    if (headerFieldDict) {
        NSArray *keys = [headerFieldDict allKeys];
        for (NSString *key in keys) {
            [request setValue:[headerFieldDict valueForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (timeoutInterval > 0) {
        request.timeoutInterval = timeoutInterval;
    }
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *urlResponce,
                                               NSData *data,
                                               NSError *error)
     {
         
         if (!handler) {
             return;
         }
         
         if(error){
#ifdef DEBUG
             NSLog(@"error:\n%@",error);
#endif
             error = [NSError errorWithDomain:@"DLHttpErrorDomian"
                                         code:error.code
                                     userInfo:error.userInfo];
             
         }
         if (foreground){
             dispatch_async(dispatch_get_main_queue(), ^{
                 handler(data, error, (NSHTTPURLResponse *)urlResponce);
             });
         }
         else{
             handler(data, error, (NSHTTPURLResponse *)urlResponce);
         }
     }];
}

+ (NSURL *)encodeURLWithString:(NSString *)string{
    NSURL *url = [NSURL URLWithString:string];
    if(url != nil){
        CFStringRef originalString = (__bridge CFStringRef)string;
        CFStringRef charactersToLeaveUnescaped = NULL;
        CFStringRef legalURLCharactersToBeEscaped = (CFStringRef)@"!*'();@&=+$,#[]";
        CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        
        CFStringRef createString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, charactersToLeaveUnescaped, legalURLCharactersToBeEscaped, encoding);
        
        NSString *newString = (__bridge NSString *)createString;
        
        if (newString)
        {
            url = [NSURL URLWithString:newString];
            CFRelease(createString);
        }
    }
    
    return url;
}


@end
