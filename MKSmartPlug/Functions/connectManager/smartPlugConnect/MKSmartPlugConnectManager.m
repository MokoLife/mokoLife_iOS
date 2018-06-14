//
//  MKSmartPlugConnectManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSmartPlugConnectManager.h"
#import "MKDeviceModel.h"
#import "MKConfigServerModel.h"

@interface MKSmartPlugConnectManager()

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@property (nonatomic, copy)NSString *wifi_ssid;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableDictionary *deviceInfoDic;

@property (nonatomic, copy)void (^connectSucBlock)(NSDictionary *deviceInfo);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

@end

@implementation MKSmartPlugConnectManager

#pragma mark - life circle
- (instancetype)init{
    if (self = [super init]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.filePath = [documentPath stringByAppendingPathComponent:@"MQTTServerConfigForPlug.txt"];
        self.paramDic = [[NSMutableDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!self.paramDic){
            self.paramDic = [NSMutableDictionary dictionary];
        }
        [self.configServerModel updateServerModelWithDic:self.paramDic];
    }
    return self;
}

+ (MKSmartPlugConnectManager *)sharedInstance{
    static MKSmartPlugConnectManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKSmartPlugConnectManager new];
        }
    });
    return manager;
}

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

/**
 记录到本地
 */
- (void)synchronize{
    [self.paramDic setObject:SafeStr(self.configServerModel.host) forKey:@"host"];
    [self.paramDic setObject:SafeStr(self.configServerModel.port) forKey:@"port"];
    [self.paramDic setObject:@(self.configServerModel.cleanSession) forKey:@"cleanSession"];
    [self.paramDic setObject:@(self.configServerModel.connectMode) forKey:@"connectMode"];
    [self.paramDic setObject:SafeStr(self.configServerModel.qos) forKey:@"qos"];
    [self.paramDic setObject:SafeStr(self.configServerModel.keepAlive) forKey:@"keepAlive"];
    [self.paramDic setObject:SafeStr(self.configServerModel.clientId) forKey:@"clientId"];
    [self.paramDic setObject:SafeStr(self.configServerModel.userName) forKey:@"userName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.password) forKey:@"password"];
    
    [self.paramDic writeToFile:self.filePath atomically:NO];
};

/**
 连接plug设备并且配置各项参数过程，配置成功之后，该设备会存储到本地数据库
 
 @param wifi_ssid 指定plug连接的wifi ssid
 @param password 指定plug连接的wifi password，对于没有密码的wifi，该项参数可以不填
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configDeviceWithWifiSSID:(NSString *)wifi_ssid
                        password:(NSString *)password
                        sucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock{
    self.wifi_ssid = wifi_ssid;
    self.password = password;
    WS(weakSelf);
    [self connectPlugWithSucBlock:^(NSDictionary *deviceInfo) {
        if (sucBlock) {
            sucBlock(deviceInfo);
        }
        weakSelf.connectFailedBlock = nil;
        weakSelf.connectSucBlock = nil;
        weakSelf.deviceInfoDic = nil;
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        weakSelf.connectFailedBlock = nil;
        weakSelf.connectSucBlock = nil;
        weakSelf.deviceInfoDic = nil;
    }];
}

#pragma mark - private method
- (void)connectPlugWithSucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock{
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = failedBlock;
    self.deviceInfoDic = nil;
    WS(weakSelf);
    [[MKSocketManager sharedInstance] connectDeviceWithHost:defaultHostIpAddress port:defaultPort connectSucBlock:^(NSString *IP, NSInteger port) {
        [weakSelf readDeviceInfo];
    } connectFailedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)readDeviceInfo{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] readSmartPlugDeviceInformationWithSucBlock:^(id returnData) {
        weakSelf.deviceInfoDic = [NSMutableDictionary dictionaryWithDictionary:returnData[@"result"]];
        [weakSelf configMqttServer];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configMqttServer{
    WS(weakSelf);
    mqttServerConnectMode connectMode = (self.configServerModel.connectMode == 0 ? mqttServerConnectTCPMode : mqttServerConnectSSLMode);
    mqttServerQosMode qoeMode = mqttQosLevelExactlyOnce;
    if ([self.configServerModel.qos isEqualToString:@"0"]) {
        //
        qoeMode = mqttQosLevelAtMostOnce;
    }else if ([self.configServerModel.qos isEqualToString:@"1"]){
        qoeMode = mqttQosLevelAtLeastOnce;
    }
    [[MKSocketManager sharedInstance] configMQTTServerHost:self.configServerModel.host
                                                      port:[self.configServerModel.port integerValue]
                                               connectMode:connectMode
                                                       qos:qoeMode
                                                 keepalive:[self.configServerModel.keepAlive integerValue]
                                              cleanSession:self.configServerModel.cleanSession clientId:self.configServerModel.clientId username:self.configServerModel.userName password:self.configServerModel.password
                                                  sucBlock:^(id returnData) {
        [weakSelf configWifiInfo];
    }
                                               failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configWifiInfo{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configWifiSSID:self.wifi_ssid password:self.password security:wifiSecurity_WPA2_PSK sucBlock:^(id returnData) {
        if (weakSelf.connectSucBlock) {
            weakSelf.connectSucBlock(weakSelf.deviceInfoDic);
        }
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
