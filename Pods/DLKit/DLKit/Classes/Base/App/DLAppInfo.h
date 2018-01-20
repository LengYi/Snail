//
//  DLAppInfo.h
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLAppInfo : NSObject

+ (NSString *)bundleDisplayName;
+ (NSString *)bundleName;
+ (NSString *)bundleVersion;
+ (NSString *)bundleShortVersion;
+ (NSString *)bundleIdentifier;

@end
