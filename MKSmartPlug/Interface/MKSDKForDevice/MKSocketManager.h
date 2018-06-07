//
//  MKSocketManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

//设备默认的ip地址
extern NSString *const defaultHostIpAddress;
//设备默认的端口号
extern NSInteger const defaultPort;

typedef NS_ENUM(NSInteger, mqttServerConnectMode) {
    mqttServerConnectTCPMode,           //配置给plug的mqtt服务器连接模式为tcp
    mqttServerConnectSSLMode,           //配置给plug的mqtt服务器连接模式为ssl
};

//mqqt服务质量
typedef NS_ENUM(NSInteger, mqttServerQosMode) {
    mqttServerQosModeBestEffortService,     //尽力而为。消息发送者会想尽办法发送消息，但是遇到意外并不会重试。
    mqttServerQosModeAtLeastOnce,           //至少一次。消息接收者如果没有知会或者知会本身丢失，消息发送者会再次发送以保证消息接收者至少会收到一次，当然可能造成重复消息。
    mqttServerQosModeJustOneTime,           //恰好一次。保证这种语义肯待会减少并发或者增加延时，不过丢失或者重复消息是不可接受的时候，级别2是最合适的。
};

//配置plug连接特定ssid的WiFi网络时候的安全策略
typedef NS_ENUM(NSInteger, wifiSecurity) {
    wifiSecurity_OPEN,
    wifiSecurity_WEP,
    wifiSecurity_WPA_PSK,
    wifiSecurity_WPA2_PSK,
    wifiSecurity_WPA_WPA2_PSK,
};

@class MKSocketDataModel;
@interface MKSocketManager : NSObject

@property (nonatomic, strong)NSMutableArray <MKSocketDataModel *>*dataList;

+ (MKSocketManager *)sharedInstance;

/**
 连接plug设备
 
 @param host host ip address
 @param port port (0~65535)
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectDeviceWithHost:(NSString *)host
                         port:(NSInteger)port
              connectSucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
           connectFailedBlock:(void (^)(NSError *error))failedBlock;
/**
 读取设备信息
 
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readSmartPlugDeviceInformationWithSucBlock:(void (^)(id returnData))sucBlock
                                       failedBlock:(void (^)(NSError *error))failedBlock;
/**
 设置给插座的mqtt服务器信息。插座接收到此信息，并成功解析，待插座成功连接wifi网络后，插座会自动去连接手机指定的mqtt服务器
 
 @param host mqtt服务器主机host
 @param port mqtt服务器主机端口号，范围0~65535
 @param mode 连接方式 0：tcp,1:ssl
 @param qos mqqt服务质量
 @param keepalive plug跟mqtt服务器连接之后保持活跃状态的时间，0~2的32次方，单位：s
 @param clean NO:表示创建一个持久会话，在客户端断开连接时，会话仍然保持并保存离线消息，直到会话超时注销。YES:表示创建一个新的临时会话，在客户端断开时，会话自动销毁。
 @param clientId plug作为客户端的id,以非数字开头,长度为6-20个字符,由英文字母(区分大小写),数字(0-9),下划线组成
 @param username plug连接mqtt服务器时候的用户名,以非数字开头,长度为6-20个字符,由英文字母(区分大小写),数字(0-9),下划线组成
 @param password plug连接mqtt服务器时候的密码,以非数字开头,长度为6-20个字符,由英文字母(区分大小写),数字(0-9),下划线组成
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configMQTTServerHost:(NSString *)host
                        port:(NSInteger)port
                 connectMode:(mqttServerConnectMode)mode
                         qos:(mqttServerQosMode)qos
                   keepalive:(NSUInteger)keepalive
                cleanSession:(BOOL)clean
                    clientId:(NSString *)clientId
                    username:(NSString *)username
                    password:(NSString *)password
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;
/**
 手机给插座指定连接特定ssid的WiFi网络。注意:调用该方法的时候，应该确保已经把mqtt服务器信息设置给plug了，否则调用该方法会出现错误
 
 @param ssid wifi ssid
 @param password wifi密码,不需要密码的wifi网络，密码可以不填
 @param security wifi加密策略
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configWifiSSID:(NSString *)ssid
              password:(NSString *)password
              security:(wifiSecurity)security
              sucBlock:(void (^)(id returnData))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

@end
