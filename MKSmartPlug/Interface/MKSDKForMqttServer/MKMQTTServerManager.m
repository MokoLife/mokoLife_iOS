//
//  MKMQTTServerManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerManager.h"
#import "MKMQTTServerBlockAdopter.h"
#import "MKMQTTServerDataParser.h"
#import "MKMQTTServerDataNotifications.h"
#import "MKMQTTServerTaskOperation.h"

@interface MKMQTTServerManager()<MKMQTTSessionManagerDelegate>

@property (nonatomic, strong)MKMQTTServerSessionManager *sessionManager;

@property (nonatomic, assign)MKMQTTSessionManagerState managerState;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, strong)NSMutableDictionary *subscriptions;

@end

@implementation MKMQTTServerManager

+ (MKMQTTServerManager *)sharedInstance{
    static MKMQTTServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerManager new];
        }
    });
    return manager;
}

#pragma mark - MQTTSessionManagerDelegate

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained{
    [MKMQTTServerDataParser handleMessage:data onTopic:topic retained:retained];
}

- (void)sessionManager:(MKMQTTServerSessionManager *)sessonManager didChangeState:(MKMQTTSessionManagerState)newState{
    //更新当前state
    self.managerState = newState;
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerManagerStateChangedNotification object:nil];
    NSLog(@"连接状态发生改变:---%ld",(long)newState);
    if (self.managerState == MKMQTTSessionManagerStateConnected) {
        //连接成功了，订阅主题
        self.sessionManager.subscriptions = [NSDictionary dictionaryWithDictionary:self.subscriptions];
    }
    if (self.managerState == MKMQTTSessionManagerStateError) {
        //连接出错
        [self disconnect];
    }
}

- (void)messageDelivered:(UInt16)msgID{
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerManagerSendDataSuccessNotification
                                                        object:nil
                                                      userInfo:@{@"userInfo" : @(msgID)}];
}

#pragma mark - public method

/**
 连接MQTT服务器
 
 @param host 服务器地址
 @param port 服务器端口
 @param tls 是否使用tls协议
 @param keepalive 心跳时间，单位秒，每隔固定时间发送心跳包, 心跳间隔不得大于120s
 @param clean session是否清除，这个需要注意，如果是false，代表保持登录，如果客户端离线了再次登录就可以接收到离线消息
 @param auth 是否使用登录验证
 @param user 用户名
 @param pass 密码
 @param clientId 客户端id，需要特别指出的是这个id需要全局唯一，因为服务端是根据这个来区分不同的客户端的，默认情况下一个id登录后，假如有另外的连接以这个id登录，上一个连接会被踢下线
 */
- (void)connectMQTTServer:(NSString *)host
                     port:(NSInteger)port
                      tls:(BOOL)tls
                keepalive:(NSInteger)keepalive
                    clean:(BOOL)clean
                     auth:(BOOL)auth
                     user:(NSString *)user
                     pass:(NSString *)pass
                 clientId:(NSString *)clientId{
    if (self.sessionManager) {
        self.sessionManager.delegate = nil;
        [self.sessionManager disconnect];
        self.sessionManager = nil;
    }
    [self.operationQueue cancelAllOperations];
    MKMQTTServerSessionManager *sessionManager = [[MKMQTTServerSessionManager alloc] init];
    sessionManager.delegate = self;
    self.sessionManager = sessionManager;
    MQTTSSLSecurityPolicy *securityPolicy = nil;
    if (tls) {
        //需要tls
        securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        securityPolicy.validatesCertificateChain = NO;
    }
    [self.sessionManager connectTo:host
                              port:port
                               tls:tls
                         keepalive:keepalive
                             clean:clean
                              auth:auth
                              user:user
                              pass:pass
                              will:false
                         willTopic:nil
                           willMsg:nil
                           willQos:0
                    willRetainFlag:false
                      withClientId:clientId
                    securityPolicy:securityPolicy
                      certificates:nil];
}

/**
 断开连接
 */
