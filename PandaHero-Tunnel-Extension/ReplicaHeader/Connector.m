//
//  Connector.m
//  Snail
//
//  Created by lemon4ex on 16/6/2.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "Connector.h"
#import "SGLogRecordContainer.h"

@implementation Connector


+ (id)connectorWithTargetHostname:(id)arg1 targetPort:(int)arg2 manager:(ConnectionManager *)arg3 {
    Connector *connector = [[self alloc]init];
    connector->_retry = 0;
    connector.targetHost = arg1;
    connector.targetPort = arg2;
    connector.manager = arg3;
    return connector;
}

// 获取远程地址
- (id)remoteIPAddress {
    return [_socket connectedHost];
}

- (id)localIPAddress {
    return [_socket localHost];
}

- (void)createSocket {
    SGGCDAsyncSocket *socket = [[SGGCDAsyncSocket alloc]initWithDelegate:self delegateQueue:self.manager.delegateQueue];
    _socket = socket;
    
}

- (void)disconnectWithError:(NSError *)arg1 {
    if (_socket) {
        _socket.delegate = nil;
        [_socket disconnectAfterWritingHoldRef];
        _socket = nil;
    }
    
    [self.delegate connectorDidDisconnect:self withError:arg1];
}

- (void)socketDidDisconnect:(id)arg1 withError:(id)arg2 {
    if (_socket == arg1) {
        NSLog(@"连接已断开%@",arg2);
        if (_initialized) {
            [self disconnectWithError:arg2];
        }
        else
        {
            _socket.delegate = nil;
            _socket = nil;
            
            if (_retry > 1) {
                NSLog(@"连接次数超过：%@ (%@)",_targetHost,arg2);
                [self.delegate connectorDidSetupFailed:self error:arg2];
            }
            else
            {
                NSLog(@"设置超时，重试...");
                _retry ++;
                [self start];
            }
        }
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ socketDidDisconnect:withError:, %@",self,arg2);
    }
    
}

- (void)readDataWithTimeout:(double)arg1 maxLength:(unsigned int)arg2 tag:(long)arg3 {
    _lastReadDataTimeout = arg1;
    _lastReadDataMaxSize = arg2;
    [_socket readDataWithTimeout:arg1 maxSize:arg2 tag:arg3];
}

- (void)writeData:(NSData *)arg1 withTimeout:(double)arg2 tag:(long)arg3 {
    [_connectorSessionRecord addOutBytes:arg1.length];
    [_interfaceSessionRecord addOutBytes:arg1.length];
    
    [_socket writeData:arg1 withTimeout:arg2 tag:arg3];
}

- (void)socket:(Connector *)arg1 didWriteDataWithTag:(long)arg2 {
    if (_socket == arg1) {
        [arg1.delegate connector:self didWriteDataWithTag:arg2];
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ didWriteDataWithTag:",self);
    }
}

- (void)socket:(id)arg1 didReadData:(NSData *)arg2 withTag:(long)arg3 {
    if (_socket == arg1) {
        [_connectorSessionRecord addInBytes:arg2.length];
        [_interfaceSessionRecord addInBytes:arg2.length];
        [self.delegate connector:self didReadData:arg2 withTag:arg3];
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ didWriteDataWithTag:",self);
    }
}

- (void)socket:(id)arg1 didConnectToHost:(id)arg2 port:(unsigned short)arg3 {
    if (_socket == arg1) {
        _interfaceSessionRecord = [[SGLogRecordContainer activeLogContainer]interfaceSessionRecordWithSourceIP:[_socket localHost]];
        NSLog(@"Connection established: %@:%d",arg2,arg3);
        _initialized = YES;
        [self.delegate connectorDidBecomeAvailable:self];
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ didConnectToHost:, %@",self,arg2);
        
    }
}

- (void)start {
    NSLog(@"Start direct connection to: %@:%d",_targetHost,_targetPort);
    
    NSError *error;
    if (![self.socket connectToHost:_targetHost onPort:_targetPort withTimeout:-1 error:&error]) {
        NSLog(@"Error occurred when start direct connection: %@",_targetHost);
        [self.delegate connectorDidSetupFailed:self error:error];
    }
}


@end