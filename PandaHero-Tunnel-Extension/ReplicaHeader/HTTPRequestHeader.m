//
//  HTTPRequestHeader.m
//  Snail
//
//  Created by lemon4ex on 16/6/4.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "HTTPRequestHeader.h"
#import "NSData-SGUtils.h"
#import "HTTPRequestCONNECTHeader.h"

static NSSet *dword_5C38C;

@implementation HTTPRequestHeader


- (id)initWithData:(NSData *)arg1 {
    if (self = [super init]) {
        _rawRequestData = arg1;
        NSData *lrcl = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *da = [arg1 componentsSeparatedByData:lrcl];
        
        if (!da.count) {
            NSLog(@"Parse data failed, try LF separator");
            da = [arg1 componentsSeparatedByData:[@"\r" dataUsingEncoding:NSUTF8StringEncoding]];
            if (!da.count) {
                NSLog(@"Unable to parse header: %@",[arg1 base64EncodedDataWithOptions:0]);
                return nil;
            }
        }
        
        NSString *line = [da[0] stringValue];
        if ([line hasPrefix:@"CONNECT"]) {
            return [[HTTPRequestCONNECTHeader alloc]initWithGroupedData:da rawData:arg1];
        }
        
        _HTTPMethod = [[line componentsSeparatedByString:@" "][0] uppercaseString];
        _URL = [line componentsSeparatedByString:@" "][1];
        if ([[_URL lowercaseString]hasPrefix:@"http://"]) {
            NSInteger httpLen = [@"http://" length];
            NSRange rangEnd = [_URL rangeOfString:@"/" options:0 range:NSMakeRange(httpLen, _URL.length - httpLen)];
            if (!rangEnd.length) {
                _host = [_URL substringFromIndex:httpLen];
                _path = @"/";
            }
            else
            {
                _host = [_URL substringWithRange:NSMakeRange(httpLen, rangEnd.location)];
                _path = [_URL substringToIndex:rangEnd.location];
            }
        }
        
        NSMutableData *data = [NSMutableData dataWithCapacity:arg1.length];
        line = [NSString stringWithFormat:@"%@ %@ HTTP/1.1\r\n", _HTTPMethod,_URL];
        NSData *tdata = [line dataUsingEncoding:NSUTF8StringEncoding];
        if (!tdata) {
            NSLog(@"Create header with UTF-8 encoding failed, fallback to ASCII");
            tdata = [line dataUsingEncoding:NSASCIIStringEncoding];
            if (!tdata) {
                NSLog(@"Unable to create start line data: %@",arg1);
                tdata = nil;
            }
        }
        
        [data appendData:tdata];
        
        // 请求头只有一行的情况
        if (da.count < 2) {
            [data appendData:[[NSString stringWithFormat:@"HOST: %@\r\n\r\n",_host] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            for (NSData *lineData in da) {
                line = [[NSString alloc]initWithData:lineData encoding:NSUTF8StringEncoding];
                
                if (!line) {
                    [data appendData:lineData];
                    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                else
                {
                    NSRange range = [line rangeOfString:@": "];
                    if (!range.length) {
                        [data appendData:lineData];
                        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    else
                    {
                        NSString *name = [line substringToIndex:range.location];
                        NSString *value = [line substringFromIndex:range.location + 2];
                        if ([[name lowercaseString] isEqualToString: @"connection"]) {
                            _connectionKeepAlive = [value isEqualToString:@"keep-alive"];
                        }
                        if ([[name lowercaseString]isEqualToString:@"host"]) {
                            if (![dword_5C38C containsObject:name]) {
                                [data appendData:lineData];
                                [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                            }
                        }
                    }
                }
            }
            [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return self;
}

+ (void)load {
    NSString *name[1] = {@"proxy-connection"};
    dword_5C38C = [NSSet setWithArray:[NSArray arrayWithObjects:name count:1]];
    
}


@end