- (void)disconnect{
    [self.operationQueue cancelAllOperations];
    if (!self.sessionManager) {
        return;
    }
    self.sessionManager.delegate = nil;
    [self.sessionManager disconnect];
    self.sessionManager = nil;
    self.managerState = MKMQTTSessionManagerStateStarting;
}

/**
 订阅主题,Object 为 QoS，key 为 Topic
 
 @param topicList 主题
 */
- (void)subscriptions:(NSArray <NSString *>*)topicList{
    if (!topicList
        || topicList.count == 0) {
        return;
    }
    for (NSString *topic in topicList) {
        [self.subscriptions setObject:@(MQTTQosLevelExactlyOnce) forKey:topic];
    }
}

/**
 取消订阅主题
 
 @param topicList 主题列表
 */
- (void)unsubscriptions:(NSArray <NSString *>*)topicList{
    if (!self.sessionManager
        || !topicList
        || topicList.count == 0) {
        return;
    }
    for (NSString *topic in topicList) {
        [self.subscriptions removeObjectForKey:topic];
    }
    [self.sessionManager unsubscriptions:topicList];
}

#pragma mark - interface

/**
 设置plug的开关状态

 @param isOn YES:开，NO:关
 @param topic 发布开关状态的主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)setSmartPlugSwitchState:(BOOL)isOn
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock{
    NSDictionary *dataDic = @{@"switch_state" : (isOn ? @"on" : @"off")};
    [self sendData:[self dataWithJson:dataDic] topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

/**
 插座便进入倒计时，当计时时间到了，插座便会切换当前的状态，如当前为”on”状态，便会切换为”off”状态

 @param delay_hour 倒计时,0~23
 @param delay_minutes 倒计分,0~59
 @param topic 发布倒计时功能的主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)setDelayHour:(NSInteger)delay_hour
            delayMin:(NSInteger)delay_minutes
               topic:(NSString *)topic
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock{
    if (delay_hour < 0 || delay_hour > 23) {
        [MKMQTTServerBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (delay_minutes < 0 || delay_minutes > 59) {
        [MKMQTTServerBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"delay_hour":@(delay_hour),
                              @"delay_minute":@(delay_minutes),
                              };
    [self sendData:[self dataWithJson:dataDic] topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

/**
 恢复出厂设置
 
 @param topic 主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)resetDeviceWithTopic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    NSDictionary *dataDic = @{};
    [self sendData:[self dataWithJson:dataDic] topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

/**
 读取设备固件信息
 
 @param topic 主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock{
    NSDictionary *dataDic = @{};
    [self sendData:[self dataWithJson:dataDic] topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

#pragma mark - private method

- (void)sendData:(NSData *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock{
    if (!data) {
        [MKMQTTServerBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (!topic || topic.length == 0) {
        [MKMQTTServerBlockAdopter operationTopicErrorBlock:failedBlock];
        return;
    }
    if (!self.sessionManager) {
        [MKMQTTServerBlockAdopter operationDisConnectedErrorBlock:failedBlock];
        return;
    }
    UInt16 msgid = [self.sessionManager sendData:data //要发送的消息体
                                           topic:topic //要往哪个topic发送消息
                                             qos:MQTTQosLevelExactlyOnce //消息级别
                                          retain:false];
    if (msgid <= 0) {
        [MKMQTTServerBlockAdopter operationSetDataErrorBlock:failedBlock];
        return;
    }
    MKMQTTServerTaskOperation *operation = [[MKMQTTServerTaskOperation alloc] initOperationWithID:msgid completeBlock:^(NSError *error, NSInteger operationID) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (msgid != operationID) {
            [MKMQTTServerBlockAdopter operationSetDataErrorBlock:failedBlock];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock();
            }
        });
    }];
    [self.operationQueue addOperation:operation];
}

- (NSData *)dataWithJson:(NSDictionary *)dic{
    if (!dic) {
        return nil;
    }
    NSString *dataString = [NSString convertToJsonData:dic];
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

- (NSMutableDictionary *)subscriptions{
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return _subscriptions;
}

@end
