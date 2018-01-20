//
//  UIDevice+name.m
//  Pods
//
//  Created by ice on 17/3/24.
//
//

#import "UIDevice+name.h"
#import "UIDevice+extended.h"

@implementation UIDevice (name)
+ (NSString *)platformName{
    NSString *originStr = [UIDevice platformType];
    NSString *platFormString = nil;
    
    if ([originStr hasPrefix:@"iPhone3"])        platFormString = @"iPhone 4";
    else if ([originStr hasPrefix:@"iPhone4"])   platFormString = @"iPhone 4S";
    
    else if ([originStr isEqualToString:@"iPhone5,1"] ||
             [originStr isEqualToString:@"iPhone5,2"])   platFormString = @"iPhone 5";
    else if ([originStr isEqualToString:@"iPhone5,3"] ||
             [originStr isEqualToString:@"iPhone5,4"])   platFormString = @"iPhone 5C";
    
    else if ([originStr hasPrefix:@"iPhone6"])   platFormString = @"iPhone 5S";
    else if ([originStr isEqualToString:@"iPhone7,2"])   platFormString = @"iPhone 6";
    else if ([originStr isEqualToString:@"iPhone7,1"])   platFormString = @"iPhone 6 Plus";
    
    else if ([originStr hasPrefix:@"iPhone2"])   platFormString = @"iPhone 3GS";
    
    else if ([originStr hasPrefix:@"iPod4"])     platFormString = @"iTouch 4";
    else if ([originStr hasPrefix:@"iPod5"])     platFormString = @"iTouch 5";
    
    else if ([originStr hasPrefix:@"iPad1"])     platFormString = @"iPad1";
    
    else if ([originStr isEqualToString:@"iPad2,1"] ||
             [originStr isEqualToString:@"iPad2,2"] ||
             [originStr isEqualToString:@"iPad2,3"] ||
             [originStr isEqualToString:@"iPad2,4"])     platFormString = @"iPad2";
    
    else if ([originStr isEqualToString:@"iPad2,5"] ||
             [originStr isEqualToString:@"iPad2,6"] ||
             [originStr isEqualToString:@"iPad2,7"] ||
             [originStr isEqualToString:@"iPad4,4"] ||
             [originStr isEqualToString:@"iPad4,5"] ||
             [originStr isEqualToString:@"iPad4,6"] ||
             [originStr isEqualToString:@"iPad4,7"] ||
             [originStr isEqualToString:@"iPad4,8"] ||
             [originStr isEqualToString:@"iPad4,9"]
             )                                          platFormString = @"iPad mini";
    
    else if([originStr isEqualToString:@"iPad4,4"] ||
            [originStr isEqualToString:@"iPad4,5"])       platFormString = @"iPad mini2";
    
    else if ([originStr isEqualToString:@"iPad3,1"] ||
             [originStr isEqualToString:@"iPad3,2"] ||
             [originStr isEqualToString:@"iPad3,3"])     platFormString = @"牛排";
    
    else if([originStr isEqualToString:@"iPad4,1"] ||
            [originStr isEqualToString:@"iPad4,2"] ||
            [originStr isEqualToString:@"iPad4,3"] ||
            [originStr isEqualToString:@"iPad5,3"] ||
            [originStr isEqualToString:@"iPad5,4"]) platFormString = @"iPadAir";
    
    else if ([originStr isEqualToString:@"iPad3,4"] ||
             [originStr isEqualToString:@"iPad3,5"] ||
             [originStr isEqualToString:@"iPad3,6"])     platFormString = @"iPad4";
    
    else if([originStr isEqualToString:@"iPad5,3"] ||
            [originStr isEqualToString:@"iPad5,4"]) platFormString = @"iPad Air 2";
    
    else if ([originStr isEqualToString:@"iPad4,7"] ||
             [originStr isEqualToString:@"iPad4,8"] ||
             [originStr isEqualToString:@"iPad4,9"])  platFormString = @"iPad mini 3";
    
    else if ([originStr isEqualToString:@"iPad5,1"] ||
             [originStr isEqualToString:@"iPad5,2"]) platFormString = @"iPad mini 4";
    
    else if ([originStr isEqualToString:@"iPad6,8"]) platFormString = @"iPad Pro";
    
    else if ([originStr isEqualToString:@"iPhone1,1"])   platFormString = @"iPhone 1G";
    else if ([originStr isEqualToString:@"iPhone1,2"])   platFormString = @"iPhone 3G";
    
    
    else if ([originStr hasPrefix:@"iPod1"])     platFormString = @"iTouch 1";
    else if ([originStr hasPrefix:@"iPod2"])     platFormString = @"iTouch 2";
    else if ([originStr hasPrefix:@"iPod3"])     platFormString = @"iTouch 3";
    
    else if ([originStr hasPrefix:@"iPhone"])      platFormString = @"iPhone"; //没结果默认iPhone
    else if ([originStr hasPrefix:@"iPod"])      platFormString = @"iTouch"; //没结果默认iPod
    else if ([originStr hasPrefix:@"iPad"])        platFormString = @"iPad"; //没结果默认iPad
    
    // 模拟器则认为 最新的 ipad,2,1 或 4s
    else if ([originStr isEqualToString:@"i386"] || [originStr isEqualToString:@"x86_64"])        platFormString =  @"iPadAir";
    
    return platFormString;
}

@end
