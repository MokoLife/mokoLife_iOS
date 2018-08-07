//
//  MKDeviceListAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceListAdopter.h"
#import "MKConfigServerController.h"
#import "MKSelectDeviceTypeController.h"
#import "MKConfigServerModel.h"

@implementation MKDeviceListAdopter

+ (void)addDeviceButtonPressed:(UIViewController *)target{
    if (![[MKMQTTServerConnectManager sharedInstance].configServerModel needParametersHasValue]) {
        //如果app的mqtt服务器信息没有，则去设置
        MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
        vc.controllerType = MKConfigServerForApp;
        [target.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (![[MKSmartPlugConnectManager sharedInstance].configServerModel needParametersHasValue]) {
        //如果设置给plug的mqtt服务器信息没有，去设置
        MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
        vc.controllerType = MKConfigServerForSmartPlug;
        [target.navigationController pushViewController:vc animated:YES];
        return;
    }
    //如果都有了，则去添加设备
    MKSelectDeviceTypeController *vc = [[MKSelectDeviceTypeController alloc] initWithNavigationType:GYNaviTypeShow];
    vc.isPrensent = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [kAppRootController presentViewController:nav animated:YES completion:nil];
}

@end
