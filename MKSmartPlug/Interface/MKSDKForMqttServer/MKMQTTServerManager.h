//
//  MKMQTTServerManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKMQTTServerSessionManager.h"

typedef NS_ENUM(NSInteger, MKFirmwareUpdateHostType) {
    MKFirmwareUpdateHostTypeIP,
    MKFirmwareUpdateHostTypeUrl,
};

@interface MKMQTTServerManager : NSObject

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState managerState;

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
 */
- (void)connectMQTTServer:(NSString *)host
                     port:(NSInteger)port
                      tls:(BOOL)tls
                keepalive:(NSInteger)keepalive
                    clean:(BOOL)clean
                     auth:(BOOL)auth
                     user:(NSString *)user
                     pass:(NSString *)pass
                 clientId:(NSString *)clientId;

/**
 断开连接
 */
- (void)disconnect;

/**
 订阅主题

 @param topicList 主题列表
 */
- (void)subscriptions:(NSArray <NSString *>*)topicList;

/**
 取消订阅主题

 @param topicList 主题列表
 */
- (void)unsubscriptions:(NSArray <NSString *>*)topicList;

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
                    failedBlock:(void (^)(NSError *error))failedBlock;
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
         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 恢复出厂设置

 @param topic 主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)resetDeviceWithTopic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/**
 读取设备固件信息

 @param topic 主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;
/**
 插座OTA升级
 
 @param hostType hostType
 @param host 放新固件的主机的ip地址或域名
 @param port 端口号,取值：0~65535
 @param catalogue 目录，长度小于100个字节
 @param topic 固件升级主题
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)updateFirmware:(MKFirmwareUpdateHostType)hostType
                  host:(NSString *)host
                  port:(NSInteger)port
             catalogue:(NSString *)catalogue
                 topic:(NSString *)topic
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;
@end
