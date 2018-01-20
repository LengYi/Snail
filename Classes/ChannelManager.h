//
//  ChannelManager.h
//  PandaHero
//
//  Created by ice on 2017/10/30.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChannelManager : NSObject
+ (BOOL)checkApp:(UIViewController *)vc;
+ (BOOL)isiPad;
+ (void)updateApp:(void(^)(BOOL shouldUpdate,NSString *plist))block;

@end
