//
//  MKDeviceAdopterCenter.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceAdopterCenter.h"

//作为当前wifi是否是smartPlug的key，如果当前wifi的ssid前几位为smartPlugWifiSSIDKey，则认为当前已经连接smartPlug
NSString *const smartPlugWifiSSIDKey = @"MK";
//作为当前wifi是否是smartSwich的key，如果当前wifi的ssid前几位为smartSwichWifiSSIDKey，则认为当前已经连接smartSwich
NSString *const smartSwichWifiSSIDKey = @"WS";

@implementation MKDeviceAdopterCenter

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
 根据deviceModel返回当前所有可能订阅的主题
 
 @param deviceModel deviceModel
 @return 主题列表
 */
+ (NSArray <NSString *>*)allTopicForDevice:(MKDeviceModel *)deviceModel{
    NSString *firmware = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"firmware_infor"];
    NSString *ota = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"];
    NSString *swicthState = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"switch_state"];
    NSString *delay = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delay_time"];
    NSString *deleteDevice = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delete_device"];
    NSMutableArray *topicList = [NSMutableArray array];
    [topicList addObject:firmware];
    [topicList addObject:ota];
    [topicList addObject:swicthState];
    [topicList addObject:delay];
    [topicList addObject:deleteDevice];
    if (deviceModel.device_mode == MKDevice_plug) {
        NSString *electricity = [deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"electricity_information"];
        [topicList addObject:electricity];
    }
    return [topicList copy];
}

@end
