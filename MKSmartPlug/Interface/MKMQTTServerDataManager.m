//
//  MKMQTTServerDataManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerDataManager.h"
#import "MKConfigServerModel.h"

NSString *const MKMQTTSessionManagerStateChangedNotification = @"MKMQTTSessionManagerStateChangedNotification";

NSString *const MKMQTTServerReceivedSwitchStateNotification = @"MKMQTTServerReceivedSwitchStateNotification";
NSString *const MKMQTTServerReceivedDelayTimeNotification = @"MKMQTTServerReceivedDelayTimeNotification";
NSString *const MKMQTTServerReceivedElectricityNotification = @"MKMQTTServerReceivedElectricityNotification";
NSString *const MKMQTTServerReceivedFirmwareInfoNotification = @"MKMQTTServerReceivedFirmwareInfoNotification";
NSString *const MKMQTTServerReceivedUpdateResultNotification = @"MKMQTTServerReceivedUpdateResultNotification";

@interface MKMQTTServerDataManager()<MKMQTTServerManagerDelegate>

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@property (nonatomic, assign)MKMQTTSessionManagerState state;

@end

@implementation MKMQTTServerDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
    [kNotificationCenterSington removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (instancetype)init{
    if (self = [super init]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.filePath = [documentPath stringByAppendingPathComponent:@"MQTTServerConfigForApp.txt"];
        self.paramDic = [[NSMutableDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!self.paramDic){
            self.paramDic = [NSMutableDictionary dictionary];
        }
        [self.configServerModel updateServerModelWithDic:self.paramDic];
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:UIApplicationDidBecomeActiveNotification
                                         object:nil];
        [MKMQTTServerManager sharedInstance].delegate = self;
    }
    return self;
}

+ (MKMQTTServerDataManager *)sharedInstance{
    static MKMQTTServerDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerDataManager new];
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

#pragma mark - event method
- (void)networkStateChanged{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_swich]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_plug]) {
        //如果是当前网络不可用或者是连接的plug设备，则断开当前手机与mqtt服务器的连接操作
        [[MKMQTTServerManager sharedInstance] disconnect];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnected
        || [MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnecting) {
        //已经连接或者正在连接，直接返回
        return;
    }
    //如果网络可用，则连接
    [self connectServer];
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
 连接mqtt server
 
 */
- (void)connectServer{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:self.configServerModel.host
                                                       port:[self.configServerModel.port integerValue]
                                                        tls:(self.configServerModel.connectMode == 1)
                                                  keepalive:[self.configServerModel.keepAlive integerValue] clean:self.configServerModel.cleanSession
                                                       auth:YES
                                                       user:self.configServerModel.userName
                                                       pass:self.configServerModel.password
                                                   clientId:self.configServerModel.clientId];
}

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData{
    MKConfigServerModel *model = [[MKConfigServerModel alloc] init];
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
