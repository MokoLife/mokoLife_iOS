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
 获取当前手机连接的wifi ssid,注意:目前公司设备的ssid前两位为mk(MK)
 
 @return wifi ssid
 */
+ (NSString *)currentWifiSSID;

/**
 当前网络是否可用
 
 @return YES:可用，NO:不可用
 */
- (BOOL)currentNetworkAvailable;
/**
 当前网络是否是wifi
 
 @return YES:wifi，NO:非wifi
 */
- (BOOL)currentNetworkIsWifi;

/**
 是否已经连接到plug了，点击连接的时候，必须先连接plug的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给plug之后才进行mqtt服务器的连接
 
 @return YES:plug,NO:not plug
 */
- (BOOL)currentWifiIsSmartPlug;

@end
