//
//  DLAppInfo.m
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import "DLAppInfo.h"

@implementation DLAppInfo

+ (NSString *)bundleDisplayName{
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!name) {
        name = @"";
    }
    return name;
}

+ (NSString *)bundleName{
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    if (!name) {
        name = @"";
    }
    return name;
}

+ (NSString *)bundleVersion{
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (!ver) {
        ver = @"";
    }
    return ver;
}

+ (NSString *)bundleShortVersion{
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (!ver) {
        ver = @"";
    }
    return ver;
}

+ (NSString *)bundleIdentifier{
    NSString *sku = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if (!sku) {
        sku = @"";
    }
    return sku;
}

@end
