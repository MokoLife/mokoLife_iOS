//
//  MKAddDeviceDataManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceDataManager.h"
#import "MKConnectDeviceView.h"
#import "MKConnectDeviceProgressView.h"
#import "MKConnectDeviceWifiView.h"
#import "MKAddDeviceAdopter.h"
#import "MKConnectViewProtocol.h"
#import "MKDeviceDataBaseManager.h"

@interface MKAddDeviceDataManager()<MKConnectViewConfirmDelegate>

@property (nonatomic, copy)void (^completeBlock)(NSError *error, BOOL success, MKDeviceModel *deviceModel);

@property (nonatomic, copy)NSString *wifiSSID;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableArray *viewList;

@property (nonatomic, strong)NSMutableDictionary *deviceDic;

/**
 超过15s没有接收到连接成功数据，则认为连接失败
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

@property (nonatomic, assign)BOOL connectTimeout;

@end

@implementation MKAddDeviceDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceDataManager销毁");
    [kNotificationCenterSington removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        //当前网络状态发生改变的通知
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(networkStatusChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
    }
    return self;
}

+ (MKAddDeviceDataManager *)addDeviceManager{
    return [[self alloc] init];
}

#pragma mark - MKConnectViewConfirmDelegate
- (void)confirmButtonActionWithView:(UIView *)view returnData:(id)returnData{
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return;
    }
    if (view == self.viewList[0]) {
        //MKConnectDeviceView
        [MKAddDeviceAdopter gotoSystemWifiPage];
        return;
    }
    if (view == self.viewList[1]) {
        //MKConnectDeviceWifiView
        if (!ValidDict(returnData)) {
            return;
        }
        self.wifiSSID = returnData[@"ssid"];
        self.password = returnData[@"password"];
        [self connectPlug];
        return;
    }
}

- (void)cancelButtonActionWithView:(UIView *)view{
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    self.completeBlock = nil;
}

#pragma mark - event method

#pragma mark - notification
- (void)networkStatusChanged{
    if (![self needProcessNetworkChanged]) {
        //如果三个alert页面都没有加载到window，则不需要管网络状态改变通知
        return;
    }
    MKConnectDeviceProgressView *progressView = self.viewList[2];
    if ([progressView isShow]) {
        //正在走连接进度流程，直接返回，
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        //需要引导用户去连接smart plug
        [self showConnectDeviceView];
        return;
    }
    [self showDeviceWifiView];
}

- (void)receiveDeviceTopicData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic)
        || self.connectTimeout
        || ![deviceDic[@"mac"] isEqualToString:self.deviceDic[@"device_mac"]]) {
        return;
    }
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    //当前设备已经连上mqtt服务器了
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
        self.receiveTimerCount = 0;
        self.connectTimeout = NO;
    }
    MKConnectDeviceProgressView *progressView = self.viewList[2];
    [progressView setProgress:1.f duration:0.2];
    [self performSelector:@selector(saveDeviceToLocal) withObject:nil afterDelay:0.5];
}

#pragma mark - public method

/**
 是否需要处理网络状态改变通知,如果三个alert页面都没有加载到window，则不需要管网络状态改变通知

 @return YES:需要处理，NO:不需要处理
 */
- (BOOL)needProcessNetworkChanged{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        if ([view isShow]) {
            return YES;
        }
    }
    return NO;
}

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    WS(weakSelf);
    [self connectProgressWithCompleteBlock:^(NSError *error, BOOL success, MKDeviceModel *deviceModel) {
        if (completeBlock) {
            completeBlock(error,success,deviceModel);
        }
        weakSelf.completeBlock = nil;
    }];
}

