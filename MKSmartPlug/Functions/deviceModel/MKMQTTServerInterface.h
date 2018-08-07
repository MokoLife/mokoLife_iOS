//
//  MKMQTTServerInterface.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMQTTServerInterface : NSObject

/**
 改变开关状态
 
 @param isOn isOn
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setSwitchState:(BOOL)isOn deviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target;

/**
 设置延时功能

 @param hour 延时时
 @param minutes 延时分
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setDelayHour:(NSString *)hour
             minutes:(NSString *)minutes
         deviceModel:(MKDeviceModel *)deviceModel
              target:(UIViewController *)target;

@end
