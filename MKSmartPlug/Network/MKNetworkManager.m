//
//  MKNetworkManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNetworkManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NSString *const MKNetworkStatusChangedNotification = @"MKNetworkStatusChangedNotification";

@interface MKNetworkManager()

@property(nonatomic, assign)AFNetworkReachabilityStatus currentNetStatus;//当前网络状态

@end

@implementation MKNetworkManager

+ (MKNetworkManager *)sharedInstance{
    static MKNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKNetworkManager new];
            [manager startMonitoring];
        }
    });
    return manager;
}

#pragma mark - public method

/**
 获取当前手机连接的wifi ssid
 
 @return wifi ssid
 */
+ (NSString *)currentWifiSSID{
    CFArrayRef tempArray = CNCopySupportedInterfaces();
    if (!tempArray) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    NSDictionary* wifiDic = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(tempArray, 0));
    NSLog(@"%@",wifiDic);
    if (!ValidDict(wifiDic)) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    CFRelease(tempArray);
    return wifiDic[@"SSID"];
}

#pragma mark 网络监听相关方法
- (void)startMonitoring{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        self.currentNetStatus = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNetworkStatusChangedNotification object:nil];
    }];
    [mgr startMonitoring];
}

@end
