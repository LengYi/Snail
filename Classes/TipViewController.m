//
//  TipViewController.m
//  PandaHero
//
//  Created by ice on 2017/10/23.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import "TipViewController.h"
#import <Masonry.h>

#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a/1.0]

@interface TipViewController ()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subLabel;
@property (nonatomic,strong) UILabel *customLabel;
@property (nonatomic,strong) UILabel *addressLabel;
@end

@implementation TipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subLabel];
    [self.view addSubview:self.customLabel];
    [self.view addSubview:self.addressLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.size.height.mas_equalTo(27);
    }];
    
    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.size.height.mas_equalTo(50);
    }];
    
    [_customLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(-30);
        make.height.mas_equalTo(20);
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(-10);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:19];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UILabel *)subLabel{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = [UIFont systemFontOfSize:13];
        _subLabel.textColor = RGBA(255, 255, 255, 0.6);
        _subLabel.numberOfLines = 0;
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _subLabel;
}

- (UILabel *)customLabel{
    if (!_customLabel) {
        _customLabel = [[UILabel alloc] init];
        _customLabel.font = [UIFont systemFontOfSize:13];
        _customLabel.textColor = RGBA(255, 255, 255, 0.6);
        _customLabel.numberOfLines = 0;
        _customLabel.backgroundColor = [UIColor clearColor];
        _customLabel.textAlignment = NSTextAlignmentCenter;
        _customLabel.text = @"联系客服";
    }
    
    return _customLabel;
}

- (UILabel *)addressLabel{
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:13];
        _addressLabel.textColor = RGBA(255, 255, 255, 0.6);
        _addressLabel.numberOfLines = 0;
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.textAlignment = NSTextAlignmentCenter;
        _addressLabel.text = @"QQ 4009981389";
    }
    
    return _addressLabel;
}

- (void)showLabelTipWithType:(NSInteger)type{
    switch (type) {
        case 0:{
            _titleLabel.text = @"点击开启保护";
            _subLabel.text = @"您的手机目前处于未保护状态，强烈建议您启动该工具，提升您的应用启动速度和系统稳定性，带来更优质的App体验";
        }
            break;
        case 1:{
            _titleLabel.text = @"启动中..";
            _subLabel.text = @"启动进行中,请耐心等待，并保证网络畅通~";
        }
            break;
        case 2:{
            _titleLabel.text = @"保护中";
            _subLabel.text = @"您的手机目前处于被保护状态，系统稳定，应用启动速度快";
        }
            break;
            
        default:
            break;
    }
}

@end
