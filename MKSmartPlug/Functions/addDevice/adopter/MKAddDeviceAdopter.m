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
    if (@available(iOS 11.0, *)) {
        NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url2 options:@{} completionHandler:nil];
        return;
    }
    NSURL *url1 = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url1]){
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url1 options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url1];
        }
    }
}

/**
 判断当前网络状态，是否可以进行下一步，当前网络必须是2.4G wifi，wifi SSID前两位不能为MK
 
 @param target 添加设备页面，如果不满足连接条件时，需要在target的view上面提示错误信息
 @return YES:可以下一步，NO:不可以下一步
 */
+ (BOOL)canConnectWithCurrentTarget:(UIViewController *)target{
    if ([MKNetworkManager sharedInstance].currentNetStatus == AFNetworkReachabilityStatusUnknown
        || [MKNetworkManager sharedInstance].currentNetStatus == AFNetworkReachabilityStatusNotReachable) {
        [target.view showCentralToast:@"Please Connect Wi-Fi First."];
        return NO;
    }
    if ([MKNetworkManager sharedInstance].currentNetStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        [target.view showCentralToast:@"This app is supported only on 2.4GHz Wi-Fi network,please reselect."];
        return NO;
    }
    if ([MKNetworkManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        [target.view showCentralToast:@"Please Connect Wi-Fi First."];
        return NO;
    }
    NSString *wifiSSID = [MKNetworkManager fetchWifiSSID];
    if (!ValidStr(wifiSSID) || [wifiSSID isEqualToString:@"<<NONE>>"]) {
        //当前wifi的ssid未知
        [target.view showCentralToast:@"Get wifi ssid errors"];
        return NO;
    }
    if (wifiSSID.length >= 2) {
        NSString *ssidHeader = [[wifiSSID substringWithRange:NSMakeRange(0, 2)] uppercaseString];
        if ([ssidHeader isEqualToString:@"MK"]) {
            [target.view showCentralToast:@"The Wi-Fi cannot be the same as plug hotpot,please reselect."];
            return NO;
        }
    }
    return YES;
}

@end