#pragma mark -
- (void)connectProgressWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    self.completeBlock = nil;
    self.completeBlock = completeBlock;
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(networkStatusChanged)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    [self.viewList removeAllObjects];
    [self loadViewList];
    if (![[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        //需要引导用户去连接smart plug
        [self showConnectDeviceView];
        return;
    }
    [self showDeviceWifiView];
}

#pragma mark - SDK
- (void)connectPlug{
    MKConnectDeviceWifiView *wifiView = self.viewList[1];
    if (![[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        [wifiView showCentralToast:@"Please connect smart plug"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:wifiView isPenetration:NO];
    WS(weakSelf);
    [[MKSmartPlugConnectManager sharedInstance] configDeviceWithWifiSSID:self.wifiSSID password:self.password sucBlock:^(NSDictionary *deviceInfo) {
        [[MKHudManager share] hide];
        weakSelf.deviceDic = nil;
        weakSelf.deviceDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfo];
        [weakSelf connectMQTTServer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
        [weakSelf dismisAllAlertView];
//        [weakView showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)connectMQTTServer{
    //开始连接mqtt服务器
    MKDeviceModel *model = [[MKDeviceModel alloc] initWithDictionary:self.deviceDic];
    [[MKMQTTServerConnectManager sharedInstance] updateMQTTServerTopic:@[[model subscribeTopicInfo]]];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveDeviceTopicData:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    [kNotificationCenterSington removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self startConnectTimer];
    [self showProcessView];
}

- (void)startConnectTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 30.f) {
            //接受数据超时
            [weakSelf connectFailed];
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

- (void)connectFailed{
    self.receiveTimerCount = 0;
    self.connectTimeout = YES;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismisAllAlertView];
        NSError *error = [[NSError alloc] initWithDomain:@"addDeviceDataManager" code:-999 userInfo:@{@"errorInfo":@"Connect failed"}];
        if (self.completeBlock) {
            self.completeBlock(error, NO, nil);
        }
        [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    });
}

- (void)saveDeviceToLocal{
    MKDeviceModel *dataModel = [[MKDeviceModel alloc] initWithDictionary:self.deviceDic];
    NSString *macAddress = self.deviceDic[@"device_mac"];
    macAddress = [[macAddress stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
    dataModel.local_name = [@"MK102-" stringByAppendingString:[macAddress substringWithRange:NSMakeRange(8, 4)]];
    WS(weakSelf);
    [MKDeviceDataBaseManager insertDeviceList:@[dataModel] sucBlock:^{
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(nil, YES, dataModel);
        }
    } failedBlock:^(NSError *error) {
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
    }];
}

#pragma mark - alertView

/**
 当前网络不是plug ap wifi，需要引导用户去连接plug wifi
 */
- (void)showConnectDeviceView{
    id <MKConnectViewProtocol>connectDeviceView = self.viewList[0];
    [connectDeviceView showConnectAlertView];
    id <MKConnectViewProtocol>wifiView = self.viewList[1];
    [wifiView dismiss];
    id <MKConnectViewProtocol>progressView = self.viewList[2];
    [progressView dismiss];
}

/**
 当前网络是plug ap wifi，需要用户输入周围可用的wifi给plug
 */
- (void)showDeviceWifiView{
    id <MKConnectViewProtocol>connectDeviceView = self.viewList[0];
    [connectDeviceView dismiss];
    id <MKConnectViewProtocol>wifiView = self.viewList[1];
    [wifiView showConnectAlertView];
    id <MKConnectViewProtocol>progressView = self.viewList[2];
    [progressView dismiss];
}

/**
 开始连接流程
 */
- (void)showProcessView{
    id <MKConnectViewProtocol>connectDeviceView = self.viewList[0];
    [connectDeviceView dismiss];
    id <MKConnectViewProtocol>wifiView = self.viewList[1];
    [wifiView dismiss];
    MKConnectDeviceProgressView *progressView = self.viewList[2];
    [progressView showConnectAlertView];
    [progressView setProgress:0.3 duration:30.f];
}

- (void)dismisAllAlertView{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        [view dismiss];
    }
}

- (void)loadViewList{
    MKConnectDeviceView *connectDeviceView = [[MKConnectDeviceView alloc] init];
    connectDeviceView.delegate = self;
    MKConnectDeviceWifiView *wifiView = [[MKConnectDeviceWifiView alloc] init];
    wifiView.delegate = self;
    MKConnectDeviceProgressView *progressView = [[MKConnectDeviceProgressView alloc] init];
    progressView.delegate = self;
    [self.viewList addObject:connectDeviceView];
    [self.viewList addObject:wifiView];
    [self.viewList addObject:progressView];
}

#pragma mark - setter & getter
- (NSMutableArray *)viewList{
    if (!_viewList) {
        _viewList = [NSMutableArray arrayWithCapacity:3];
    }
    return _viewList;
}

@end
