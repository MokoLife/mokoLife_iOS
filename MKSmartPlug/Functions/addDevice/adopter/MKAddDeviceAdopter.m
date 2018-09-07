//
//  MKAddDeviceAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceAdopter.h"

@implementation MKAddDeviceAdopter

+ (UILabel *)connectAlertTitleLabel:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DEFAULT_TEXT_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = MKFont(18.f);
    titleLabel.numberOfLines = 0;
    titleLabel.text = title;
    return titleLabel;
}

+ (UILabel *)connectAlertMsgLabel:(NSString *)text{
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.font = MKFont(15.f);
    msgLabel.numberOfLines = 0;
    msgLabel.text = text;
    return msgLabel;
}

/**
 跳转到设置->wifi页面
 */
+ (void)gotoSystemWifiPage{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
        return;
    }
    //低于10
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
