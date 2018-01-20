//
//  HTTPProxyServer.m
//  Tomato
//
//  Created by lemon4ex on 16/9/18.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "HTTPProxyServer.h"
#import <GCDAsyncSocket.h>
#import "ProxyConnection.h"

@interface HTTPProxyServer ()<GCDAsyncSocketDelegate,ProxyConnectionDelegate>
{
    GCDAsyncSocket *_socket;
    NSMutableArray *_connections;
    dispatch_queue_t _queue;
}

@end

@implementation HTTPProxyServer

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("HTTPProxyServer", NULL);
        _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:_queue];
        _connections = [NSMutableArray array];
    }
    
    return self;
}

- (void)start {
    NSError *error;
    if ([_socket acceptOnInterface:@"127.0.0.1" port:6538 error:&error]) {
        DDLogInfo(@"HTTP proxy server start listen at 127.0.0.1:6538");
    }
    else
    {
        DDLogError(@"HTTP proxy server start error:%@",error.localizedDescription);
    }
}

- (void)stop {
    [_socket disconnect];
}

- (void)doAsyncProxy:(ProxyConnection *)connection message:(HTTPMessage *)message
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[message url]];
    request.timeoutInterval = 30;
    NSDictionary *headerFieldDict = [message allHeaderFields];
    for (NSString *key in headerFieldDict.allKeys) {
        [request setValue:[headerFieldDict valueForKey:key] forHTTPHeaderField:key];
    }
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
        HTTPMessage *resMessage = [[HTTPMessage alloc]initResponseWithStatusCode:httpRes.statusCode description:[NSHTTPURLResponse localizedStringForStatusCode:httpRes.statusCode] version:HTTPVersion1_1];
        NSDictionary *fields = httpRes.allHeaderFields;
        for (NSString *key in fields.allKeys) {
            [resMessage setHeaderField:key value:fields[key]];
        }
        resMessage.body = data;
        DDLogInfo(@"Write apple http message, %@",[[NSString alloc]initWithData:resMessage.messageData encoding:NSUTF8StringEncoding]);
        [connection writeHTTPMessage:resMessage];
    }];
    [task resume];
}

- (void)doFakeHTTP:(ProxyConnection *)connection
{
    DDLogInfo(@"Write fake http message");
    HTTPMessage *message = [[HTTPMessage alloc]initResponseWithStatusCode:500 description:[NSHTTPURLResponse localizedStringForStatusCode:500] version:HTTPVersion1_1];
    message.body = [@"HTTP/1.1 500 - Internal Server Error" dataUsingEncoding:NSUTF8StringEncoding];
    [connection writeHTTPMessage:message];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    DDLogDebug(@"Accept new socket %@",newSocket);
    ProxyConnection *connection = [[ProxyConnection alloc]initWithLocalSocket:newSocket];
    connection.delegate = self;
    [_connections addObject:connection];
    [connection readHTTPMessage];
}

#pragma mark - ProxyConnectionDelegate
- (void)didReadHTTPMessage:(ProxyConnection *)connection message:(HTTPMessage *)message
{
//    [self doFakeHTTP:connection];
//    return;
    
    dispatch_async(_queue, ^{
        NSString *url = [message url].absoluteString;
        url = [url stringByRemovingPercentEncoding];
        NSRange range = [url rangeOfString:@"ME4wTKADAgEAMEUwQzBBMAkGBSsOAwIaBQAEFADrDMz0cWy6RiOj1S+Y1D32MKkdBBSIJxcJqbYYYIvs67r2R1nFUlSjtwII"];
        if (range.location != NSNotFound) {
            NSString *base64SN = [url substringFromIndex:range.length + range.location];
            DDLogInfo(@"Find oscp get string, cer's sn is %@",base64SN);
            // 请求服务器，判断是否拦截
            NSData *snData = [[NSData alloc]initWithBase64EncodedString:base64SN options:0];
            const char *bytes = snData.bytes;
            NSMutableString *snString = [NSMutableString string];
            for (NSUInteger i = 0 ; i < snData.length; ++i) {
                [snString appendFormat:@"%02hhx",bytes[i]];
            }
            
            NSNumber *num = [self numberHexString:snString];
            NSString *str = [NSString stringWithFormat:@"%lld",[num longLongValue]];
            
#if DEBUG  // 测试证书过期
            if ([@"5730544896317924461" isEqualToString:str]) {
                DDLogInfo(@"原始id %@",str);
                str = @"2193643471350179391";
                DDLogInfo(@"测试id %@",str);
            }
#endif
            NSString *serverUrl = [NSString stringWithFormat:@"http://anti.bitawful.com/v/wxcert.ashx?cert&certid=%@",str];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:serverUrl]];
            request.timeoutInterval = 30;
            DDLogInfo(@"Server request url %@",serverUrl);
            
            NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
                
                // 默认全防护检测到不在服务器目录则不防护
                if (!error) {
                    if (data) {
                        NSError *error;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if (dict) {
                            NSString *value = dict[@"Data"];
                            if (value) {
                                if ([dict[@"Data"] isEqualToString:@"ilegal"]) // ok 证书正常,out 证书无效,ilegal 非公司证书
                                {
                                    [self doAsyncProxy:connection message:message];
                                    return;
                                }
                            }
                        }
                    }
                }
 
                
//                do {
//                    DDLogInfo(@"Server request response %@, data %@, error %@",response,data,error.localizedDescription);
//                    if (httpRes.statusCode != 200 || !data) [self doFakeHTTP:connection];
//                    NSError *error;
//                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                    DDLogInfo(@"Server say %@",dict);
//                    if (!dict)
//                    {
//                        DDLogError(@"NSJSONSerialization error, %@",error.localizedDescription);
//                        [self doFakeHTTP:connection];
//                        break;
//                    }
//                    // 非公司证书不守护
//                    if ([dict[@"Data"] isEqualToString:@"ilegal"]) // ok 证书正常,out 证书无效,ilegal 非公司证书
//                    {
//                        break;
//                    }
//
//                    [self doFakeHTTP:connection];
//                    return;
//                } while (0);
                
                 [self doFakeHTTP:connection];
            }];
            [task resume];
        }
        else
        {
            range = [url rangeOfString:@"http://ocsp.apple.com"];
            if (range.location != NSNotFound) {// 同步推拦截
                [self doFakeHTTP:connection];
            }else{
                DDLogInfo(@"Not find oscp get string");
                [self doAsyncProxy:connection message:message];
            }
        }
    });
}

- (void)connectionDidDisconnect:(ProxyConnection *)connection withError:(NSError *)err
{
    dispatch_async(_queue, ^{
        [_connections removeObject:connection];
        DDLogDebug(@"Connection %@ is removed from connections",connection);
    });
}


- (NSNumber *) numberHexString:(NSString *)aHexString
{
    // 为空,直接返回.
    if (nil == aHexString)
    {
        return nil;
    }
    
    NSScanner * scanner = [NSScanner scannerWithString:aHexString];
    unsigned long long longlongValue;
    [scanner scanHexLongLong:&longlongValue];
    
    //将整数转换为NSNumber,存储到数组中,并返回.
    NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
    
    return hexNumber;
    
}
@end
