//
//  ViewController.m
//  PandaHero
//
//  Created by lemon4ex on 16/5/29.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import <Masonry.h>
#import "TipViewController.h"
#import <UIImage+GIF.h>
#import "ChannelManager.h"

#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a/1.0]
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()
{
    NETunnelProviderManager *_manager;
}
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *connectButton;
@property (nonatomic,strong) TipViewController *tipVC;
@property (nonatomic,strong) UIImageView *gifView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = RGBA(46,54,72,1);
    self.navigationItem.title = @"PandaHeros";
    
    // 顶部标题
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(38);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 27));
    }];
    
    // VPN连接按钮
    [self.view addSubview:self.connectButton];
    CGFloat width = [UIScreen mainScreen].bounds.size.width * 0.6;
    [_connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat offsetY = 70;
        if ([ChannelManager isiPad]) {
            offsetY = 50;
        }
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel).with.offset(offsetY);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    
    // Gif动画 默认不显示
    [self.view addSubview:self.gifView];
    width = [UIScreen mainScreen].bounds.size.width * 0.6;
    [self.gifView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.connectButton.mas_centerX);
        make.centerY.equalTo(self.connectButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];

    self.gifView.hidden = YES;
    
    // 提示语
    [self.view addSubview:self.tipVC.view];
    [_tipVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
         CGFloat offsetY = 55;
        if ([ChannelManager isiPad]) {
            offsetY = 40;
        }
        make.top.mas_equalTo(_connectButton.mas_bottom).with.offset(offsetY);
        make.left.equalTo(self.view).with.offset(40);
        make.right.equalTo(self.view).with.offset(-40);
        make.bottom.equalTo(self.view);
    }];
    [_tipVC showLabelTipWithType:0];
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * managers, NSError * error) {
        if (managers.count > 0) {
            _manager = managers[0];
            [self delDupConfig:managers];
        } else {
            _manager = [[NETunnelProviderManager alloc] init];
        }
        
        [self applicationDidBecomeActive];
    }];
    
    [self addNotification];
    
    [ChannelManager updateApp:^(BOOL shouldUpdate, NSString *plist) {
        if (shouldUpdate && plist) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"检测到新版本是否升级?"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 NSString *str = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",plist];
                                                                 NSURL *url = [NSURL URLWithString:str];
                                                                 [[UIApplication sharedApplication] openURL:url];
                                                             }];
            [alertVC addAction:cancelAction];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

- (void)dealloc{
    [self removeNofification];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:19];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"防闪退工具";
    }
    return _titleLabel;
}

- (UIButton *)connectButton{
    if (!_connectButton) {
        _connectButton = [UIButton buttonWithType:0];
        [_connectButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
        //[_connectButton setTitle:@"连接" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _connectButton;
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(VPNManagerStatusChanged)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNofification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImageView *)gifView{
    if (!_gifView) {
        _gifView = [[UIImageView alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"start" ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage sd_animatedGIFWithData:data];
        _gifView.image = image;
    }
    return _gifView;
}

- (TipViewController *)tipVC{
    if (!_tipVC) {
        _tipVC = [[TipViewController alloc] init];
    }
    
    return _tipVC;
}

- (void)applicationDidBecomeActive {
    [_manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        [self VPNManagerStatusChanged];
    }];
}

- (void)VPNManagerStatusChanged {
#if DEBUG
    NSLog(@"VPNManagerStatusChanged: %ld", (long)_manager.connection.status);
#endif
    _gifView.hidden = YES;
    [_connectButton setImage:[UIImage imageNamed:@"bg"] forState:UIControlStateNormal];
    switch (_manager.connection.status) {
        case NEVPNStatusInvalid:   // 0
            [_tipVC showLabelTipWithType:0]; // 请启动保护
            break;
        case NEVPNStatusDisconnected:   // 1 连接已断开
            [_tipVC showLabelTipWithType:0]; // 请启动保护
            break;
        case NEVPNStatusDisconnecting: // 5 连接断开中
            break;
        case NEVPNStatusConnecting:
            [_tipVC showLabelTipWithType:1]; // 保护启动中
            break;
        case NEVPNStatusReasserting:
            [_tipVC showLabelTipWithType:1]; // 保护启动中
            break;
        case NEVPNStatusConnected:
            _gifView.hidden = NO;
            [_connectButton setImage:nil forState:UIControlStateNormal];
            [_tipVC showLabelTipWithType:2]; // 保护中
            break;
    }
    
}

- (void)delDupConfig:(NSArray *)arr{
    if (arr.count > 1) {
        for (NETunnelProviderManager *manager in arr) {
            [manager removeFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)connect {
    if (_manager.connection.status == NEVPNStatusDisconnected ||_manager.connection.status == NEVPNStatusInvalid) {
        
        if (![ChannelManager checkApp:self]) {
            return;
        }
        
        [_tipVC showLabelTipWithType:1];
        
        NETunnelProviderProtocol *protocol = [[NETunnelProviderProtocol alloc] init];
        protocol.serverAddress = @"192.168.2.3";
        _manager.protocolConfiguration = protocol;
        _manager.enabled = YES;
        _manager.onDemandEnabled = YES;
        NEOnDemandRuleConnect *demand = [[NEOnDemandRuleConnect alloc] init];
        _manager.onDemandRules = @[demand];
        
        [_manager saveToPreferencesWithCompletionHandler:^(NSError * __nullable error) {
            if (error) {
#if DEBUG
                NSLog(@"Error when saveToPreferencesWithCompletionHandler: %@", error);
#endif
                [_tipVC showLabelTipWithType:0];
                return;
            }
            
            [_manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error){
                NSError *startError = nil;
                if (![_manager.connection startVPNTunnelWithOptions:nil andReturnError:&startError]) {
#if DEBUG
                    NSLog(@"Start error: %@", startError);
#endif
                }
            }];
        }];
    }
}

@end
