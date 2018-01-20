//
//  ProxyConnection.m
//  PandaHero
//
//  Created by lemon4ex on 2017/10/18.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import "ProxyConnection.h"

enum
{
    HTTP_READ_HEADER = 10,
    HTTP_READ_BODY, //11
    HTTP_WRITE_DATA,
};

@interface ProxyConnection ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_localSocket;
    dispatch_queue_t _localQueue;
    HTTPMessage *_request;
}
@end

@implementation ProxyConnection

- (instancetype)initWithLocalSocket:(GCDAsyncSocket *)localSocket
{
    if (self = [super init]) {
        _localQueue = dispatch_queue_create("localsocket", NULL);
        _localSocket = localSocket;
        _localSocket.delegate = self;
        _localSocket.delegateQueue = _localQueue;
    }
    
    return self;
}

- (NSData *)doubleCRLFData
{
    return [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)readHTTPMessage
{
    _request = [[HTTPMessage alloc]initEmptyRequest];
    [_localSocket readDataToData:[self doubleCRLFData] withTimeout:30 tag:HTTP_READ_HEADER];
}

- (void)writeHTTPMessage:(HTTPMessage *)message
{
    [_localSocket writeData:[message messageData] withTimeout:30 tag:HTTP_WRITE_DATA];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == HTTP_READ_HEADER) {
        [_request appendData:data];
        DDLogInfo(@"Socket %@ read HTTP header",sock);
        DDLogDebug(@"1111 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        long long contentLength = [[_request headerField:@"Content-Length"] longLongValue];
        if (contentLength > 0) {
            [_localSocket readDataToLength:contentLength withTimeout:30 tag:HTTP_READ_BODY];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(didReadHTTPMessage:message:)]) {
                [_delegate didReadHTTPMessage:self message:_request];
            }
        }
    }
    else if (tag == HTTP_READ_BODY)
    {
        [_request appendData:data];
        if ([_delegate respondsToSelector:@selector(didReadHTTPMessage:message:)]) {
            [_delegate didReadHTTPMessage:self message:_request];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == HTTP_WRITE_DATA)
    {
        DDLogInfo(@"Write data done");
        [_localSocket disconnect];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogInfo(@"Local socket %@ did disconnect,error %@",_localSocket,err.localizedDescription);
    _localSocket.delegate = nil;
    _localSocket = nil;
    if ([_delegate respondsToSelector:@selector(connectionDidDisconnect:withError:)]) {
        [_delegate connectionDidDisconnect:self withError:err];
    }
}
@end
