//
//  MKDeviceModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceNormalDefines.h"

@interface MKDeviceModel : NSObject<MKDeviceModelProtocol>

/**
 设备类型，目前有插座和面板
 */
@property (nonatomic, assign)MKDeviceType device_mode;

/**
 保存的时候的设备icon名字
 */
@property (nonatomic, copy)NSString *device_icon;

/**
 设备返回的plug名字
 */
@property (nonatomic, copy)NSString *device_name;

/**
 用户手动添加的在设备列表页面显示的设备名字，device_name是plug自己定义的并且不可修改的字段。如果用户没有添加这个local_name，那么默认的值就是xxxx
 */
@property (nonatomic, copy)NSString *local_name;

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

/**
 设备类型，
 1、智能插座:现在分为带计电量和不带两种
 2、智能面板:一路开关、两路开关、三路开关
 */
@property (nonatomic, copy)NSString *device_type;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKDeviceModelDelegate>delegate;

@end
