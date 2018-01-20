//
//  PacketTunnelProvider.m
//  Snail
//
//  Created by lemon4ex on 16/6/3.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "NSString-SGUtils.h"
#import "STTCPConnectionManager.h"
#import "STNetworkInterfaceManager.h"
#import "SettingsModel.h"
#import "STIPLayerDNSForwarder.h"
#import "SGDNSClient.h"
#import "ConnectionManager.h"
#import "SGLogRecordContainer.h"
#import "SGGCDAsyncSocket.h"

unsigned int dword_5C3FC;
unsigned int dword_5C400;
unsigned int dword_5C404;

FILE *logFile;

static PacketTunnelProvider *provider;

@implementation PacketTunnelProvider


+ (id)sharedInstance {
    return provider;
}

+ (void)load {
//    dword_5C3FC = (int)objc_msgSend(CFSTR("240.0.0.1"), "IPAddressUsingNetworkByteOrder");
//    dword_5C400 = (int)objc_msgSend(CFSTR("240.0.0.2"), "IPAddressUsingNetworkByteOrder");
//    dword_5C404 = (int)objc_msgSend(CFSTR("240.0.0.3"), "IPAddressUsingNetworkByteOrder");
    dword_5C3FC = [@"240.0.0.1" IPAddressUsingNetworkByteOrder];
    dword_5C400 = [@"240.0.0.2" IPAddressUsingNetworkByteOrder];
    dword_5C404 = [@"240.0.0.3" IPAddressUsingNetworkByteOrder];
    
}

- (void)logRecordContainer:(id)arg1 didAddNewConversationRecord:(id)arg2 {
    // TODO
//    LODWORD(v6) = dword_5C408;
//    v5 = __OFSUB__(dword_5C408, 30);
//    v4 = dword_5C408 - 30 < 0;
//    HIDWORD(v6) = dword_5C408++ + 1;
//    if ( !(v4 ^ v5) )
//        j__objc_msgSend((struct Connector *)self, "shutdown", v6, v7, v8);
}

- (void)shutdown {
    // TODO
//    sub_1259C(4, (int)self, (int)CFSTR("Shutdown"), v2);
//    v3 = objc_msgSend(&OBJC_CLASS___SGLogRecordContainer, "activeLogContainer");
//    v4 = (void *)objc_retainAutoreleasedReturnValue(v3);
//    objc_msgSend(v4, "saveAllData");
//    objc_release(v4);
//    exit(0);
}

- (void)dealloc {
    [self shutdown];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self removeObserver:self forKeyPath:@"defaultPath"];
}

- (id)DNSServerAddresses {
    if (_settingsModel.DNSServer) {
        NSLog(@"Use self-defined DNS server: %@",_settingsModel.DNSServerAddresses);
        return _settingsModel.DNSServerAddresses;
    }
    else
    {
        // TODO
        //  使用系统DNS
        
//        res_9_init();
//        v12 = objc_msgSend(&OBJC_CLASS___NSMutableArray, "arrayWithCapacity:", _res.nscount);
//        v19 = (void *)objc_retainAutoreleasedReturnValue(v12);
//        if ( _res.nscount >= 1 )
//        {
//            v13 = &_res.nsaddr_list[0].var3;
//            v14 = 0;
//            do
//            {
//                v15 = inet_ntoa((struct in_addr)v13->var0);
//                v16 = objc_msgSend(&OBJC_CLASS___NSString, "stringWithUTF8String:", v15);
//                v17 = (void *)objc_retainAutoreleasedReturnValue(v16);
//                if ( (unsigned int)objc_msgSend(v17, "isValidIPAddress") & 0xFF )
//                    objc_msgSend(v19, "addObject:", v17);
//                objc_release(v17);
//                v13 += 4;
//                ++v14;
//            }
//            while ( v14 < _res.nscount );
//        }
//        v11 = (struct Connector *)v19;
//        sub_1259C(4, (int)v2, (int)CFSTR("System DNS servers: %@"), (int)v19);
        
    }
    
    return nil;
}

