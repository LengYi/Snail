//
//  UIDevice+extended.m
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import "UIDevice+extended.h"
#import "AdSupport/AdSupport.h"
#import <sys/sysctl.h>

@implementation UIDevice (extended)

+ (NSString *)idfa{
    ASIdentifierManager *ai = [ASIdentifierManager sharedManager];
    return (ai.advertisingTrackingEnabled) ? ai.advertisingIdentifier.UUIDString : @"";
}

+ (NSString *)idfv{
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

+ (NSString *)currentLanguage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    return currentLanguage;
}

+ (NSString *)platformType{
    NSString *platform = nil;
#if TARGET_IPHONE_SIMULATOR
    platform =  @"iPhone7,1";
#else
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    platform = [NSString stringWithCString:machine encoding: NSUTF8StringEncoding];
    free(machine);
    machine = NULL;
    platform = (platform.length > 0) ? platform : @"";
#endif
    return platform;
}

+ (NSString *)systemVersion{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if (!ver) {
        ver = @"";
    }
    return ver;
}

+ (BOOL)jailbreaked{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    NSArray *arr = @[@"/Applications/Cydia.app",@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/bin/bash",@"/usr/sbin/sshd",@"/etc/apt"];
    for (NSString *jbPath in arr) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:jbPath]) {
            return YES;
        }
    }
    return NO;
#endif
}

@end
