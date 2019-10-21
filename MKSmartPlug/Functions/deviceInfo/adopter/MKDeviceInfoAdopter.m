//
//  MKDeviceInfoAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInfoAdopter.h"
#import "MKDeviceDataBaseManager.h"

@implementation MKDeviceInfoAdopter

+ (void)deleteDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target reset:(BOOL)reset{
    if (!deviceModel) {
        return;
    }
    NSString *title = (reset ? @"After reset,the device will be removed from the device list,and relevant data will be totally cleared." : @"Please confirm again whether to remove the devoce.");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:title
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (reset) {
            //恢复出厂设置
            [self resetDeviceWithModel:deviceModel target:target];
            return;
        }
        //移除设备
        [self deleteDeviceModel:deviceModel target:target];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -
+ (void)resetDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        return;
    }
    if (deviceModel.device_mode == MKDevice_plug && deviceModel.plugState == MKSmartPlugOffline) {
        [target.view showCentralToast:@"Device offline,please check."];
        return;
    }
    if (deviceModel.device_mode == MKDevice_swich && deviceModel.swichState == MKSmartSwichOffline) {
        [target.view showCentralToast:@"Device offline,please check."];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected) {
        [target.view showCentralToast:@"Network error,please check."];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Reseting..." inView:target.view isPenetration:NO];
    NSString *topic = [deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"reset"];
    __weak __typeof(&*target)weakTarget = target;
    WS(weakSelf);
    [MKMQTTServerInterface resetDeviceWithTopic:topic sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf deleteDeviceModel:deviceModel target:weakTarget];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

+ (void)deleteDeviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target{
    [[MKHudManager share] showHUDWithTitle:@"Deleting..." inView:target.view isPenetration:NO];
    __weak __typeof(&*target)weakTarget = target;
    [MKDeviceDataBaseManager deleteDeviceWithMacAddress:deviceModel.device_mac sucBlock:^{
        [[MKHudManager share] hide];
        [[MKMQTTServerManager sharedInstance] unsubscriptions:[deviceModel allTopicList]];
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
        [weakTarget.navigationController popToRootViewControllerAnimated:YES];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakTarget.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

@end
