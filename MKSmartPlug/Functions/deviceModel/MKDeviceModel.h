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

@protocol MKDeviceModelDelegate;
@interface MKDeviceModel : MKBaseDataModel

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

/**
 设备类型，现在分为带计电量和不带两种
 */
@property (nonatomic, copy)NSString *device_type;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKDeviceModelDelegate>delegate;

/**
 是否处于离线状态
 */
@property (nonatomic, assign, readonly)BOOL offline;

/**
 订阅的主题

 @return 设备功能/设备名称/型号/mac/device/#
 */
- (NSString *)subscribeTopicInfo;

/**
 发布主题，注意，这个只是精确到设备功能/设备名称/型号/mac/app这一级，具体的得加上功能位
 
 @return 设备功能/设备名称/型号/mac/app/
 */
- (NSString *)sendDataTopic;

- (void)updatePropertyWithModel:(MKDeviceModel *)model;

/**
 设备列表页面的状态监控
 */
- (void)startStateMonitoringTimer;

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter;

/**
 取消定时器
 */
- (void)cancel;

@end

@protocol MKDeviceModelDelegate <NSObject>

@optional
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel;

@end
