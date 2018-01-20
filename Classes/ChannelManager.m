//
//  ChannelManager.m
//  PandaHero
//
//  Created by ice on 2017/10/30.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import "ChannelManager.h"
#import <DLHttp.h>
#import <UIDevice+extended.h>
#import <DLAppInfo.h>

@implementation ChannelManager

/**
 * 比较版本号
 *
 * @param v1 第一个版本号
 * @param v2 第二个版本号
 *
 * @return 如果版本号相等，返回 0,
 *         如果第一个版本号低于第二个，返回 -1，否则返回 1.
 */
int compareVersion(const char *v1, const char *v2){
    const char *p_v1 = v1;
    const char *p_v2 = v2;
    
    while (*p_v1 && *p_v2) {
        char buf_v1[32] = {0};
        char buf_v2[32] = {0};
        
        char *i_v1 = strchr(p_v1, '.');
        char *i_v2 = strchr(p_v2, '.');
        
        if (!i_v1 || !i_v2) break;
        
        if (i_v1 != p_v1) {
            strncpy(buf_v1, p_v1, i_v1 - p_v1);
            p_v1 = i_v1;
        }
        else
            p_v1++;
        
        if (i_v2 != p_v2) {
            strncpy(buf_v2, p_v2, i_v2 - p_v2);
            p_v2 = i_v2;
        }
        else
            p_v2++;
        
        
        
        int order = atoi(buf_v1) - atoi(buf_v2);
        if (order != 0)
            return order < 0 ? -1 : 1;
    }
    
    double res = atof(p_v1) - atof(p_v2);
    
    if (res < 0) return -1;
    if (res > 0) return 1;
    return 0;
}

+ (BOOL)isiPad{
    NSString *deviceName = [UIDevice platformType];
    return [deviceName hasPrefix:@"iPad"];
}

//+ (NSString *)channelUrl:(void(^)(NSString *url))block{
//    NSString *devideID = @"1";
//    NSString *channel = @"%e5%9c%a8%e7%ba%bf%e5%ae%89%e8%a3%85%e4%bc%81%e7%ad%be_1_z";
//    if ([ChannelManager isiPad]) {
//        devideID = @"2";
//        channel = @"%e5%9c%a8%e7%ba%bf%e5%ae%89%e8%a3%85%e4%bc%81%e7%ad%be_2_z";
//    }
//    NSString *url = [NSString stringWithFormat:@"http://config.tongbu.com/tbtui/tuiver.ashx?deviceid=%@&tuitype=sign&channel=%@&channel_ext=tuizx.tongbu.com",devideID,channel];
//    [DLHttp synWithGetURLString:url
//                withHeaderField:nil
//            withTimeoutInterval:0
//                   shouldEncode:NO completionHandler:^(NSData *data, NSError *error, NSHTTPURLResponse *response) {
//                       if (!error) {
//                           if (data) {
//                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                               if (dict) {
//                                   NSArray *arr = dict[@"tbtui"];
//                                   if (arr && arr.count > 0) {
//                                       NSDictionary *dd = arr[0];
//                                       NSString *plist = dd[@"plistRandomSku"];
//                                       NSLog(@"str = %@",plist);
//                                       if (!plist) {
//                                           plist = @"";
//                                       }
//                                       block(plist);
//                                   }
//                               }
//                           }
//                       }
//                   }];
//    return nil;
//}

+ (void)updateApp:(void(^)(BOOL shouldUpdate,NSString *plist))block{
    
    NSString *chan = @"apphero"; //apphero 防闪退工具国内版  pandahero防闪退工具海外版
    
    NSString *url = [NSString stringWithFormat:@"http://config.tongbu.com/kkzs/kkver.ashx?deviceid=1&tuitype=sign&pt=%@&channel=%@&channel_ext=tuizx.tongbu.com",chan,chan];
    [DLHttp asynWithGetURLString:url
                withHeaderField:nil
            withTimeoutInterval:0
                 withForeground:YES
                   shouldEncode:NO
              completionHandler:^(NSData *data, NSError *error, NSHTTPURLResponse *response) {
                  if (!error) {
                      if (data) {
                          NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                          if (dict) {
                              NSDictionary *resultDic = dict[@"tbtui"][0];
                              if (resultDic) {
                                  NSString *ver = resultDic[@"version"];
                                  NSString *curVer = [DLAppInfo bundleShortVersion];
                                  NSString *plist = resultDic[@"plistRandomSku"];
                                  if (!ver) {
                                      ver = @"1.0.0";
                                  }
#if DEBUG
                                  NSLog(@"--- %@",dict);
                                  NSLog(@"服务器本号 %@,客户端版本号 %@",ver,curVer);
#endif
                                  if (compareVersion([ver UTF8String],[curVer UTF8String]) == 1) {
#if DEBUG
                                      NSLog(@"升级");
#endif
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          block(YES,plist);
                                      });
                                      
                                  }else
                                  {
#if DEBUG
                                      NSLog(@"不升级");
#endif
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          block(NO,nil);
                                      });
                                  }
                              }
                          }
                      }
                  }
              }];
}


+ (BOOL)checkApp:(UIViewController *)vc{
    NSString *schemel = @"tbtuivpn://"; // iPhone
    if ([ChannelManager isiPad]) {
        schemel = @"tbtuivpnhd://";  // HD
    }
    
    NSURL *url = [NSURL URLWithString:schemel];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请先安装同步推"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    NSString *openUrl = @"http://tui.tongbu.com/m/";
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
                                                }]];
        
        [vc presentViewController:alert animated:YES completion:^{
            
        }];
        return NO;
    }
    
    return YES;
}


@end
