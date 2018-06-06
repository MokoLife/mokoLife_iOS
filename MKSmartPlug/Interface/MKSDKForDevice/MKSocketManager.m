//
//  MKSocketManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSocketManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
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

//- (void)configMQTTServerHost:(NSString *)host port:(NSInteger)port clientId:(NSString *)clientId

/**
 获取当前手机连接的wifi ssid
 
 @return wifi ssid
 */
+ (NSString *)currentWifiSSID{
    CFArrayRef tempArray = CNCopySupportedInterfaces();
    if (!tempArray) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    NSDictionary* wifiDic = (__bridge NSDictionary *) CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(tempArray, 0));
    NSLog(@"%@",wifiDic);
    if (!ValidDict(wifiDic)) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    CFRelease(tempArray);
    return wifiDic[@"SSID"];
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
        if (!returnData) {
            //出错
            [MKSocketBlockAdopter operationGetDataErrorBlock:failedBlock];
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
