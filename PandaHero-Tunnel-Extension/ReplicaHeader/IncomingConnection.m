//
//  IncomingConnection.m
//  Snail
//
//  Created by lemon4ex on 16/6/5.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "IncomingConnection.h"
#import "SGLogConversationRecord.h"
#import "SGGCDAsyncSocket.h"
#import "OutgoingConnection.h"
#import "ConnectionManager.h"
#import "HTTPResponseHeader.h"
#import "NSData-SGUtils.h"
#import "HTTPRequestHeader.h"
#import "HTTPRequestCONNECTHeader.h"
#import "SGLogRecordContainer.h"

@implementation IncomingConnection


- (void)dealloc {
//    // TODO
//    v4 = a1;
//    v5 = a3;
//    vars8 = a4;
//    v6 = (void *)objc_retain(a2, a2, a3);
//    if ( (unsigned __int8)byte_5C2D4 & (unsigned __int8)v4 )
//    {
//        v7 = objc_retain(v5, &classRef_NSString, &vars8);
//        v8 = objc_msgSend(&OBJC_CLASS___NSString, "alloc");
//        v9 = objc_msgSend(v8, "initWithFormat:arguments:", v7, &vars8, &vars8);
//        objc_release(v7);
//        v10 = objc_msgSend(v6, "loggerModuleName");
//        v11 = objc_retainAutoreleasedReturnValue(v10);
//        sub_1248C(v4, v11, v9);
//        objc_release(v11);
//        objc_release(v9);
//    }
}

- (void)disconnectWithReason:(id)arg1 {
    _record.status = arg1;
    _record.completed = YES;
    _record.failed = YES;
    NSLog(@"Disconnect with reason: %@",arg1);
    if (_socket) {
//        _socket.delegate = nil;
        [_socket disconnectAfterWritingHoldRef];
    }
    
    if (_outgoingConnection) {
        _outgoingConnection.delegate = nil;
        [_outgoingConnection disconnectWithReason:arg1];
        
    }
    
    self.status = 500;
    [_manager releaseIncomingConnection:self];
}

- (void)outgoingConnectionResponseDidComplete:(id)arg1 keepAlive:(BOOL)arg2 {
    NSLog(@"Ougoing connection report response did complete");
    
    _record.status = @"Completed";
    _record.completed = YES;
    
    if (_outgoingConnection.status == 300) {
        [_manager addOutgoingConnectionToReuseQueue:_outgoingConnection];
    }
    
    _outgoingConnection.delegate = nil;
    _outgoingConnection = nil;
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    if (arg2) {
        NSLog(@"Response complete, ready to process next request");
        [self readHeader];
    }
    else
    {
        NSLog(@"Keep alive disabled");
        [self disconnectWithReason:@"Keep alive disabled"];
    }
    
}

- (void)outgoingConnection:(id)arg1 didReadResponseHeader:(HTTPResponseHeader *)arg2 {
    
    _record.responseHeader = [arg2.rawResponseData stringValue];
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
}

- (void)outgoingConnectionSocketDidDisconnect:(id)arg1 error:(id)arg2 {
    [self disconnectWithReason:[NSString stringWithFormat:@"Remote closed (%@)",arg2]];
}

- (void)socket:(id)arg1 didWriteDataWithTag:(long)arg2 {
    if (_socket == arg1) {
        [_outgoingConnection continueReadData];
        _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ %@",arg1,NSStringFromSelector(@selector(socket:didWriteDataWithTag:)));
    }
}

- (void)outgoingConnection:(id)arg1 didReadData:(NSData *)arg2 {
    [_record addInBytes:arg2.length];
    
    [_socket writeData:arg2 withTimeout:-1 tag:0];
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
}

- (void)socketDidDisconnect:(id)arg1 withError:(id)arg2 {
    if (arg1 == _socket) {
        NSLog(@"Socket disconnect with error: %@",arg2);
        [self disconnectWithReason:[NSString stringWithFormat:@"Socket disconnect with error: %@",arg2]];
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ %@",arg1,NSStringFromSelector(@selector(socketDidDisconnect:withError:)));
    }
}

- (void)readFromSocket {
    if (!_reading) {
        _reading = YES;
        [_socket readDataWithTimeout:-1 maxSize:-1 tag:0];
    }
}

- (void)readHeader {
    _outgoingConnection.delegate = nil;
    _outgoingConnection = nil;
    
    _status = 200;
    [self readFromSocket];
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
}

