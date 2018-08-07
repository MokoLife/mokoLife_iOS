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

@end
