//
//  MKMQTTServerManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerManager.h"
#import "MQTTSessionManager.h"
#import "MKMQTTServerBlockAdopter.h"
#import "MKMQTTServerDataParser.h"
#import "MKMQTTServerDataNotifications.h"

@interface MKMQTTServerManager()<MQTTSessionManagerDelegate>

@property (nonatomic, strong)MQTTSessionManager *sessionManager;

@property (nonatomic, assign)MKSessionManagerState managerState;

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

- (void)sessionManager:(MQTTSessionManager *)sessonManager didChangeState:(MQTTSessionManagerState)newState{
    //更新当前state
    [self sessionStateWithMQTTManagerState:newState];
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerManagerStateChangedNotification object:nil];
    NSLog(@"连接状态发生改变:---%ld",(long)newState);
    if (self.managerState == MKSessionManagerStateConnected) {
        //连接成功了，订阅主题
        self.sessionManager.subscriptions = [NSDictionary dictionaryWithDictionary:self.subscriptions];
    }
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
    MQTTSessionManager *sessionManager = [[MQTTSessionManager alloc] init];
    sessionManager.delegate = self;
    self.sessionManager = sessionManager;
    [self.sessionManager connectTo:host
                              port:port
                               tls:tls
                         keepalive:keepalive  //心跳间隔不得大于120s
                             clean:clean
                              auth:auth
                              user:user
                              pass:pass
                              will:false
                         willTopic:nil
                           willMsg:nil
                           willQos:0
                    willRetainFlag:false
                      withClientId:clientId];
}

/**
 断开连接
 */
- (void)disconnect{
    if (!self.sessionManager) {
        return;
    }
    self.sessionManager.delegate = nil;
    [self.sessionManager disconnect];
    self.sessionManager = nil;
    self.managerState = MQTTSessionManagerStateStarting;
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
    if (!topic || topic.length == 0) {
        [MKMQTTServerBlockAdopter operationTopicErrorBlock:failedBlock];
        return;
    }
    if (!self.sessionManager) {
        [MKMQTTServerBlockAdopter operationDisConnectedErrorBlock:failedBlock];
        return;
    }
    NSString *dataString = [NSString convertToJsonData:@{@"switch_state" : (isOn ? @"on" : @"off")}];
    UInt16 msgid = [self.sessionManager sendData:[dataString dataUsingEncoding:NSUTF8StringEncoding] //要发送的消息体
                                           topic:topic //要往哪个topic发送消息
                                             qos:MQTTQosLevelExactlyOnce //消息级别
                                          retain:false];
    if (msgid > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock();
            }
        });
        return;
    }
    [MKMQTTServerBlockAdopter operationSetDataErrorBlock:failedBlock];
}

#pragma mark - private method

//- (void)

- (void)sessionStateWithMQTTManagerState:(MQTTSessionManagerState)sessionState{
    switch (sessionState) {
        case MQTTSessionManagerStateStarting:
            //开始连接
            self.managerState = MKSessionManagerStateStarting;
            break;
        case MQTTSessionManagerStateConnecting:
            //正在连接
            self.managerState = MKSessionManagerStateConnecting;
            break;
        case MQTTSessionManagerStateError:
            //连接出错
            self.managerState = MKSessionManagerStateError;
            break;
        case MQTTSessionManagerStateConnected:
            //连接成功
            self.managerState = MKSessionManagerStateConnected;
            break;
        case MQTTSessionManagerStateClosing:
            //正在关闭
            self.managerState = MKSessionManagerStateClosing;
            break;
        case MQTTSessionManagerStateClosed:
            //已经关闭
            self.managerState = MKSessionManagerStateClosed;
            break;
        default:
            break;
    }
}

#pragma mark - setter & getter
- (NSMutableDictionary *)subscriptions{
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return _subscriptions;
}

@end
