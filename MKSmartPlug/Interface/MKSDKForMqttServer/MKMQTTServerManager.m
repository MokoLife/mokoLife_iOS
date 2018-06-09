//
//  MKMQTTServerManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerManager.h"
#import "MQTTSessionManager.h"
#import "MQTTSession.h"

@interface MKMQTTServerManager()<MQTTSessionManagerDelegate>

@property (nonatomic, strong)MQTTSessionManager *sessionManager;

@property (nonatomic, copy)void (^connectSucBlock)(void);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

@property (nonatomic, assign)MKSessionManagerState managerState;

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
    
}

- (void)messageDelivered:(UInt16)msgID{
    
}

- (void)sessionManager:(MQTTSessionManager *)sessonManager didChangeState:(MQTTSessionManagerState)newState{
    //更新当前state
    [self sessionStateWithMQTTManagerState:newState];
    if ([self.delegate respondsToSelector:@selector(sessionManager:didChangeState:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate sessionManager:[MKMQTTServerManager sharedInstance] didChangeState:self.managerState];
        });
    }
    NSLog(@"连接状态发生改变:---%ld",(long)newState);
    if (newState == MQTTSessionManagerStateError) {
        //连接出错
        [self.sessionManager disconnect];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.connectFailedBlock) {
                self.connectFailedBlock(sessonManager.lastErrorCode);
            }
        });
        return;
    }
    if (newState == MQTTSessionManagerStateConnected) {
        //连接成功
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.connectSucBlock) {
                self.connectSucBlock();
            }
        });
        return;
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
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectMQTTServer:(NSString *)host
                     port:(NSInteger)port
                      tls:(BOOL)tls
                keepalive:(NSInteger)keepalive
                    clean:(BOOL)clean
                     auth:(BOOL)auth
                     user:(NSString *)user
                     pass:(NSString *)pass
                 clientId:(NSString *)clientId
          connectSucBlock:(void (^)(void))sucBlock
       connectFailedBlock:(void (^)(NSError *error))failedBlock{
    MQTTSessionManager *sessionManager = [[MQTTSessionManager alloc] init];
    sessionManager.delegate = self;
    self.sessionManager = sessionManager;
    __weak __typeof(&*self)weakSelf = self;
    [self connectTo:host port:port tls:tls keepalive:keepalive clean:clean auth:auth user:user pass:pass clientId:clientId connectSucBlock:^{
        if (sucBlock) {
            sucBlock();
        }
        [weakSelf clearConnectBlock];
    } connectFailedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

#pragma mark - private method
- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
         clientId:(NSString *)clientId
  connectSucBlock:(void (^)(void))sucBlock
connectFailedBlock:(void (^)(NSError *error))failedBlock{
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = failedBlock;
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

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailedBlock) {
        self.connectFailedBlock = nil;
    }
}

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

@end
