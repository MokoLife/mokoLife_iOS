//
//  MKMQTTServerDataManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/8/18.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerDataManager.h"

NSString *const MKMQTTSessionManagerStateChangedNotification = @"MKMQTTSessionManagerStateChangedNotification";

NSString *const MKMQTTServerReceivedSwitchStateNotification = @"MKMQTTServerReceivedSwitchStateNotification";
NSString *const MKMQTTServerReceivedDelayTimeNotification = @"MKMQTTServerReceivedDelayTimeNotification";
NSString *const MKMQTTServerReceivedElectricityNotification = @"MKMQTTServerReceivedElectricityNotification";
NSString *const MKMQTTServerReceivedFirmwareInfoNotification = @"MKMQTTServerReceivedFirmwareInfoNotification";
NSString *const MKMQTTServerReceivedUpdateResultNotification = @"MKMQTTServerReceivedUpdateResultNotification";

@interface MKMQTTServerDataManager()<MKMQTTServerManagerDelegate>

@property (nonatomic, assign)MKMQTTSessionManagerState state;

@end

@implementation MKMQTTServerDataManager

- (instancetype)init{
    if (self = [super init]) {
//        [MKMQTTServerManager sharedInstance].delegate = self;
    }
    return self;
}

+ (MKMQTTServerDataManager *)sharedInstance{
    static MKMQTTServerDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MKMQTTServerDataManager alloc] init];
        }
    });
    return manager;
}

#pragma mark - MKMQTTServerManagerDelegate
- (void)mqttServerManagerStateChanged:(MKMQTTSessionManagerState)state{
    self.state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTSessionManagerStateChangedNotification object:nil];
}

- (void)sessionManager:(MKMQTTServerManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic{
    if (!topic) {
        return;
    }
    NSArray *keyList = [topic componentsSeparatedByString:@"/"];
    if (keyList.count != 6) {
        return;
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!dataString) {
        return;
    }
    //    NSDictionary *dataDic = [NSString dictionaryWithJsonString:dataString];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (!dataDic || dataDic.allValues.count == 0) {
        return;
    }
    NSString *macAddress = keyList[3];
    NSString *function = keyList[5];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
    [tempDic setObject:macAddress forKey:@"mac"];
    [tempDic setObject:function forKey:@"function"];
    NSLog(@"接收到数据:%@",tempDic);
    if ([function isEqualToString:@"switch_state"]) {
        //开关状态
        [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedSwitchStateNotification
                                                            object:nil
                                                          userInfo:@{@"userInfo" : tempDic}];
        return;
    }
    if ([function isEqualToString:@"delay_time"]) {
        //倒计时
        [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedDelayTimeNotification
                                                            object:nil
                                                          userInfo:@{@"userInfo" : tempDic}];
        return;
    }
    if ([function isEqualToString:@"electricity_information"]) {
        //电量信息
        [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedElectricityNotification
                                                            object:nil
                                                          userInfo:@{@"userInfo" : tempDic}];
        return;
    }
    if ([function isEqualToString:@"firmware_infor"]) {
        //固件信息
        [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedFirmwareInfoNotification
                                                            object:nil
                                                          userInfo:@{@"userInfo" : tempDic}];
        return;
    }
    if ([function isEqualToString:@"ota_upgrade_state"]) {
        //固件升级结果
        [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerReceivedUpdateResultNotification
                                                            object:nil
                                                          userInfo:@{@"userInfo" : tempDic}];
        return;
    }
}

@end