- (void)wake {
//    v2 = self;
//    objc_msgSend(self->_connectionManager, "resumeTimer");
//    v3 = objc_msgSend(&OBJC_CLASS___SGLogRecordContainer, "activeLogContainer");
//    v4 = (void *)objc_retainAutoreleasedReturnValue(v3);
//    objc_msgSend(v4, "resumeTimer");
//    objc_release(v4);
//    v5 = v2;
//    v6 = &OBJC_CLASS___PacketTunnelProvider;
//    objc_msgSendSuper2(&v5, "wake");
    
    [_connectionManager resumeTimer];
    [[SGLogRecordContainer activeLogContainer]resumeTimer];
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    [_connectionManager pauseTimer];
    [[SGLogRecordContainer activeLogContainer]pauseTimer];
}

- (void)stopTunnelWithReason:(int)arg1 completionHandler:(void (^)(void))completionHandler {
    NSLog(@"Stop by user, reason: %ld",arg1);
    [self shutdown];
}

- (id)prepareTunnelNetworkSettingsWithDNSServers:(id)arg1 {
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]initWithTunnelRemoteAddress:@"240.240.240.240"];
    settings.MTU = @(1400);
    settings.IPv4Settings = [[NEIPv4Settings alloc]initWithAddresses:@[@"240.0.0.1"] subnetMasks:@[@"255.0.0.0"]];
    settings.IPv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute],
                                             [[NEIPv4Route alloc]initWithDestinationAddress:@"17.0.0.0" subnetMask:@"255.0.0.0"],
                                             [[NEIPv4Route alloc]initWithDestinationAddress:@"240.0.0.0" subnetMask:@"255.0.0.0"]];
    settings.IPv4Settings.excludedRoutes = @[[[NEIPv4Route alloc]initWithDestinationAddress:@"0.0.0.0" subnetMask:@"128.0.0.0"],
                                             [[NEIPv4Route alloc]initWithDestinationAddress:@"128.0.0.0" subnetMask:@"128.0.0.0"]
                                             ];
    settings.proxySettings = [[NEProxySettings alloc]init];
    settings.proxySettings.HTTPEnabled = YES;
    settings.proxySettings.HTTPSEnabled = YES;
    settings.proxySettings.HTTPServer = [[NEProxyServer alloc]initWithAddress:@"240.0.0.3" port:6152];
    settings.proxySettings.HTTPSServer = [[NEProxyServer alloc]initWithAddress:@"240.0.0.3" port:6152];
    
    settings.DNSSettings = [[NEDNSSettings alloc]initWithServers:@[@"240.0.0.2"]];
    
    return settings;

}

- (void)networkChanged {
    NSLog(@"Network changed, reset all service");
    
    [_connectionManager closeAllConnection];
    
    [[STTCPConnectionManager sharedInstance]closeAllConnection];
    
    [[SGDNSClient sharedInstance]flushCache];
    
    self.reasserting = YES;
    
    [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error) {
        
    }];
    
    if (_resetTimer) {
        dispatch_source_cancel(_resetTimer);
        _resetTimer = nil;
    }
    _resetTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _dispatchQueue);
    dispatch_source_set_timer(_resetTimer, dispatch_time(0, 0), 3, 0);
    dispatch_source_set_event_handler(_resetTimer, ^{
        dispatch_source_cancel(_resetTimer);
        [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error) {
           dispatch_async(_dispatchQueue, ^{
               NSLog(@"Tunnel flush done");
               if (error) {
                   NSLog(@"Flush tunnel setting failed: %@",error);
                   [self shutdown];
               }
               else
               {
                   if ([[[STNetworkInterfaceManager sharedInstance]primaryIPAddress] isValidIPAddress]) {
                       [self.ipLayerDNSForwarder setUpstreamDNSServers:[self DNSServerAddresses]];
                       [[SGDNSClient sharedInstance]setUpstreamDNSServers:[self DNSServerAddresses]];
                       
                        NETunnelNetworkSettings *settings = [self prepareTunnelNetworkSettingsWithDNSServers:[self DNSServerAddresses]];
                       
                       [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
                           dispatch_async(_dispatchQueue, ^{
                               if (error) {
                                   NSLog(@"setTunnelNetworkSettings failed: %@",error);
                                   [self shutdown];
                               }
                               else
                               {
                                   NSLog(@"Reset completed");
                                   self.reasserting = NO;
                               }
                               
                           });
                       }];
                   }
                   
               }
           });
        }];
    });
    dispatch_resume(_resetTimer);
}

- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4 {
    if (self == arg1 && [arg2 isEqualToString:@"defaultPath"]) {
        [[STNetworkInterfaceManager sharedInstance]updateInterfaceInfo];
        
    }
    else
    {
        [super observeValueForKeyPath:arg1 ofObject:arg2 change:arg3 context:arg4];
    }
}