- (void)outgoingConnectionDidWriteBodyData:(id)arg1 length:(unsigned int)arg2 {
    self.retry = NO;
    self.delegate = nil;
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    [self readFromSocket];
}

- (void)outgoingConnectionDidWriteHeaderData:(id)arg1 length:(unsigned int)arg2 {
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    _record.status = @"Transferring";
    if (_remaingData) {
        NSLog(@"Write remaing data...");
        [_outgoingConnection writeBodyData:_remaingData];
        [[_record requestBodyDataFileHandle] writeData:_remaingData];
        _remaingData = nil;
    }else
    {
        NSLog(@"outgoingConnectionDidWriteHeaderData");
        [self readFromSocket];
    }
}

- (void)outgoingConnectionSetupFailed:(id)arg1 error:(id)arg2 {
    [self writeServiceUnavailableResponseWithReason:arg2];
    [self disconnectWithReason:[NSString stringWithFormat:@"Outgoing connection setup failed (%@)",arg2]];
}

- (void)writeServiceUnavailableResponseWithReason:(id)arg1 {
    NSData *data = nil;
    if (arg1) {
        data = [[NSString stringWithFormat:@"Surge Error (%@)",arg1] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableData *bodyData = [[[NSString stringWithFormat:@"HTTP/1.1 503 Service Unavailable\r\nConnection: close\r\nProxy-Connection: close\r\nContent-Length: %lu\r\n\r\n",data.length] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [bodyData appendData:data];
    
    [_socket writeData:bodyData withTimeout:-1 tag:0];
}

- (void)outgoingConnectionDidBecomeAvailable:(OutgoingConnection*)arg1 {
    _status = 400;
    _record.localIPAddress = arg1.localIPAddress;
    _record.remoteIPAddress = arg1.remoteIPAddress;
    
    [_outgoingConnection startNewRequestWithHeader:_currentRequestHeader record:_record];
    _record.status = @"Sending header";
}

- (void)outgoingConnectionDidCompleteDNSLookup:(id)arg1 {
	_record.status = @"Establishing TCP connection";
}

- (void)socket:(id)arg1 didReadData:(NSData *)arg2 withTag:(long)arg3 {
    if (_socket == arg1) {
        _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
        _reading = NO;
        if (_status != 200) {
            if (_status == 400) {
                [_outgoingConnection writeBodyData:arg2];
                [[_record requestBodyDataFileHandle]writeData:arg2];
            }
            else
            {
                NSLog(@"Unexpected status: %d",self.status);
            }
        }
        else
        {
            if (!_requestHeaderData) {
                _requestHeaderData = [NSMutableData data];
            }
            [_requestHeaderData appendData:arg2];
            
            NSData *lrdata = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
            
            NSRange range =  [_requestHeaderData rangeOfData:lrdata options:0 range:NSMakeRange(0, _requestHeaderData.length)];
            
            if (range.location == NSNotFound) {
                NSLog(@"Request header not found, try LF separator");
                
                range =  [_requestHeaderData rangeOfData:[@"\r\r" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, _requestHeaderData.length)];
                
                if (range.location == NSNotFound) {
                    NSLog(@"Request header not found, try again: %@",_requestHeaderData);
                    [self readFromSocket];
                    return;
                }
            }
            
            NSData *httpData = [_requestHeaderData subdataWithRange:NSMakeRange(0, range.location + range.length)];
            
            _currentRequestHeader = [[HTTPRequestHeader alloc]initWithData:httpData];
            if (!_currentRequestHeader) {
                [self disconnectWithReason:[NSString stringWithFormat:@"Failed to parse request header"]];
                return;
            }
            
            if (range.location + range.length > _requestHeaderData.length) {
                _remaingData = nil;
            }
            else
            {
                _remaingData = [_requestHeaderData subdataWithRange:NSMakeRange(range.location + range.length, _requestHeaderData.length)];
                NSLog(@"Body data left in header datagram: %lu",_remaingData.length);
            }
            _requestHeaderData = nil;
            if (![_currentRequestHeader isMemberOfClass:[HTTPRequestCONNECTHeader class]]) {
                if([_currentRequestHeader.host isIPv6Address])
                {
                    [self disconnectWithReason:[NSString stringWithFormat:@"Not support IPv6"]];
                    return;
                }
                NSString *hostName = nil;
                [_currentRequestHeader.host getHostname:&hostName andPort:NULL withDefaultPortValue:0];
                _record = [[SGLogRecordContainer activeLogContainer]newConversationRecordWithHostname:hostName];
                
                _record.requestHeader = [[_currentRequestHeader parsedRequestData] stringValue];
                _record.method = [_currentRequestHeader HTTPMethod];
                _record.URL = [_currentRequestHeader URL];

                // TODO
                // 记录信息
//                v4 = a1;
//                v5 = a3;
//                vars8 = a4;
//                v6 = (void *)objc_retain(a2, a2, a3);
//                if ( (unsigned __int8)byte_5C2D4 & (unsigned __int8)v4 )
//                {
//                    v7 = objc_retain(v5, &classRef_NSString, &vars8);
//                    v8 = objc_msgSend(&OBJC_CLASS___NSString, "alloc");
//                    v9 = objc_msgSend(v8, "initWithFormat:arguments:", v7, &vars8, &vars8);
//                    objc_release(v7);
//                    v10 = objc_msgSend(v6, "loggerModuleName");
//                    v11 = objc_retainAutoreleasedReturnValue(v10);
//                    sub_1248C(v4, v11, (int)v9);
//                    objc_release(v11);
//                    objc_release(v9);
//                }
                
                NSLog(@"Received request: [%@] %@",_currentRequestHeader,_record.method);
//                [self loggerModuleName];
//                sub_1259C(8, (int)v5, (int)CFSTR("Received request: [%@] %@"), v84);
//                objc_release(v86);
//                objc_release(v84);
//                v88 = objc_msgSend(v5, "loggerModuleName");
//                v89 = objc_retainAutoreleasedReturnValue(v88);
//                v132 = &_NSConcreteStackBlock;
//                v133 = -1040187392;
//                v134 = 0;
//                v135 = sub_19168;
//                v136 = &unk_513D0;
//                v91 = (void *)objc_retain(v5, 0, v90);
//                v137 = v91;
//                sub_12550(16, v89, (int)&v132, v92, v87);
//                objc_release(v89);
//                v93 = objc_msgSend(v91, "loggerModuleName");
//                v94 = objc_retainAutoreleasedReturnValue(v93);
//                v126 = &_NSConcreteStackBlock;
//                v127 = -1040187392;
//                v128 = 0;
//                v129 = sub_19200;
//                v130 = &unk_513F0;
//                v96 = objc_retain(v91, &unk_513F0, v95);
//                v131 = v96;
//                sub_12550(16, v94, (int)&v126, v97, v98);
//                objc_release(v94);
                
                _status = 300;
                NSLog(@"Request available outgoing connection for: %@",[_currentRequestHeader host]);
                _outgoingConnection = [_manager reuseOutgoingConnectionToHost:[_currentRequestHeader host]];
                
                if (_outgoingConnection) {
                    _record.status = @"Reuse previous connection";
                }
                else
                {
                    _record.status = @"No previous outgoing connection, creating";
                    _outgoingConnection = [[OutgoingConnection alloc]initWithHost:[_currentRequestHeader host] manager:_manager];
                    _record.status = @"DNS Lookup";
                    
                    NSLog(@"Outgoing connection: %@",_outgoingConnection);
                    
                    _outgoingConnection.delegate = self;
                    if (_outgoingConnection.status == 50) {
                        [_outgoingConnection startConnect];
                    }
                    else if (_outgoingConnection.status == 300)
                    {
                        [self outgoingConnectionDidBecomeAvailable:_outgoingConnection];
                    }
                    else
                    {
                        NSLog(@"Unknown outgoing connection status: %d",_outgoingConnection.status);
                    }
                    
                    [_record addOutBytes:arg2.lenght];
                    
                    if (_remaingData.length) {
                        NSLog(@"CONNECT tunnel with additional data, length: %d",arg2.length);
                    }
                    
                    _socket.delegate = nil;
                    [_manager transferConnectionToCONNECTConnection:self socket:self.socket header:_currentRequestHeader];
                    _socket = nil;
                }
            }
        }
    }
    else
    {
        NSLog(@"Recevied message from socket, dismatch: %@ %@",arg1,NSStringFromSelector(@selector(socket:didReadData:withTag:)));
    }
}

- (id)initWithSocket:(id)arg1 manager:(id)arg2 {
    if (self = [super init]) {
        _manager = arg2;
        _socket = arg1;
        _socket.delegate = self;
        [self readHeader];
    }
    
    return self;
}


@end
