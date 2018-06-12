//
//  MKMQTTServerManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MKSessionManagerState) {
    MKSessionManagerStateStarting,
    MKSessionManagerStateConnecting,
    MKSessionManagerStateError,
    MKSessionManagerStateConnected,
    MKSessionManagerStateClosing,
    MKSessionManagerStateClosed
};

//manager的装发生改变通知
extern NSString *const MKMQTTServerManagerStateChangedNotification;
//manager收到mqtt服务器的数据通知
extern NSString *const MKMQTTServerReceiveDataNotification;

@interface MKMQTTServerManager : NSObject

/**
 订阅主题。NSDictionary类型，Object 为 QoS，key 为 Topic
 */
@property (nonatomic, strong)NSDictionary<NSString *, NSNumber *> *subscriptions;

@property (nonatomic, assign, readonly)MKSessionManagerState managerState;

+ (MKMQTTServerManager *)sharedInstance;
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
       connectFailedBlock:(void (^)(NSError *error))failedBlock;

@end
