//
//  MKMQTTServerInterface.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"
#import "MKMQTTServerErrorBlockAdopter.h"

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
    if (deviceModel.device_state == smartPlugDeviceOffline) {
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
    if (deviceModel.device_state == smartPlugDeviceOffline) {
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

+ (void)setSmartPlugSwitchState:(BOOL)isOn
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock{
    NSDictionary *dataDic = @{@"switch_state" : (isOn ? @"on" : @"off")};
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)setDelayHour:(NSInteger)delay_hour
            delayMin:(NSInteger)delay_minutes
               topic:(NSString *)topic
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock{
    if (delay_hour < 0 || delay_hour > 23) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (delay_minutes < 0 || delay_minutes > 59) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"delay_hour":@(delay_hour),
                              @"delay_minute":@(delay_minutes),
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)resetDeviceWithTopic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{} topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{} topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)updateFirmware:(MKFirmwareUpdateHostType)hostType
                  host:(NSString *)host
                  port:(NSInteger)port
             catalogue:(NSString *)catalogue
                 topic:(NSString *)topic
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock{
    if (hostType == MKFirmwareUpdateHostTypeIP && ![host isValidatIP]) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (hostType == MKFirmwareUpdateHostTypeUrl && ![host checkIsUrl]) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (port < 0 || port > 65535 || !catalogue) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"type":@(hostType),
                              @"realm":host,
                              @"port":@(port),
                              @"catalogue":catalogue,
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

@end
