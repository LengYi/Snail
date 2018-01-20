//
//  OutgoingConnection.m
//  Snail
//
//  Created by lemon4ex on 16/6/5.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "OutgoingConnection.h"
#import "Connector.h"
#import "NSData-SGUtils.h"
#import "NSString-SGUtils.h"
#import "HTTPRequestHeader.h"
#import "HTTPResponseHeader.h"
#import "SGDNSClient.h"
#import "SGDNSClientMultipleResult.h"
#import "ChunkedCodingParser.h"
#import "SGLogConversationRecord.h"

@implementation OutgoingConnection


- (id)remoteIPAddress {
	return [_connector remoteIPAddress];
}

- (id)localIPAddress {
    return [_connector localIPAddress];
}

- (void)dealloc {
    NSLog(@"Dealooc");
}

- (void)disconnectWithReason:(id)arg1 {
    NSLog(@"disconnectWithReason: %@",arg1);
    _connector.delegate = nil;
    [_connector disconnectWithError:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
    _connector = nil;
    [self reportDisconnectWithError:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
	
}

- (void)writeBodyData:(NSData*)arg1 {
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    [_connector writeData:arg1 withTimeout:-1 tag:arg1.length];
}

- (void)connector:(id)arg1 didWriteDataWithTag:(long)arg2 {
    if (arg2 == -10) {
        [self.delegate outgoingConnectionDidWriteHeaderData:self length:_reading];
    }
    else
    {
        [self.delegate outgoingConnectionDidWriteBodyData:self length:arg2];
    }
}

- (void)startNewRequestWithHeader:(HTTPRequestHeader *)arg1 record:(id)arg2 {
    if (_status == 300) {
        NSLog(@"%@ current status: %d",self,_status);
    }
    
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    NSLog(@"New conversation: %@",[arg1 URL]);
    _status = 400;
    _delegate = arg1;
    _responseHeaderData = nil;
    _responseReceviedDataLength = 0;
    _processingHeader = arg1;
    _responseHeaderData = [NSMutableData data];
    NSAssert([_processingHeader parsedRequestData] != nil, @"No request data!");
    _reading = [_processingHeader parsedRequestData].length;
    [_connector writeData:[_processingHeader parsedRequestData] withTimeout:-1 tag:-10];
    [self continueReadData];
}

- (void)reportDisconnectWithError:(id)arg1 {
    NSLog(@"Socket closed: %@",arg1);
    
    if (_connector) {
        _connector.delegate = nil;
        [_connector disconnectWithError:arg1];
        _connector = nil;
    }
    
    _status = 500;
    [_delegate outgoingConnectionSocketDidDisconnect:self error:arg1];
}

- (void)connectorDidDisconnect:(id)arg1 withError:(id)arg2 {
    NSLog(@"Socket disconnect with error: %@",arg2);
    _connector.delegate = nil;
    _connector = nil;
    [self reportDisconnectWithError:arg2];
	
}

- (void)finishConversation {
    
    NSLog(@"%@ current status: %d",self,_status);
    NSLog(@"Finish conversation: %@, response body data length: %d",[_delegate URL],[_responseHeaderData length]);
    _lastActivityTimestamp = 0;
    _delegate = nil;
    
    if ([_responseHeader.connection isEqualToString:@"close"]) {
        _status = 500;
        
    }
    else if ([_responseHeader.httpVerison isEqualToString:@"1.1"])
    {
        _status = 300;
    }
    else
    {
        if (![_responseHeader.connection isEqualToString:@"keep-alive"]) {
            _status = 500;
        }
        else
        {
            _status = 300;
        }
        
    }
    
    [_delegate outgoingConnectionResponseDidComplete:self keepAlive:[_responseHeader.connection isEqualToString:@"keep-alive"]];
    
    if (_chunkedCodingParser == 6) {
        [self reportDisconnectWithError:[NSError errorWithDomain:@"SGErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"OutgoingConnectionResponseEndTypeIllegal"}]];
    }
    else
    {
        if (_status != 300) {
            [self reportDisconnectWithError:[NSError errorWithDomain:@"SGErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Server not support keep-alive"}]];
        }
    }
    
    _responseHeader = nil;
    _writingHeaderLength = 0;
    _responseHeaderData = nil;
    
}

- (void)continueReadData {
    if (!_responseReceviedDataLength) {
        _responseReceviedDataLength = 1;
        [_connector readDataWithTimeout:-1 maxLength:_responseReceviedDataLength tag:0];
    }
}

- (int)responseEndType {
    if (_writingHeaderLength) {
        return 3;
    }
    else
    {
        if ([[_delegate HTTPMethod]isEqualToString:@"HEAD"]) {
            return 2;
        }
        else if(_responseHeader.statusCode == 304 &&
                _responseHeader.responseContentLength != -1)
        {
            NSLog(@"Server return code 304 with Content-Length, which is illegal (RFC 2616), abort: %@",[_responseHeader.rawResponseData stringValue]);
            return 6;
        }
        else if (_responseHeader.statusCode == 304)
        {
            return 7;
        }
        else
        {
            if (_responseHeader.responseContentLength == -1) {
                if ([_responseHeader.httpVerison isEqualToString:@"1.0"]) {
                    if ([[_responseHeader.connection lowercaseString]isEqualToString:@"keep-alive"]) {
                        NSLog(@"HTTP Version 1.0 require connection keep alive, but no valid Content-Length, abort. %@",[_responseHeader.rawResponseData stringValue]);
                        return 5;
                    }
                    else
                        return 4;
                }
                else
                {
                    NSLog(@"No content length in header and do not support chunked transfer encoding");
                    if ([[_responseHeader.connection lowercaseString]isEqualToString:@"keep-alive"]) {

                        return 5;
                    }
                    else
                        return 4;
                }
            }
            else
            {
                return 1;
            }
        }
    }
}

- (void)connector:(id)arg1 didReadData:(NSData *)arg2 withTag:(long)arg3 {
    _responseReceviedDataLength = 0;
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    if (!_responseHeader) {
        [_responseHeaderData appendData:arg2];
        NSRange range = [_responseHeaderData rangeOfData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]options:0 range:NSMakeRange(0, _responseHeaderData.length)];
        if (range.location == NSNotFound) {
            NSLog(@"Response header not found, try LF separator");
            range = [_responseHeaderData rangeOfData:[@"\r\r" dataUsingEncoding:NSUTF8StringEncoding]options:0 range:NSMakeRange(0, _responseHeaderData.length)];
            if (range.location == NSNotFound) {
                NSLog(@"Response header not found, try again: %@",_responseHeaderData);
                [self continueReadData];
                return;
            }
        }
        
        NSData *responseData = [_responseHeaderData subdataWithRange:NSMakeRange(0, range.location + range.length)];
        _responseHeader = [[HTTPResponseHeader alloc]initWithData:responseData];
        
        if (!_responseHeader) {
            // TODO
            // 记录信息
//            v45 = objc_msgSend(v5, "loggerModuleName");
//            v46 = objc_retainAutoreleasedReturnValue(v45);
//            v126 = &_NSConcreteStackBlock;
//            v127 = -1040187392;
//            v128 = 0;
//            v129 = sub_11320;
//            v130 = &unk_511B0;
//            v47 = (void *)objc_retain(v5, sub_11320, &unk_511B0);
//            v131 = v47;
//            sub_12550(2, v46, (int)&v126, v48, v111);
//            objc_release(v46);
            [self reportDisconnectWithError:[NSError errorWithDomain:@"SGErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Unable to parse response header"}]];
            return;
        }
        
//        v112 = v31;
//        v35 = objc_msgSend(v5, "loggerModuleName");
//        v36 = objc_retainAutoreleasedReturnValue(v35);
//        v118 = &_NSConcreteStackBlock;
//        v119 = -1040187392;
//        v120 = 0;
//        v121 = sub_1140C;
//        v122 = &unk_511D0;
//        v37 = objc_retain(v5, sub_1140C, &unk_511D0);
//        v123 = v37;
//        sub_12550(16, v36, (int)&v118, v38, v111);
//        objc_release(v36);
        
        if (range.location + range.length >= _responseHeaderData.length) {
            
        }
        else
        {
            NSData *bodyData = [_responseHeaderData subdataWithRange:NSMakeRange(range.location + range.length, _responseHeaderData.length - range.location - range.length)];
            NSLog(@"Body data left in header datagram: %lu",bodyData.length);
            if (_responseHeader.statusCode == 100) {
                NSLog(@"Status code 100 received, read header again...");
                [_delegate outgoingConnection:self didReadData:_responseHeader.rawResponseData];
                _responseHeader = nil;
                _responseHeaderData = nil;
                _responseHeaderData = [NSMutableData data];
                if (bodyData) {
                    NSLog(@"Fake connector data and try for remaining data");
                    [self connector:arg1 didReadData:bodyData withTag:-10101];
                    
                }
                
                return;
            }
            
            NSLog(@"Received response: [%d] %@",_responseHeader.statusCode,[_processingHeader URL]);
            [_delegate outgoingConnection:self didReadResponseHeader:_responseHeader];
            [_delegate outgoingConnection:self didReadData:_responseHeader.rawResponseData];
            
            if (_responseHeader.chunkedTransferEncoding) {
                _chunkedCodingParser = [[ChunkedCodingParser alloc]init];
                _chunkedCodingParser.outFileHandle = [_record responseBodyDataFileHandle];
            }
            
            _endType = [self responseEndType];
            NSLog(@"Response end type: %d",_endType);
            
            if (bodyData) {
                [_delegate outgoingConnection:self didReadData:bodyData];
                if (!_writingHeaderLength) {
                    [[_record responseBodyDataFileHandle]writeData:bodyData];
                }
                
            }
            // TODO
//            if ( (unsigned int)&v5->_chunkedCodingParser[-1].theIn + 7 <= 6 )
//            {
//                switch ( v5->_chunkedCodingParser )
//                {
//                    case 1u:
//                        v117 = v10;
//                        v114 = v7;
//                        v87 = v5->_responseReceviedDataLength;
//                        v88 = *((_DWORD *)&v5->_responseHeaderData + 1);
//                        v89 = v88 >= (unsigned int)objc_msgSend(*(void **)&v5->super.NSObject_opaque[v14], "responseContentLength");
//                        v91 = 0;
//                        v92 = 0;
//                        if ( !v89 )
//                            v91 = 1;
//                        if ( v87 < v90 )
//                            v92 = 1;
//                        if ( v87 == v90 )
//                            v92 = v91;
//                        if ( !v92 )
//                        {
//                            v93 = objc_msgSend(*(void **)&v5->super.NSObject_opaque[v14], "responseContentLength");
//                            sub_1259C(16, (int)v5, (int)CFSTR("Response data content length enough: %d"), (int)v93);
//                            v94 = *(_QWORD *)(&v5->_responseHeaderData + 1);
//                            LODWORD(v95) = objc_msgSend(*(void **)&v5->super.NSObject_opaque[v14], "responseContentLength");
//                            if ( v95 == v94 )
//                            {
//                                objc_msgSend(v5, "finishConversation");
//                            }
//                            else
//                            {
//                                v98 = objc_msgSend(*(void **)&v5->super.NSObject_opaque[v14], "responseContentLength");
//                                v99 = *((_DWORD *)&v5->_responseHeaderData + 1);
//                                v100 = v5->_responseReceviedDataLength;
//                                v101 = objc_msgSend(v5->_delegate, "rawRequestData");
//                                v102 = (void *)objc_retainAutoreleasedReturnValue(v101);
//                                v103 = v102;
//                                v104 = objc_msgSend(v102, "stringValue");
//                                v105 = objc_retainAutoreleasedReturnValue(v104);
//                                v106 = objc_msgSend(*(void **)&v5->super.NSObject_opaque[v14], "rawResponseData");
//                                v107 = (void *)objc_retainAutoreleasedReturnValue(v106);
//                                v108 = v107;
//                                v109 = objc_msgSend(v107, "stringValue");
//                                v110 = objc_retainAutoreleasedReturnValue(v109);
//                                sub_1259C(8, (int)v5, (int)CFSTR("Response data content length dismatch: %d %d\n%@\n%@"), (int)v98);
//                                objc_release(v110);
//                                objc_release(v108);
//                                objc_release(v105);
//                                objc_release(v103);
//                                objc_msgSend(v5, "disconnectWithReason:", CFSTR("Response data content length dismatch"));
//                            }
//                        }
//                        v7 = v114;
//                        v10 = v117;
//                        break;
//                    case 2u:
//                    case 5u:
//                    case 6u:
//                    case 7u:
//                        goto LABEL_41;
//                    case 3u:
//                        objc_msgSend((void *)v5->_writingHeaderLength, "parse:", v10);
//                        if ( objc_msgSend((void *)v5->_writingHeaderLength, "currentStep") == (void *)6 )
//                        {
//                            sub_1259C(16, (int)v5, (int)CFSTR("Chunked end"), v96);
//                        LABEL_41:
//                            objc_msgSend(v5, "finishConversation");
//                        }
//                        else if ( objc_msgSend((void *)v5->_writingHeaderLength, "currentStep") == (void *)7 )
//                        {
//                            sub_1259C(8, (int)v5, (int)CFSTR("Chunked Abort!"), v97);
//                            objc_msgSend(v5, "disconnectWithReason:", CFSTR("Chunked encoding error"));
//                        }
//                        break;
//                    default:
//                        break;
//                }
//            }
        }
    }
}

- (void)connectorDidSetupFailed:(id)arg1 error:(id)arg2 {
    NSLog(@"Connector failed: %d",_endType);
    [_delegate outgoingConnectionSetupFailed:arg1 error:arg2];
    [self reportDisconnectWithError:arg2];
}

- (void)connectorDidBecomeAvailable:(id)arg1 {
    NSLog(@"connectorDidBecomeAvailable");
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    _status = 300;
    [_delegate outgoingConnectionDidBecomeAvailable:self];
}

- (void)startConnect {
    _status = 100;
    _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    if ([_host isIPAddress]) {
        [_delegate outgoingConnectionDidCompleteDNSLookup:self];
        _connector = [Connector connectorWithTargetHostname:_hostname targetPort:_port manager:_manager];
        _connector.delegate = self;
        [_connector start];
    }
    else
    {
        [[SGDNSClient sharedInstance] lookupDomain:_host completionHandler:^(SGDNSClientMultipleResult *result){
            if (result.isNotEmpty) {
                [_delegate outgoingConnectionDidCompleteDNSLookup:self];
                _connector = [Connector connectorWithTargetHostname:_hostname targetPort:_port manager:_manager];
                _connector.delegate = self;
                [_connector start];
            }
            else
            {
                [self disconnectWithReason:@"DNS Lookup failed!"];
            }
        }];
    }
}

- (id)initWithHost:(id)arg1 manager:(id)arg2 {
    if (self = [super init]) {
        NSLog(@"New outgoing connection to %@",arg1);
        _host = arg1;
        _manager = arg2;
        [_host getHostname:&_hostname andPort:&_port withDefaultPortValue:80];
        _status = 50;
        _lastActivityTimestamp = CFAbsoluteTimeGetCurrent();
    }
    
    return self;
}


@end