- (void)startTunnelWithOptions:(id)arg1 completionHandler:(void (^)(NSError *))completionHandler {
    provider = self;
    _startDate = [NSDate date];
    NSString *path = [[NSFileManager defaultManager]containerURLForSecurityApplicationGroupIdentifier:@"group.me.yach.Replica"].path;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *sessionsPath = [path stringByAppendingPathComponent:@"Sessions"];
    NSString *logDirPath = [sessionsPath stringByAppendingPathComponent:[formatter stringFromDate:[NSDate date]]];
    [[NSFileManager defaultManager]createDirectoryAtPath:logDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *logPath = [logDirPath stringByAppendingPathComponent:@"Replica.log"];
    dispatch_queue_t dword_5C378 = dispatch_queue_create("SGLogger", NULL);
    if (logFile) {
        fclose(logFile);
    }
    // TODO
    // 设置文件夹不同步，初始化日志系统
//    v37 = objc_msgSend(&OBJC_CLASS___NSFileManager, "defaultManager");
//    v38 = (void *)objc_retainAutoreleasedReturnValue(v37);
//    objc_msgSend(v38, "createFileAtPath:contents:attributes:", v36, 0, 0);
//    objc_release(v38);
//    v39 = objc_msgSend(v36, "copy");
//    v40 = dword_5C380;
//    dword_5C380 = (int)v39;
//    objc_release(v40);
//    v124 = (void *)objc_retainAutorelease(v36);
//    v41 = (const char *)objc_msgSend(v124, "fileSystemRepresentation");
//    dword_5C37C = (int)fopen(v41, "w");
//    objc_release(v124);
//    NSSetUncaughtExceptionHandler(sub_12658);
//    v42 = v121;
//    v43 = objc_msgSend((void *)v121, "loggerModuleName");
//    v44 = objc_retainAutoreleasedReturnValue(v43);
//    v45 = (void *)objc_retainAutorelease(v44);
//    v46 = v45;
//    v47 = objc_msgSend(v45, "UTF8String");
//    v48 = dispatch_queue_create(v47, 0);
//    v49 = *(_DWORD *)(v121 + 4);
//    *(_DWORD *)(v121 + 4) = v48;
//    objc_release(v49);
//    objc_release(v46);
//    sub_1CD40(0x3E8u, (int)sub_1CE04);
//    gettimeofday(&v137, 0);
    
    [STTCPConnectionManager sharedInstance];
    [[STNetworkInterfaceManager sharedInstance] updateInterfaceInfo];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkChanged) name:@"STNetworkInterfaceManagerPrimaryIPDidChange" object:nil];
    
    [self addObserver:self forKeyPath:@"defaultPath" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setupCommandListener];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.me.yach.Replica"];
    
    NSLog(@"Initialized, container build: %@",[userDefaults objectForKey:@"Build"]);
    
    NEVPNProtocol *protocol = [self protocolConfiguration];
//    [protocol providerConfiguration];

//    v62 = v61;
//    v63 = objc_msgSend(v61, "providerConfiguration");
//    v64 = (void *)objc_retainAutoreleasedReturnValue(v63);
//    v65 = v64;
//    v66 = objc_msgSend(v64, "objectForKeyedSubscript:", CFSTR("pro"));
//    v67 = (void *)objc_retainAutoreleasedReturnValue(v66);
//    *(_BYTE *)(v121 + 20) = (unsigned int)objc_msgSend(v67, "boolValue");
    
    _settingsModel = [SettingsModel settingsModelFromPath:[path stringByAppendingPathComponent:@"replica.conf"] error:nil];
    if (!_settingsModel) {
        NSLog(@"error");
        
    }
    else
    {
        // TODO
        // 初始化记录系统
    }
    
    _ipLayerDNSForwarder = [[STIPLayerDNSForwarder alloc]init];
    _ipLayerDNSForwarder.localDNSMap = _settingsModel.localDNSMap;
    _ipLayerDNSForwarder.upstreamDNSServers = _settingsModel.DNSServerAddresses;
    
    [[SGDNSClient sharedInstance]setUpstreamDNSServers:_settingsModel.DNSServerAddresses];
    
    NSLog(@"Setup proxy server...");
    
    _connectionManager = [[ConnectionManager alloc]initWithSettingsModel:_settingsModel];
    
    NETunnelNetworkSettings *settings = [self prepareTunnelNetworkSettingsWithDNSServers:_settingsModel.DNSServerAddresses];
    
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setTunnelNetworkSettings failed: %@",error);
            completionHandler(error);
        }
        else
        {
            dispatch_async(_dispatchQueue, ^{
                [self readPacketFlow];
                NSLog(@"Start service completed");
                
            });
        }
    }];
    
}

