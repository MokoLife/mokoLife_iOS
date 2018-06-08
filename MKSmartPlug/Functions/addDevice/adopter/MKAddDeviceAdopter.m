//
//  MKAddDeviceAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceAdopter.h"

//作为当前wifi是否是smartPlug的key，如果当前wifi的ssid前几位为smartPlugWifiSSIDKey，则认为当前已经连接smartPlug
NSString *const smartPlugWifiSSIDKey = @"MOKO";

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
 是否已经连接到plug了，点击连接的时候，必须先连接plug的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给plug之后才进行mqtt服务器的连接

 @return YES:plug,NO:not plug
 */
+ (BOOL)currentWifiIsSmartPlug{
    if ([MKNetworkManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        return NO;
    }
    NSString *wifiSSID = [MKNetworkManager currentWifiSSID];
    if (!ValidStr(wifiSSID) || [wifiSSID isEqualToString:@"<<NONE>>"]) {
        //当前wifi的ssid未知
        return NO;
    }
    if (wifiSSID.length < smartPlugWifiSSIDKey.length) {
        return NO;
    }
    NSString *ssidHeader = [[wifiSSID substringWithRange:NSMakeRange(0, smartPlugWifiSSIDKey.length)] uppercaseString];
    if ([ssidHeader isEqualToString:smartPlugWifiSSIDKey]) {
        return YES;
    }
    return NO;
}

@end
