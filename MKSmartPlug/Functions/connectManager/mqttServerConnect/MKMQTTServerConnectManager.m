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

@property (nonatomic, copy)void (^connectProgressBlock)(CGFloat progress);

@property (nonatomic, copy)void (^connectSucBlock)(void);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

@property (nonatomic, assign)MKSessionManagerState managerState;

@end

@implementation MKMQTTServerConnectManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerManagerStateChangedNotification object:nil];
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MQTTServerManagerStateChanged) name:MKMQTTServerManagerStateChangedNotification
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

#pragma mark - notice method
- (void)MQTTServerManagerStateChanged{
    self.managerState = [MKMQTTServerManager sharedInstance].managerState;
}

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    [self.configServerModel updateServerDataWithModel:model];
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
 
 @param progressBlock 连接进度回调
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectMqttServerWithProgressBlock:(void (^)(CGFloat progress))progressBlock
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock{
    self.connectProgressBlock = progressBlock;
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = failedBlock;
    [self connectServer];
}

#pragma mark -
- (void)connectServer{
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:self.configServerModel.host
                                                       port:[self.configServerModel.port integerValue]
                                                        tls:NO
                                                  keepalive:[self.configServerModel.keepAlive integerValue] clean:self.configServerModel.cleanSession auth:NO
                                                       user:self.configServerModel.userName
                                                       pass:self.configServerModel.password
                                                   clientId:self.configServerModel.clientId
                                            connectSucBlock:^{
        NSLog(@"连接成功");
    }
                                         connectFailedBlock:^(NSError *error) {
        NSLog(@"连接失败");
    }];
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
