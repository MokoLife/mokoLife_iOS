//
//  MKAddDeviceAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKAddDeviceAdopter : NSObject

+ (UILabel *)connectAlertTitleLabel:(NSString *)title;

+ (UILabel *)connectAlertMsgLabel:(NSString *)text;
/**
 跳转到设置->wifi页面
 */
+ (void)gotoSystemWifiPage;

/**
 判断当前网络状态，是否可以进行下一步，当前网络必须是2.4G wifi，wifi SSID前两位不能为MK
 
 @param target 添加设备页面，如果不满足连接条件时，需要在target的view上面提示错误信息
 @return YES:可以下一步，NO:不可以下一步
 */
+ (BOOL)canConnectWithCurrentTarget:(UIViewController *)target;

@end
