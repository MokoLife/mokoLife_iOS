//
//  MKMQTTServerDataManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/8/18.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 mqtt服务器连接状态改变
 */
extern NSString *const MKMQTTSessionManagerStateChangedNotification;

/*
 接收到开关状态的通知
 */
extern NSString *const MKMQTTServerReceivedSwitchStateNotification;

/*
 接收到倒计时的通知
 */
extern NSString *const MKMQTTServerReceivedDelayTimeNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKMQTTServerReceivedElectricityNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKMQTTServerReceivedFirmwareInfoNotification;

/*
 接收到设备固件升级结果通知
 */
extern NSString *const MKMQTTServerReceivedUpdateResultNotification;

@interface MKMQTTServerDataManager : NSObject

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState state;

+ (MKMQTTServerDataManager *)sharedInstance;

@end
