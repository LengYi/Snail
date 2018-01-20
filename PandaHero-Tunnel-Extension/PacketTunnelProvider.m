//
//  PacketTunnelProvider.m
//  PandaHero-Tunnel-Extension
//
//  Created by lemon4ex on 16/5/29.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "SNLNetworkInterfaceManager.h"
#import <net/if.h>
#import <mach/mach.h>
#import "HTTPProxyServer.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

@interface PacketTunnelProvider ()
{
    dispatch_queue_t _dispatchQueue;
    dispatch_source_t _memoryWarningSource;
    HTTPProxyServer *_proxyServer;
}

@end

@implementation PacketTunnelProvider

- (void)logMemoryUsage
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    
    if (kernReturn == KERN_SUCCESS ) {
        DDLogInfo(@"Memory in use: %.2fMB",taskInfo.resident_size / 1024.0 / 1024.0);
    }
}

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *securityPath = [fileMgr containerURLForSecurityApplicationGroupIdentifier:@"group.netex.ex"].path;
    NSString *logsDirectory = [securityPath stringByAppendingPathComponent:@"Logs"];
    
    [fileMgr removeItemAtPath:logsDirectory error:nil];
    [fileMgr createDirectoryAtPath:logsDirectory withIntermediateDirectories:YES attributes:nil error:nil];

    DDLogFileManagerDefault *defaultLogFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:defaultLogFileManager]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    DDLogInfo(@"Starting tunnel...");
    
    _dispatchQueue = dispatch_queue_create("PacketTunnelProviderQueue", NULL);
    _memoryWarningSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_MEMORYPRESSURE, 0, DISPATCH_MEMORYPRESSURE_CRITICAL, _dispatchQueue);
    dispatch_source_set_event_handler(_memoryWarningSource, ^{
        dispatch_source_memorypressure_flags_t pressureLevel = dispatch_source_get_data(_memoryWarningSource);
        DDLogInfo(@"Received memory warning, level: %lu",pressureLevel);
        // TODO:释放无用内存
    });
    
    dispatch_resume(_memoryWarningSource);
    
    [self logMemoryUsage];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkInterfaceDidChange:) name:SNLNetworkInterfaceManagerInterfaceDidChange object:nil];
 
    dispatch_async(_dispatchQueue, ^{
        
        [self addObserver:self forKeyPath:@"defaultPath" options:0 context:NULL];
        
        [self startConnectionWithCompletionHandler:completionHandler];
    });
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler{
    [_proxyServer stop];
	completionHandler();
    exit(EXIT_SUCCESS);
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
	// Add code here to handle the message.
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
	// Add code here to get ready to sleep.
	completionHandler();
}

- (void)wake
{
	// Add code here to wake up.
}

#pragma mark -
- (void)setupHTTPProxy
{
    _proxyServer = [[HTTPProxyServer alloc]init];
    [_proxyServer start];
}

- (void)startConnectionWithCompletionHandler:(void (^)(NSError * __nullable error))completionHandler {
    
    NEPacketTunnelNetworkSettings *settings = [self prepareTunnelNetworkSettings];
    __weak typeof(self) weakSelf = self;
    
    [self setTunnelNetworkSettings:settings completionHandler:^(NSError * __nullable error) {
        if (error)  {
            DDLogInfo(@"Error occurred while setTunnelNetworkSettings: %@", error);
            completionHandler(error);
        } else {
            completionHandler(nil);
            dispatch_async(_dispatchQueue, ^{
                [[SNLNetworkInterfaceManager sharedInstance] monitorInterfaceChange];
                [weakSelf setupHTTPProxy];
            });
        }
    }];
}

- (NEPacketTunnelNetworkSettings *)prepareTunnelNetworkSettings {
    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"240.40.40.40"];
//    settings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"240.0.0.1"]
//                                                          subnetMasks:@[@"255.0.0.0"]];
//    NSMutableArray *includedRoutes = [NSMutableArray array];
//    
//    [includedRoutes addObject:[NEIPv4Route defaultRoute]];
//    
//    [includedRoutes addObject:[[NEIPv4Route alloc] initWithDestinationAddress:@"240.40.40.40" subnetMask:@"255.0.0.0"]];
//    
//    settings.IPv4Settings.includedRoutes = includedRoutes;
//    settings.MTU = @(1400);
    
    NEProxySettings *proxySettings = [[NEProxySettings alloc]init];
    proxySettings.HTTPEnabled = YES;
    proxySettings.HTTPServer = [[NEProxyServer alloc]initWithAddress:@"127.0.0.1" port:6538];
    proxySettings.HTTPSEnabled = YES;
    proxySettings.HTTPSServer = [[NEProxyServer alloc]initWithAddress:@"127.0.0.1" port:6538];
    proxySettings.matchDomains = @[@"ocsp.apple.com"];
    
    settings.proxySettings = proxySettings;
    
    return settings;
}

#pragma mark - 通知
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *,id> *)change
                       context:(nullable void *)context {

    if (object && object == self && [keyPath isEqualToString:@"defaultPath"]) {
        if (self.defaultPath.status == NWPathStatusSatisfied) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startTunnelWithOptions:nil completionHandler:^(NSError * _Nullable error) {
                    
                }];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//- (void)networkInterfaceDidChange:(NSNotification *)notification
//{
//    DDLogInfo(@"Interface did change!");
//    dispatch_async(_dispatchQueue, ^{
//        
//        self.reasserting = YES;
//        //        [self releaseUDPSession];
//        //        [self releaseDNSServer];
////        [self releaseHttpServer];
//        [_proxyServer stop];
//        
//        [self setTunnelNetworkSettings:nil completionHandler:^(NSError * _Nullable error) {
//            if (error)  {
//                DDLogInfo(@"Error occurred while setTunnelNetworkSettings: %@", error);
//                [self cancelTunnelWithError:error];
//            } else {
//                dispatch_async(_dispatchQueue, ^{
//                    [self startConnectionWithCompletionHandler:^(NSError * _Nullable error) {
//                        if (error) {
//                            [self cancelTunnelWithError:error];
//                        } else {
//                            [self setReasserting:NO];
//                        }
//                    }];
//                });
//            }
//        }];
//    });
//}

@end

#pragma clang diagnostic pop
