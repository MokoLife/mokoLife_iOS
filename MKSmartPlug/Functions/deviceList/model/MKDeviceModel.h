//
//  MKDeviceModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseDataModel.h"

typedef NS_ENUM(NSInteger, smartPlugDeviceState) {
    smartPlugDeviceOffline,             //离线状态
    smartPlugDeviceOn,                  //在线并且打开
    smartPlugDeviceStatusOff,           //在线并且关闭
};

@interface MKDeviceModel : MKBaseDataModel

/**
 保存的时候的设备icon名字
 */
@property (nonatomic, copy)NSString *device_icon;

/**
 plug名字
 */
@property (nonatomic, copy)NSString *device_name;

/**
 当前设备的状态，离线、开、关
 */
@property (nonatomic, assign)smartPlugDeviceState device_state;

/**
 设备id，plug的mac address
 */
@property (nonatomic, copy)NSString *device_mac;

/**
 规格，国标cn/美规us/英规bu/欧规eu
 */
@property (nonatomic, copy)NSString *device_specifications;

/**
 设备功能
 */
@property (nonatomic, copy)NSString *device_function;

@end
