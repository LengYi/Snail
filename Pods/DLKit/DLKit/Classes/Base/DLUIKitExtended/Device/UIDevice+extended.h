//
//  UIDevice+extended.h
//  DLKit
//
//  Created by ice on 17/3/23.
//  Copyright © 2017年 707689817@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (extended)

+ (NSString *)idfa;
+ (NSString *)idfv;
+ (NSString *)currentLanguage;
+ (NSString *)platformType;
+ (NSString *)systemVersion;
+ (BOOL)jailbreaked;

@end