- (void)writeDatagrams:(NSArray *)arg1 {
     NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:[arg1 count]];
    for (NSInteger i = 0; i < arg1.count; i++) {
        [array addObject:@(2)]; // 初始化协议数组
    }
    
    [self.packetFlow writePackets:arg1 withProtocols:array];
}

- (BOOL)shouldHandlePacketForDestIP:(unsigned int)arg1 {
    return YES;
}

- (void)readPacketFlow {
    [self.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        [self readPacketFlow];
        
        if (self.reasserting) {
            NSLog(@"Received packet while reasserting, drop");
        }
        else
        {
            [packets enumerateObjectsUsingBlock:^(NSData * data, NSUInteger idx, BOOL * stop) {
                
                if ([protocols[idx] intValue] != 2)//AF_INET
                {
                    NSLog(@"Received unknown protocol: %d",[protocols[idx] intValue]);
                    return;
                }
                
                // TODO
                // 这里处理各种数据包
//                do
//                {
//                    v19 = 0;
//                    do
//                    {
//                        if ( *v54 != v49 )
//                            objc_enumerationMutation(v48);
//                        v27 = *(_DWORD *)(v53 + 4 * v19);
//                        v28 = objc_msgSend(v9, "objectAtIndexedSubscript:", v50 + v19);
//                        v29 = (void *)objc_retainAutoreleasedReturnValue(v28);
//                        v30 = objc_msgSend(v29, "intValue");
//                        objc_release(v29);
//                        if ( v30 != (void *)2 )
//                        {
//                            sub_1259C(2, *(_DWORD *)(v3 + 20), (int)CFSTR("Received unknown protocol: %d"), (int)v30);
//                            goto LABEL_29;
//                        }
//                        v31 = (void *)objc_retainAutorelease(v27);
//                        v32 = v31;
//                        v33 = objc_msgSend(v31, "bytes");
//                        v34 = v33[4];
//                        v35 = *((_BYTE *)v33 + 9);
//                        if ( v34 == dword_5C3FC )
//                        {
//                            v22 = *(_DWORD *)(v3 + 20);
//                            v20 = 16;
//                            v21 = CFSTR("Receive packet to self: type %d, drop");
//                            goto LABEL_14;
//                        }
//                        if ( v34 != dword_5C404 )
//                        {
//                            if ( v34 == dword_5C400 )
//                            {
//                                v22 = *(_DWORD *)(v3 + 20);
//                                if ( v35 == 17 )
//                                {
//                                    v37 = objc_msgSend(*(void **)(v3 + 20), "ipLayerDNSForwarder");
//                                    v38 = (void *)objc_retainAutoreleasedReturnValue(v37);
//                                    v39 = "incomingDNSQuery:";
//                                    v40 = (int)v38;
//                                    goto LABEL_26;
//                                }
//                                v20 = 2;
//                                v21 = CFSTR("WARNING! Drop non-UDP packet: type %d");
//                            }
//                            else
//                            {
//                                if ( (unsigned int)objc_msgSend(*(void **)(v3 + 20), "shouldHandlePacketForDestIP:", v34) & 0xFF )
//                                {
//                                    if ( v35 == 6 )
//                                    {
//                                    LABEL_25:
//                                        v41 = objc_msgSend(&OBJC_CLASS___STTCPConnectionManager, "sharedInstance");
//                                        v38 = (void *)objc_retainAutoreleasedReturnValue(v41);
//                                        v40 = (int)v38;
//                                        v39 = "incomingData:";
//                                    LABEL_26:
//                                        objc_msgSend(v38, v39, v32);
//                                        v26 = v40;
//                                    }
//                                    else
//                                    {
//                                        v23 = *(_DWORD *)(v3 + 20);
//                                        v24 = objc_msgSend(&OBJC_CLASS___NSString, "stringWithIPAddressUsingNetworkByteOrder:", v34);
//                                        v25 = objc_retainAutoreleasedReturnValue(v24);
//                                        sub_1259C(16, v23, (int)CFSTR("Drop non-TCP packet: type %d, dest: %@"), v35);
//                                        v26 = v25;
//                                    }
//                                    objc_release(v26);
//                                    goto LABEL_28;
//                                }
//                                v22 = *(_DWORD *)(v3 + 20);
//                                v20 = 16;
//                                v21 = CFSTR("Drop unknown packet: type %d");
//                            }
//                        LABEL_14:
//                            v36 = v35;
//                            goto LABEL_19;
//                        }
//                        if ( v35 == 6 )
//                            goto LABEL_25;
//                        sub_1259C(2, *(_DWORD *)(v3 + 20), (int)CFSTR("WARNING! Drop non-TCP packet: type %d"), v35);
//                        v22 = *(_DWORD *)(v3 + 20);
//                        v20 = 2;
//                        v21 = CFSTR("%@");
//                        v36 = (int)v32;
                
            }];

        }
    }];
	
}

