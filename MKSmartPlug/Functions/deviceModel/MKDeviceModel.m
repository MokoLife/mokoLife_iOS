//
//  MKDeviceModel.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel()

/**
 超过40s没有接收到信息，则认为离线
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

/**
 是否处于离线状态
 */
@property (nonatomic, assign)BOOL offline;

@end

@implementation MKDeviceModel

- (void)dealloc{
    NSLog(@"MKDeviceModel销毁");
}

/**
 订阅的主题

 @param topicType 主题类型，是app发布数据的主题还是设备发布数据的主题
 @param function 主题功能
 @return 设备功能/设备名称/型号/mac/topicType/function
 */
- (NSString *)subscribeTopicInfoWithType:(deviceModelTopicType)topicType
                                function:(NSString *)function{
    NSString *typeIden = (topicType == deviceModelTopicDeviceType ? @"device" : @"app");
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
            self.device_function,
            self.device_name,
            self.device_specifications,
            self.device_mac,
            typeIden,
            function];
}

- (NSArray <NSString *>*)allTopicForDevice{
    NSString *firmware = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"firmware_infor"];
    NSString *electricity = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"electricity_information"];
    NSString *ota = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"];
    NSString *delay = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delay_time"];
    NSString *swicthState = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"switch_state"];
    return @[firmware,electricity,ota,delay,swicthState];
}

- (void)updatePropertyWithModel:(MKDeviceModel *)model{
    if (!model) {
        return;
    }
    self.device_icon = model.device_icon;
    self.device_name = model.device_name;
    self.local_name = model.local_name;
    self.device_state = model.device_state;
    self.device_mac = model.device_mac;
    self.device_specifications = model.device_specifications;
    self.device_function = model.device_function;
    self.device_type = model.device_type;
}

- (void)startStateMonitoringTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.offline = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 62.f) {
            //接受数据超时
            dispatch_cancel(weakSelf.receiveTimer);
            weakSelf.receiveTimerCount = 0;
            weakSelf.offline = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(deviceModelStateChanged:)]) {
                    [weakSelf.delegate deviceModelStateChanged:weakSelf];
                }
            });
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter{
    if (self.offline) {
        //已经离线，重新开启定时器监测
        [self startStateMonitoringTimer];
        return;
    }
    self.receiveTimerCount = 0;
}

/**
 取消定时器
 */
- (void)cancel{
    self.receiveTimerCount = 0;
    self.offline = NO;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
}

@end
