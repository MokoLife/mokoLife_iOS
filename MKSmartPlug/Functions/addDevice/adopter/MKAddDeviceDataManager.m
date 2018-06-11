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
#import "MKSmartPlugConnectManager.h"

@interface MKAddDeviceDataManager()<MKConnectViewConfirmDelegate>

@property (nonatomic, copy)void (^completeBlock)(NSError *error, BOOL success);

@property (nonatomic, copy)NSString *wifiSSID;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableArray *viewList;

@end

@implementation MKAddDeviceDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceDataManager销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        //当前网络状态发生改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
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
    if (view == self.viewList[2]) {
        //MKConnectDeviceProgressView
        return;
    }
}

- (void)cancelButtonActionWithView:(UIView *)view{
    
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
        if ([MKAddDeviceAdopter currentWifiIsSmartPlug]) {
            //如果已经连接到plug了，则进入下一步
            [self showDeviceWifiView];
        }
        return;
    }
    id <MKConnectViewProtocol>wifiView = self.viewList[1];
    if ([wifiView isShow]) {
        //当前手机已经连接到了目标设备wifi，出现的需要设置给plug连接的wifi ssid、password alert
        return;
    }
    MKConnectDeviceProgressView *progressView = self.viewList[2];
    if (![progressView isShow]) {
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
//        if ([progressView currentProgress] == 0.1f) {
//            //不可用,提示错误
//            [progressView showCentralToast:@"Connect error,please check your network is available"];
//        }
        //由于切换网络引起的不可用，暂时不处理，因为这个时候还没有开始连接mqtt服务器流程
        return;
    }
    //设置plug已经完成，需要开启app->>mqtt服务器流程,当前网络状态必须可用，并且连接的wifi不能是smartPlug设备
    if ([MKAddDeviceAdopter currentWifiIsSmartPlug]) {
        //必须连接了wifi并且非plug设备
        [progressView showCentralToast:@"Network cannot be smart plug!"];
        [self performSelector:@selector(dismisAllAlertView) withObject:nil afterDelay:0.5f];
        return;
    }
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:@"111.111.111.1" port:8080 tls:YES keepalive:60 clean:YES auth:YES user:@"asdf" pass:@"12345" clientId:@"tehckaj" connectSucBlock:^{
        NSLog(@"Success");
    } connectFailedBlock:^(NSError *error) {
        [progressView showCentralToast:@"Connect mqtt!"];
        [self performSelector:@selector(dismisAllAlertView) withObject:nil afterDelay:0.5f];
    }];
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
    if (![MKAddDeviceAdopter currentWifiIsSmartPlug]) {
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
    [progressView setProgress:0.3 duration:60.f];
}

- (void)dismisAllAlertView{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        [view dismiss];
    }
}

#pragma mark - SDK
- (void)connectPlug{
    MKConnectDeviceWifiView *wifiView = self.viewList[1];
    if (![MKAddDeviceAdopter currentWifiIsSmartPlug]) {
        [wifiView showCentralToast:@"Please connect smart plug"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:wifiView isPenetration:NO];
    __weak __typeof(&*wifiView)weakView = wifiView;
    WS(weakSelf);
    [MKSmartPlugConnectManager configDeviceWithWifiSSID:self.wifiSSID password:self.password sucBlock:^{
        [[MKHudManager share] hide];
        //开始连接mqtt服务器
        [weakSelf connectMqttServer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakView showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)connectMqttServer{
    [[MKSocketManager sharedInstance] disconnect];
    [self showProcessView];
}

#pragma mark - private method
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
