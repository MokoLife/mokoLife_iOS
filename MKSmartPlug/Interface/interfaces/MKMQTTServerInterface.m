//
//  MKMQTTServerInterface.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

@implementation MKMQTTServerInterface

/**
 改变开关状态

 @param isOn isOn
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setSwitchState:(BOOL)isOn deviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        return;
    }
    if (deviceModel.device_mode == MKDevice_plug && deviceModel.plugState == MKSmartPlugOffline) {
        [target.view showCentralToast:@"Device offline,please check."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:target.view isPenetration:NO];
    NSString *topic = [deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"switch_state"];
    __weak __typeof(&*target)weakTarget = target;
    [self setSmartPlugSwitchState:isOn topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

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
              target:(UIViewController *)target{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        return;
    }
    if (deviceModel.device_mode == MKDevice_plug && deviceModel.plugState == MKSmartPlugOffline) {
        [target.view showCentralToast:@"Device offline,please check."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:target.view isPenetration:NO];
    NSString *topic = [deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"delay_time"];
    __weak __typeof(&*target)weakTarget = target;
    [self setDelayHour:[hour integerValue] delayMin:[minutes integerValue] topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

@end
