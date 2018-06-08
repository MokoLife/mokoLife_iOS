//
//  MKAddDeviceAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

//作为当前wifi是否是smartPlug的key，如果当前wifi的ssid前几位为smartPlugWifiSSIDKey，则认为当前已经连接smartPlug
extern NSString *const smartPlugWifiSSIDKey;

@interface MKAddDeviceAdopter : NSObject

+ (UILabel *)connectAlertTitleLabel:(NSString *)title;

+ (UILabel *)connectAlertMsgLabel:(NSString *)text;
/**
 跳转到设置->wifi页面
 */
+ (void)gotoSystemWifiPage;

/**
 是否已经连接到plug了，点击连接的时候，必须先连接plug的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给plug之后才进行mqtt服务器的连接
 
 @return YES:plug,NO:not plug
 */
+ (BOOL)currentWifiIsSmartPlug;

@end
