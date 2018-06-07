//
//  MKSocketManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "MKSocketBlockAdopter.h"
#import "MKSocketAdopter.h"
#import "MKSocketTaskID.h"
#import "MKSocketDataModel.h"
#import "MKSocketTaskOperation.h"

//设备默认的ip地址
NSString *const defaultHostIpAddress = @"192.168.4.1";
//设备默认的端口号
NSInteger const defaultPort = 8266;

static NSTimeInterval const defaultConnectTime = 15.f;
static NSTimeInterval const defaultCommandTime = 2.f;

@interface MKSocketManager()<GCDAsyncSocketDelegate>

@property (nonatomic, strong)GCDAsyncSocket *socket;

@property (nonatomic, strong)dispatch_queue_t socketQueue;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, copy)void (^connectSucBlock)(NSString *IP, NSInteger port);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

@end

@implementation MKSocketManager

#pragma mark - life circle

+ (MKSocketManager *)sharedInstance{
    static MKSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [self socketManager];
        }
    });
    return manager;
}

+ (MKSocketManager *)socketManager{
    return [[self alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        _socketQueue = dispatch_queue_create("com.moko.MKSocketManagerQueue", nil);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

#pragma mark - delegate

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if (!sock) {
        return;
    }
    [self.operationQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectSucBlock) {
            self.connectSucBlock(sock.connectedHost, sock.connectedPort);
        }
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if (!err) {
        return;
    }
    [self.operationQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectFailedBlock) {
            self.connectFailedBlock([MKSocketBlockAdopter exchangedGCDAsyncSocketErrorToLocalError:err]);
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //发送成功之后读取数值
    NSLog(@"发送数据成功");
    [self.socket readDataWithTimeout:defaultCommandTime tag:socketReadDeviceInformationTask];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    [self taskTimeoutWithTag:tag];
    return 0.f;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"HTTP Response:\n%@", httpResponse);
    [self taskSuccessWithTag:tag returnData:[MKSocketAdopter dictionaryWithJsonString:httpResponse]];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    [self taskTimeoutWithTag:tag];
    return 0.f;
}

#pragma mark - public method

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
           connectFailedBlock:(void (^)(NSError *error))failedBlock{
    if (![MKSocketAdopter isValidatIP:host] || port < 0 || port > 65535) {
        [MKSocketBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [self connectHost:host port:port sucBlock:^(NSString *IP, NSInteger port) {
        if (sucBlock) {
            sucBlock(IP,port);
        }
        [weakSelf clearConnectBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

#pragma mark - interface
/**
 读取设备信息

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readSmartPlugDeviceInformationWithSucBlock:(void (^)(id returnData))sucBlock
                                       failedBlock:(void (^)(NSError *error))failedBlock{
    NSString *jsonString = [MKSocketAdopter convertToJsonData:@{@"header":@(4001)}];
    [self addTaskWithTaskID:socketReadDeviceInformationTask jsonString:jsonString sucBlock:sucBlock failedBlock:failedBlock];
}

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
                 failedBlock:(void (^)(NSError *error))failedBlock{
    if (![MKSocketAdopter isValidatIP:host] || ![MKSocketAdopter isDomainName:host]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Host error" block:failedBlock];
        return;
    }
    if (port < 0 || port > 65535) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Port effective range : 0~65535" block:failedBlock];
        return;
    }
    if (![MKSocketAdopter isClientId:clientId]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Client id error" block:failedBlock];
        return;
    }
    if (![MKSocketAdopter isUserName:username]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"User name error" block:failedBlock];
        return;
    }
    if (![MKSocketAdopter isPassword:password]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Password error" block:failedBlock];
        return;
    }
    NSString *connectMode = @"0";
    if (mode == mqttServerConnectSSLMode) {
        connectMode = @"1";
    }
    NSString *qosString = @"2";
    if (qos == mqttServerQosModeBestEffortService) {
        qosString = @"0";
    }else if (qos == mqttServerQosModeAtLeastOnce){
        qosString = @"1";
    }
    NSDictionary *commandDic = @{
                                 @"header":@(4002),
                                 @"host":host,
                                 @"port":@(port),
                                 @"clientId":clientId,
                                 @"connect_mode":connectMode,
                                 @"username":username,
                                 @"password":password,
                                 @"keepalive":[NSString stringWithFormat:@"%ld",(long)keepalive],
                                 @"qos":qosString,
                                 @"clean_session":(clean ? @"1" : @"0"),
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigMQTTServerTask jsonString:jsonString sucBlock:sucBlock failedBlock:failedBlock];
}

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
           failedBlock:(void (^)(NSError *error))failedBlock{
    if (!ssid || ssid.length == 0) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"SSID error" block:failedBlock];
        return;
    }
    NSString *wifi_security = @"0";
    if (security == wifiSecurity_WEP) {
        wifi_security = @"1";
    }else if (security == wifiSecurity_WPA_PSK){
        wifi_security = @"2";
    }else if (security == wifiSecurity_WPA2_PSK){
        wifi_security = @"3";
    }else if (security == wifiSecurity_WPA_WPA2_PSK){
        wifi_security = @"4";
    }
    NSDictionary *commandDic = @{
                                 @"header":@(4003),
                                 @"wifi_ssid":ssid,
                                 @"wifi_pwd":((!password || password.length == 0) ? @"" : password),
                                 @"wifi_security":wifi_security,
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigWifiTask jsonString:jsonString sucBlock:sucBlock failedBlock:failedBlock];
}

#pragma mark - connect private method
- (void)connectHost:(NSString *)host
               port:(NSInteger)port
           sucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock{
    self.connectSucBlock = nil;
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = nil;
    self.connectFailedBlock = failedBlock;
    NSError *error = nil;
    BOOL pass = [self.socket connectToHost:host onPort:port withTimeout:defaultConnectTime error:&error];
    if (!pass) {
        [self.operationQueue cancelAllOperations];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failedBlock) {
                failedBlock(error);
            }
        });
    }
}

- (void)addTaskWithTaskID:(MKSocketTaskID)taskID
               jsonString:(NSString *)jsonString
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock{
    if (!jsonString) {
        [MKSocketBlockAdopter operationGetDataErrorBlock:failedBlock];
        return;
    }
    if (!self.socket.isConnected) {
        [MKSocketBlockAdopter operationDisConnectedErrorBlock:failedBlock];
        return;
    }
    MKSocketTaskOperation *operation = [[MKSocketTaskOperation alloc] initOperationWithID:taskID completeBlock:^(NSError *error, MKSocketTaskID operationID, id returnData) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (!returnData || ![returnData isKindOfClass:[NSDictionary class]]) {
            //出错
            [MKSocketBlockAdopter operationGetDataErrorBlock:failedBlock];
        }
        if (![returnData[@"code"] isEqualToString:@"0"]) {
            //数据错误
            [MKSocketBlockAdopter operationDataErrorWithReturnData:returnData block:failedBlock];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock(returnData);
            }
        });
    }];
    [self.operationQueue addOperation:operation];
    NSData *commandData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:commandData withTimeout:defaultCommandTime tag:socketReadDeviceInformationTask];
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailedBlock) {
        self.connectFailedBlock = nil;
    }
}

- (void)taskSuccessWithTag:(long)tag returnData:(NSDictionary *)returnData{
    MKSocketDataModel *dataModel = [[MKSocketDataModel alloc] init];
    dataModel.taskID = tag;
    dataModel.timeout = NO;
    dataModel.returnData = returnData;
    [self addDataToList:dataModel];
}

- (void)taskTimeoutWithTag:(long)tag{
    MKSocketDataModel *dataModel = [[MKSocketDataModel alloc] init];
    dataModel.taskID = tag;
    dataModel.timeout = YES;
    dataModel.returnData = nil;
    [self addDataToList:dataModel];
}

- (void)addDataToList:(MKSocketDataModel *)dataModel{
    if (!dataModel) {
        return;
    }
    [[self mutableArrayValueForKey:@"dataList"] removeAllObjects];
    [[self mutableArrayValueForKey:@"dataList"] addObject:dataModel];
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
