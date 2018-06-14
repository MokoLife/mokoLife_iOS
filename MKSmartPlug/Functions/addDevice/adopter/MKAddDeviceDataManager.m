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
#import "MKDeviceModel.h"
#import "MKDeviceDataBaseManager.h"

@interface MKAddDeviceDataManager()<MKConnectViewConfirmDelegate>

@property (nonatomic, copy)void (^completeBlock)(NSError *error, BOOL success);

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
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceiveDataNotification object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        //当前网络状态发生改变的通知
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(networkStatusChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
        [self loadViewList];
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
}

#pragma mark - event method

#pragma mark - notification
- (void)networkStatusChanged{
    if (![self needProcessNetworkChanged]) {
        //如果三个alert页面都没有加载到window，则不需要管网络状态改变通知
        return;
    }
    MKConnectDeviceWifiView *connectDeviceView = self.viewList[0];
    if ([connectDeviceView isShow]) {
        //当前手机没有连plug ap wifi，出现的是引导用户连接设备的alert
        if ([[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
            //如果已经连接到plug了，则进入下一步
            [self showDeviceWifiView];
        }
        return;
    }
}

- (void)receiveDeviceTopicData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || self.connectTimeout) {
        return;
    }
    if ([deviceDic[@"mac"] isEqualToString:self.deviceDic[@"device_mac"]]) {
        //当前设备已经连上mqtt服务器了
        if (self.receiveTimer) {
            dispatch_cancel(self.receiveTimer);
            self.receiveTimerCount = 0;
            self.connectTimeout = NO;
        }
        MKConnectDeviceProgressView *progressView = self.viewList[2];
        [progressView setProgress:1.f duration:0.2];
        [self saveDeviceToLocal];
    }
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

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success))completeBlock{
    self.completeBlock = nil;
    self.completeBlock = completeBlock;
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceiveDataNotification object:nil];
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    if (![[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        //需要引导用户去连接smart plug
        [self showConnectDeviceView];
        return;
    }
    [self showDeviceWifiView];
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
    [progressView setProgress:0.3 duration:10.f];
}

- (void)dismisAllAlertView{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        [view dismiss];
    }
}

#pragma mark - SDK
- (void)connectPlug{
    MKConnectDeviceWifiView *wifiView = self.viewList[1];
    if (![[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        [wifiView showCentralToast:@"Please connect smart plug"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:wifiView isPenetration:NO];
    __weak __typeof(&*wifiView)weakView = wifiView;
    WS(weakSelf);
    [[MKSmartPlugConnectManager sharedInstance] configDeviceWithWifiSSID:self.wifiSSID password:self.password sucBlock:^(NSDictionary *deviceInfo) {
        [[MKHudManager share] hide];
        weakSelf.deviceDic = nil;
        weakSelf.deviceDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfo];
        [weakSelf connectMQTTServer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakView showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)connectMQTTServer{
    //开始连接mqtt服务器
    MKDeviceModel *model = [[MKDeviceModel alloc] initWithDictionary:self.deviceDic];
    [[MKMQTTServerConnectManager sharedInstance] updateMQTTServerTopic:@[[model topicInfo]]];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveDeviceTopicData:)
                                       name:MKMQTTServerReceiveDataNotification
                                     object:nil];
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
        MKConnectDeviceProgressView *progressView = self.viewList[2];
        if ([progressView isShow]) {
            [progressView showCentralToast:@"Connect failed"];
        }
        [self performSelector:@selector(dismisAllAlertView) withObject:nil afterDelay:0.5f];
        [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceiveDataNotification object:nil];
    });
}

- (void)saveDeviceToLocal{
    MKDeviceModel *dataModel = [[MKDeviceModel alloc] initWithDictionary:self.deviceDic];
    NSString *macAddress = self.deviceDic[@"device_mac"];
    macAddress = [[macAddress stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
    dataModel.local_name = [@"MK102-" stringByAppendingString:[macAddress substringWithRange:NSMakeRange(8, 4)]];
    [MKDeviceDataBaseManager insertDeviceList:@[dataModel] sucBlock:^{
        
    } failedBlock:^(NSError *error) {
        
    }];
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
