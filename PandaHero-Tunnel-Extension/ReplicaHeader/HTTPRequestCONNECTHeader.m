//
//  HTTPRequestCONNECTHeader.m
//  Snail
//
//  Created by lemon4ex on 16/6/4.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "HTTPRequestCONNECTHeader.h"

@implementation HTTPRequestCONNECTHeader


- (id)initWithGroupedData:(NSArray *)arg1 rawData:(NSData *)arg2 {
    if (self = [super init]) {
        _rawRequestData = arg2;
        NSString *line = [[NSString alloc]initWithData:arg1[0] encoding:NSUTF8StringEncoding];
        if (!line) {
            NSLog(@"Header UTF-8 decoding failed, fallback to ASCII");
            line = [[NSString alloc]initWithData:arg1[0] encoding:NSASCIIStringEncoding];
            if (!line) {
                NSLog(@"Unable to parse header start line: %@",[arg1[0] base64EncodedDataWithOptions:0]);
            }
        }
        
        NSArray *arr = [line componentsSeparatedByString:@" "];
        if (arr.count > 1) {
            _host = arr[1];
        }
        else
        {
            NSLog(@"Unknown CONNECT line: %@",line);
        }
    }
    
    return self;
}


@end