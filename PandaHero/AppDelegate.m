//
//  AppDelegate.m
//  PandaHero
//
//  Created by lemon4ex on 16/5/29.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "AppDelegate.h"
#import <UMMobClick/MobClick.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UMAnalyticsConfig *conf = [UMAnalyticsConfig sharedInstance];
    conf.appKey = @"59f6d921aed17910bb000065";
    conf.channelId = @"VPN_TOOL";
    [MobClick startWithConfigure:conf];
#if DEBUG
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *securityPath = [fileMgr containerURLForSecurityApplicationGroupIdentifier:@"group.netex.ex"].path;
    NSString *logsDirectory = [securityPath stringByAppendingPathComponent:@"Logs"];
    NSArray *logs = [fileMgr contentsOfDirectoryAtPath:logsDirectory error:nil];
    for (NSString *name in logs) {
        NSString *path = [logsDirectory stringByAppendingPathComponent:name];
        NSLog(@"path %@",path);
        NSString *log = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
        NSLog(@"\n%@",log);
    }
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
