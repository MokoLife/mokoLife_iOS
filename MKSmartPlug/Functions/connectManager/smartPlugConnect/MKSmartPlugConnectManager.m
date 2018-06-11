//
//  MKSmartPlugConnectManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSmartPlugConnectManager.h"
#import <objc/runtime.h>
#import "MKDeviceModel.h"
#import "MKDeviceDataBaseManager.h"

static const char *connectWifiSSIDKey = "connectWifiSSIDKey";
static const char *connectWifiPasswordKey = "connectWifiPasswordKey";
static const char *deviceInfoKey = "deviceInfoKey";

@implementation MKSmartPlugConnectManager

/**
 连接plug设备并且配置各项参数过程，配置成功之后，该设备会存储到本地数据库

 @param wifi_ssid 指定plug连接的wifi ssid
 @param password 指定plug连接的wifi password，对于没有密码的wifi，该项参数可以不填
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
+ (void)configDeviceWithWifiSSID:(NSString *)wifi_ssid
                        password:(NSString *)password
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock{
    if (ValidStr(wifi_ssid)) {
        objc_setAssociatedObject(self, &connectWifiSSIDKey, wifi_ssid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (ValidStr(password)) {
        objc_setAssociatedObject(self, &connectWifiPasswordKey, password, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    WS(weakSelf);
    [[MKSocketManager sharedInstance] connectDeviceWithHost:defaultHostIpAddress port:defaultPort connectSucBlock:^(NSString *IP, NSInteger port) {
        [weakSelf readDeviceInfoWithSucBlock:sucBlock failedBlock:failedBlock];
    } connectFailedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearBindWifiInfo];
    }];
}

+ (void)readDeviceInfoWithSucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] readSmartPlugDeviceInformationWithSucBlock:^(id returnData) {
        NSDictionary *dic = returnData[@"result"];
        if (ValidDict(dic)) {
            objc_setAssociatedObject(self, &deviceInfoKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [weakSelf configMqttServerWithSucBlock:sucBlock failedBlock:failedBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearBindWifiInfo];
    }];
}

+ (void)configMqttServerWithSucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configMQTTServerHost:@"45.32.33.42" port:1883 connectMode:mqttServerConnectTCPMode qos:mqttQosLevelExactlyOnce keepalive:60 cleanSession:YES clientId:@"smartPlug1" username:@"host1243" password:@"a123456" sucBlock:^(id returnData) {
        [weakSelf configWifiWithSucBlock:sucBlock failedBlock:failedBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearBindWifiInfo];
    }];
}

+ (void)configWifiWithSucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock{
    WS(weakSelf);
    NSString *ssid = objc_getAssociatedObject(self, &connectWifiSSIDKey);
    NSString *password = objc_getAssociatedObject(self, &connectWifiPasswordKey);
    [[MKSocketManager sharedInstance] configWifiSSID:ssid password:password security:wifiSecurity_WPA2_PSK sucBlock:^(id returnData) {
        [weakSelf saveDeviceToLocalWithSucBlock:sucBlock failedBlock:failedBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearBindWifiInfo];
    }];
}

+ (void)saveDeviceToLocalWithSucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock{
    NSDictionary *dataDic = objc_getAssociatedObject(self, &deviceInfoKey);
    MKDeviceModel *dataModel = [[MKDeviceModel alloc] initWithDictionary:dataDic];
    dataModel.local_name = @"MK1xxxx";
    WS(weakSelf);
    [MKDeviceDataBaseManager insertDeviceList:@[dataModel] sucBlock:^{
        if (sucBlock) {
            sucBlock();
        }
        [weakSelf clearBindWifiInfo];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearBindWifiInfo];
    }];
}

+ (void)clearBindWifiInfo{
    objc_setAssociatedObject(self, &connectWifiSSIDKey, @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &connectWifiPasswordKey, @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &deviceInfoKey, @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
