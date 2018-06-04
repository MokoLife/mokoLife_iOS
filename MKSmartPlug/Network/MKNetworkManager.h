//
//  MKNetworkManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

//当前网络状态发生改变通知
extern NSString *const MKNetworkStatusChangedNotification;

@interface MKNetworkManager : NSObject

@property(nonatomic, assign, readonly)AFNetworkReachabilityStatus currentNetStatus;//当前网络状态

+ (MKNetworkManager *)sharedInstance;

/**
 获取当前手机连接的wifi SSID
 
 @return SSID
 */
+ (NSString *)fetchWifiSSID;

@end
