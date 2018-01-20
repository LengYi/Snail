//
//  DLHttp.h
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DLHttpCompletionHandler)(NSData *data, NSError *error, NSHTTPURLResponse * response);

@interface DLHttp : NSObject

// 待测试
+ (void)synWithGetURLString:(NSString *)urlStr
            withHeaderField:(NSDictionary *)headerFieldDict
        withTimeoutInterval:(NSTimeInterval)timeoutInterval
               shouldEncode:(BOOL)shouldEncode
          completionHandler:(DLHttpCompletionHandler)handler;

+ (void)asynWithGetURLString:(NSString *)urlStr
             withHeaderField:(NSDictionary *)headerFieldDict
         withTimeoutInterval:(NSTimeInterval)timeoutInterval
              withForeground:(BOOL)foreground
                shouldEncode:(BOOL)shouldEncode
           completionHandler:(DLHttpCompletionHandler)handler;

+ (void)synWithPostURLString:(NSString *)urlStr
                    withData:(NSData *)postData
             withHeaderField:(NSDictionary *)headerFieldDict
         withTimeoutInterval:(NSTimeInterval)timeoutInterval
              withForeground:(BOOL)foreground
             shouldURLEncode:(BOOL)shouldEncode
           completionHandler:(DLHttpCompletionHandler)handler;

+ (void)asynWithPostURLString:(NSString *)urlStr
                     withData:(NSData *)postData
              withHeaderField:(NSDictionary *)headerFieldDict
          withTimeoutInterval:(NSTimeInterval)timeoutInterval
               withForeground:(BOOL)foreground
              shouldUrlEncode:(BOOL)shouldEncode
            completionHandler:(DLHttpCompletionHandler)handler;

@end
