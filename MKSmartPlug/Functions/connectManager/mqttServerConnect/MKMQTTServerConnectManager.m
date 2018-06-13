//
//  MKMQTTServerConnectManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerConnectManager.h"
#import "MKConfigServerModel.h"

@interface MKMQTTServerConnectManager()

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@end

@implementation MKMQTTServerConnectManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
    [kNotificationCenterSington removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
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
    }
    return self;
}

+ (MKMQTTServerConnectManager *)sharedInstance{
    static MKMQTTServerConnectManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerConnectManager new];
        }
    });
    return manager;
}

#pragma mark - event method
- (void)networkStateChanged{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]
        || [[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        //如果是当前网络不可用或者是连接的plug设备，则断开当前手机与mqtt服务器的连接操作
        [[MKMQTTServerManager sharedInstance] disconnect];
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
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:self.configServerModel.host
                                                       port:[self.configServerModel.port integerValue]
                                                        tls:NO
                                                  keepalive:[self.configServerModel.keepAlive integerValue] clean:self.configServerModel.cleanSession auth:NO
                                                       user:self.configServerModel.userName
                                                       pass:self.configServerModel.password
                                                   clientId:self.configServerModel.clientId];
}

/**
 订阅主题
 */
- (void)updateMQTTServerTopic:(NSArray <NSString *>*)topicList{
    if (!ValidArray(topicList) || [MKMQTTServerManager sharedInstance].managerState != MKSessionManagerStateConnected) {
        return;
    }
    [[MKMQTTServerManager sharedInstance] subscriptions:topicList];
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
