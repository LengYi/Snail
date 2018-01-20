//
//  HTTPResponseHeader.m
//  Snail
//
//  Created by lemon4ex on 16/6/5.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "HTTPResponseHeader.h"
#import "NSData-SGUtils.h"

@implementation HTTPResponseHeader


- (id)initWithData:(NSData *)arg1 {
    if (self = [super init]) {
        _headerLength = arg1.length;
        _rawResponseData = arg1;
        NSData *clcrData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArray = [_rawResponseData componentsSeparatedByData:clcrData];
        
        if (!dataArray.count) {
            NSLog(@"Parse data failed, try LF separator");
            dataArray = [_rawResponseData componentsSeparatedByData:[@"\r" dataUsingEncoding:NSUTF8StringEncoding]];
            if (!dataArray.count) {
                NSLog(@"Unable to parse header: %@",[_rawResponseData base64EncodedDataWithOptions:0]);
                return nil;
            }
        }
        
        NSString *line = [dataArray[0] stringValue];
        NSArray *lineArray = [line componentsSeparatedByString:@" "];
        if (lineArray.count > 1) {
            if([[lineArray[0] uppercaseString] rangeOfString:@"HTTP/1.1"].location == NSNotFound)
            {
                if ([[lineArray[0] uppercaseString] rangeOfString:@"HTTP/1.0"].location == NSNotFound) {
                    NSLog(@"Unknown http version: %@",lineArray[0]);
                    return nil;
                }
                else
                    _httpVerison = @"1.0";
            }
            else
            {
                _httpVerison = @"1.1";
            }
            
            _statusCode = [lineArray[1] integerValue];
        }
        
        if (dataArray.count > 2) {
            for (NSInteger i = 1; i < dataArray.count; i++) {
                NSString *line = [[NSString alloc]initWithData:dataArray[i] encoding:NSUTF8StringEncoding];
                NSRange range = [line rangeOfString:@":"];
                if (range.location != NSNotFound) {
                    NSString *name = [line substringToIndex:range.location];
                    NSString *value = [line substringFromIndex:range.location + 1];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                    if ([[name lowercaseString]isEqualToString:@"content-length"]) {
                        _responseContentLength = [value longLongValue];
                    }
                    else if ([[name lowercaseString]isEqualToString:@"transfer-encoding"])
                    {
                        if ([[value lowercaseString] isEqualToString:@"chunked"]) {
                            _chunkedTransferEncoding = YES;
                        }
                    }
                    else if ([[name lowercaseString]isEqualToString:@"connection"])
                    {
                        _connection = [value lowercaseString];
                    }
                }
            }
        }
    }
    
    return self;
}


@end
