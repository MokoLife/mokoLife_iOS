//
//  MKDeviceModel+MKTopic.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel+MKTopic.h"

//作为当前wifi是否是smartPlug的key，如果当前wifi的ssid前几位为smartPlugWifiSSIDKey，则认为当前已经连接smartPlug
NSString *const smartPlugWifiSSIDKey = @"MK";
//作为当前wifi是否是smartSwich的key，如果当前wifi的ssid前几位为smartSwichWifiSSIDKey，则认为当前已经连接smartSwich
NSString *const smartSwichWifiSSIDKey = @"WS";

@implementation MKDeviceModel (MKTopic)

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect:(MKDeviceType)deviceType{
    if ([MKNetworkManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        return NO;
    }
    NSString *wifiSSID = [MKNetworkManager currentWifiSSID];
    if (!ValidStr(wifiSSID) || [wifiSSID isEqualToString:@"<<NONE>>"]) {
        //当前wifi的ssid未知
        return NO;
    }
    NSString *targetSSID = smartPlugWifiSSIDKey;
    if (deviceType == MKDevice_swich) {
        targetSSID = smartSwichWifiSSIDKey;
    }
    if (wifiSSID.length < targetSSID.length) {
        return NO;
    }
    NSString *ssidHeader = [[wifiSSID substringWithRange:NSMakeRange(0, targetSSID.length)] uppercaseString];
    if ([ssidHeader isEqualToString:targetSSID]) {
        return YES;
    }
    return NO;
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

/**
 app可以订阅的主题
 
 @return topicList
 */
- (NSArray <NSString *>*)allTopicList{
    NSString *firmware = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"firmware_infor"];
    NSString *ota = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"];
    NSString *swicthState = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"switch_state"];
    NSString *delay = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delay_time"];
    NSString *deleteDevice = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delete_device"];
    NSMutableArray *topicList = [NSMutableArray array];
    [topicList addObject:firmware];
    [topicList addObject:ota];
    [topicList addObject:swicthState];
    [topicList addObject:delay];
    [topicList addObject:deleteDevice];
    if (self.device_mode == MKDevice_plug) {
        NSString *electricity = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"electricity_information"];
        [topicList addObject:electricity];
    }
    return [topicList copy];
}

@end
