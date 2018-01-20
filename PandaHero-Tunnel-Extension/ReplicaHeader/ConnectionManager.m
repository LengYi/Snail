//
//  ConnectionManager.m
//  Snail
//
//  Created by lemon4ex on 16/6/2.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "ConnectionManager.h"
#import "HTTPRequestCONNECTHeader.h"
#import "SGGCDAsyncSocket.h"
#import "SGTunnelConnection.h"
#import "IncomingConnection.h"
#import "OutgoingConnection.h"

@implementation ConnectionManager


- (void)dealloc {
    [self stopHTTPProxyServer];
    if (_timeoutTimer) {
        dispatch_source_cancel(_timeoutTimer);
        _timeoutTimer = NULL;
    }
}

- (void)resumeTimer {
    if (_timeoutTimer) {
        dispatch_resume(_timeoutTimer);
    }
}

- (void)pauseTimer {
    if (_timeoutTimer ) {
        dispatch_suspend(_timeoutTimer);
    }
}

- (void)closeAllConnectionWithOutDispatch {
	// TODO
}

- (void)closeAllConnection {
	dispatch_async(_delegateQueue, ^{
        [self closeAllConnectionWithOutDispatch];
    });
}

- (void)timeoutTimer {
	// TODO
}

- (void)transferConnectionToCONNECTConnection:(id)arg1 socket:(SGGCDAsyncSocket *)arg2 header:(HTTPRequestCONNECTHeader *)header {
    if ([[header host] isIPv6Address]) {
        NSLog(@"不支持ipv6 %@",[header host]);
        [_incomingConnections removeObject:arg1];
        [arg2 disconnect];
    }
    else
    {
        SGTunnelConnection *connection = [[SGTunnelConnection alloc]initWithSocket:arg2 CONNECTHeader:header manager:self];
        [_incomingConnections removeObject:arg1];
        if (connection) {
            [_tunnelConnections addObject:connection];
        }
        else
        {
            [arg2 disconnect];
        }
    }
}

- (void)releaseTunnelConnection:(SGTunnelConnection *)arg1 {
    NSLog(@"Release tunnel connection: %@",arg1);
    [_tunnelConnections removeObject:arg1];
}

- (void)releaseIncomingConnection:(IncomingConnection *)arg1 {
    NSLog(@"Release incoming connection: %@",arg1);
    [_incomingConnections removeObject:arg1];
}

- (void)incomingConnection:(id)arg1 {
	dispatch_async(_delegateQueue, ^{
        [_incomingConnections addObject:[[IncomingConnection alloc] initWithSocket:arg1 manager:self]];
    });
}

- (void)socket:(id)arg1 didAcceptNewSocket:(id)arg2 {
    [self loggerModuleName];
    
    if (_incomingConnections.count < 0x65) {
        [self incomingConnection:arg2];
    }
    else
    {
        NSLog(@"Hard incoming connection limit: %ld, reject!",_incomingConnections.count);
        [arg2 disconnect];
    }
}

- (void)stopHTTPProxyServer {
    [_listener disconnect];
    [self closeAllConnectionWithOutDispatch];
}

- (BOOL)startHTTPProxyServerWithError:(id *)arg1 {
    _listener = [[SGGCDAsyncSocket alloc]initWithDelegate:self delegateQueue:_delegateQueue];
    NSError *error;
    if (![_listener acceptOnInterface:@"127.0.0.1" port:6153 error:&error]) {
        NSLog(@"监听失败%@",error);
        return NO;
    }
    
    return YES;
}

- (void)addOutgoingConnectionToReuseQueue:(OutgoingConnection *)arg1 {
    NSMutableArray *array = _outgoingConnectionMap[[arg1 host]];
    if (!array) {
        array = [NSMutableArray array];
        _outgoingConnectionMap[[arg1 host]] = array;
    }
    
    [array addObject:arg1];
}

- (id)reuseOutgoingConnectionToHost:(id)arg1 {
    NSMutableArray *array = _outgoingConnectionMap[arg1];
    for (OutgoingConnection *outgoing in [NSMutableArray copy]) {
        if (outgoing.status == 300) {
            [array removeObject:outgoing];
            
            return outgoing;
        }
    }
    
    return nil;
}

- (id)initWithSettingsModel:(id)arg1 {
    if (self = [self init]) {
        _delegateQueue = dispatch_queue_create("Surge Core", NULL);
        _incomingConnections = [NSMutableArray array];
        _outgoingConnectionMap = [NSMutableDictionary dictionary];
        _tunnelConnections = [NSMutableArray array];
        _timeoutTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _delegateQueue);
        dispatch_source_set_timer(_timeoutTimer, DISPATCH_TIME_NOW, 2, 0);
        dispatch_source_set_event_handler(_timeoutTimer, ^{
            [self timeoutTimer];
        });
        dispatch_resume(_timeoutTimer);
    }
    
    return self;
}


@end