- (void)stopByCommand {
    NSLog(@"Stop by Widget");
    [self shutdown];
    
}

- (void)returnDNSResultToSocket:(id)arg1 {
    NSArray *array = [[SGDNSClient sharedInstance]cachedResult];
    dispatch_async(_dispatchQueue, ^{
        [self responseCommand:[NSDictionary dictionaryWithObject:array forKey:@"results"] toSocket:arg1];
    });
}

- (void)returnTrafficUsageToSocket:(id)arg1 {
    if ([SGLogRecordContainer activeLogContainer]) {
        dispatch_async([[SGLogRecordContainer activeLogContainer] dispatch_queue], ^{
            NSArray *array = [[SGLogRecordContainer activeLogContainer]allInterfaceSessionRecord];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               // TODO
                // 流量统计处理
            }];
        });
    }
}

- (void)receiveMessage:(NSDictionary *)arg1 fromSocket:(id)arg2 {
    NSLog(@"Recevice container message: %@",arg1);
    
    if ([arg1[@"command"] isEqual:@"dns-results"]) {
        [self returnDNSResultToSocket:arg2];
    }
    
    if ([arg1[@"command"] isEqual:@"statistics"]) {
        [self returnTrafficUsageToSocket:arg2];
    }
    
    if ([arg1[@"command"] isEqual:@"stop"]) {
        [self stopByCommand];
    }
    
}

- (void)socketDidDisconnect:(SGGCDAsyncSocket *)arg1 withError:(id)arg2 {
    arg1.delegate = nil;
    [_commandSockets removeObject:arg1];
}

- (void)socket:(SGGCDAsyncSocket *)arg1 didReadData:(NSData *)arg2 withTag:(long)arg3 {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[arg2 subdataWithRange:NSMakeRange(0, arg2.length - 4)] options:0 error:0];
    [self receiveMessage:dict fromSocket:arg1];
    [arg1 readDataToData:[NSData dataWithBytesNoCopy:NULL/*这里不正确，是什么？*/ length:4 freeWhenDone:NO] withTimeout:-1 tag:0];
}

- (void)socket:(id)arg1 didAcceptNewSocket:(SGGCDAsyncSocket *)arg2 {
    arg2.delegate = self;
    [_commandSockets addObject:arg2];
    
    [arg1 readDataToData:[NSData dataWithBytesNoCopy:NULL/*这里不正确，是什么？*/ length:4 freeWhenDone:NO] withTimeout:-1 tag:0];
}

- (void)responseCommand:(NSDictionary *)arg1 toSocket:(SGGCDAsyncSocket *)arg2 {
    NSMutableData *data = [[NSJSONSerialization dataWithJSONObject:arg1 options:0 error:nil] mutableCopy];
    [data appendData:[NSData dataWithBytesNoCopy:NULL/*这里不正确，是什么？*/ length:4 freeWhenDone:NO]];
    [arg2 writeData:data withTimeout:-1 tag:0];
}

- (void)setupCommandListener {
    _commandListener = [[SGGCDAsyncSocket alloc]initWithDelegate:self delegateQueue:_dispatchQueue];
    _commandSockets = [NSMutableSet set];
    if (![_commandListener acceptOnInterface:@"127.0.0.1" port:6155 error:nil]) {
        NSLog(@"Error when start command socket: %@",@"");
    }
}


@end