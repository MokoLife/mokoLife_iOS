//
//  MKDeviceListController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceListController.h"
#import "MKSettingsController.h"
#import "MKSelectDeviceTypeController.h"
#import "MKBaseTableView.h"
#import "MKDeviceListCell.h"
#import "MKAddDeviceView.h"
#import "MKDeviceListAdopter.h"
#import "MKDeviceDataBaseManager.h"
#import "EasyLodingView.h"
#import "MKConfigDeviceController.h"

@interface MKDeviceListController ()<UITableViewDelegate, UITableViewDataSource, MKDeviceModelDelegate, MKDeviceListCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKAddDeviceView *addDeviceView;

@property (nonatomic, strong)UIView *loadingView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKDeviceListController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceListController销毁");
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerManagerStateChangedNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKNeedReadDataFromLocalNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotification];
    [self performSelector:@selector(networkStatusChanged) withObject:nil afterDelay:2.f];
    [self getDeviceList];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Moko Life";
}

- (void)leftButtonMethod{
    MKSettingsController *vc = [[MKSettingsController alloc] initWithNavigationType:GYNaviTypeShow];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod{
    [MKDeviceListAdopter addDeviceButtonPressed:self];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceModel *dataModel = self.dataList[indexPath.row];
    MKConfigDeviceController *vc = [[MKConfigDeviceController alloc] initWithNavigationType:GYNaviTypeHide];
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:dataModel];
    vc.dataModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceListCell *cell = [MKDeviceListCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKDeviceModelDelegate
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        return;
    }
    [self updateDeviceModelWithState:smartPlugDeviceOffline mac:deviceModel.device_mac];
}

#pragma mark - MKDeviceListCellDelegate
- (void)deviceSwitchStateChanged:(MKDeviceModel *)deviceModel isOn:(BOOL)isOn{
    [MKMQTTServerInterface setSwitchState:isOn deviceModel:deviceModel target:self];
}

#pragma mark - Notification Method
- (void)MQTTServerManagerStateChanged{
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]
        || [[MKNetworkManager sharedInstance] currentWifiIsSmartPlug]) {
        //网络不可用
        [EasyLodingView hidenLoingInView:self.loadingView];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKSessionManagerStateConnecting) {
        //开始连接
        [EasyLodingView showLodingText:@"Connecting..." config:^EasyLodingConfig *{
            EasyLodingConfig *config = [EasyLodingConfig shared];
            config.lodingType = LodingShowTypeIndicatorLeft;
            config.textFont = MKFont(18.f);
            config.bgColor = NAVIGATION_BAR_COLOR;
            config.tintColor = COLOR_WHITE_MACROS;
            config.superView = self.loadingView;
            return config;
        }];
        return;
    }
    [EasyLodingView hidenLoingInView:self.loadingView];
}

- (void)networkStatusChanged{
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
        //网络不可用
        [EasyLodingView hidenLoingInView:self.loadingView];
        [self.view showCentralToast:@"The network is not available"];
    }
}

- (void)receiveSwitchStateData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || self.dataList.count == 0) {
        return;
    }
    smartPlugDeviceState state = ([deviceDic[@"switch_state"] isEqualToString:@"on"] ? smartPlugDeviceOn : smartPlugDeviceStatusOff);
    [self updateDeviceModelWithState:state mac:deviceDic[@"mac"]];
}

#pragma mark - get device list
- (void)getDeviceList{
    WS(weakSelf);
    [MKDeviceDataBaseManager getLocalDeviceListWithSucBlock:^(NSArray<MKDeviceModel *> *deviceList) {
        [weakSelf processLocalDeviceDatas:deviceList];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)processLocalDeviceDatas:(NSArray<MKDeviceModel *> *)deviceList{
    if (!ValidArray(deviceList)) {
        //如果本地没有，则加载添加设备页面，
        [self.view sendSubviewToBack:self.tableView];
        [self.view bringSubviewToFront:self.addDeviceView];
        [self reloadTableViewWithData:@[]];
        return;
    }
    //如果本地有设备，显示设备列表
    [self.view sendSubviewToBack:self.addDeviceView];
    [self.view bringSubviewToFront:self.tableView];
    [self reloadTableViewWithData:deviceList];
}

- (void)reloadTableViewWithData:(NSArray <MKDeviceModel *> *)deviceList{
    //页面消失需要取消model的定时器
    for (MKDeviceModel *model in self.dataList) {
        [model cancel];
    }
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:deviceList];
    [self.tableView reloadData];
    for (MKDeviceModel *model in self.dataList) {
        model.delegate = self;
        [model startStateMonitoringTimer];
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKSessionManagerStateConnected
        && [MKMQTTServerManager sharedInstance].managerState != MKSessionManagerStateConnecting) {
        [[MKMQTTServerConnectManager sharedInstance] connectServer];
    }
    [self resetMQTTServerTopic];
}

- (void)resetMQTTServerTopic{
    if (!ValidArray(self.dataList)) {
        return;
    }
    NSMutableArray *topicList = [NSMutableArray arrayWithCapacity:self.dataList.count];
    for (MKDeviceModel *deviceModel in self.dataList) {
        [topicList addObject:[deviceModel subscribeTopicInfo]];
    }
    [[MKMQTTServerConnectManager sharedInstance] updateMQTTServerTopic:topicList];
}

#pragma mark -
- (void)updateDeviceModelWithState:(smartPlugDeviceState)state mac:(NSString *)mac{
    @synchronized(self) {
        //需要执行的代码
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            for (NSInteger i = 0; i < self.dataList.count; i ++) {
                MKDeviceModel *model = self.dataList[i];
                if ([model.device_mac isEqualToString:mac]) {
                    model.device_state = state;
                    if (state != smartPlugDeviceOffline) {
                        [model resetTimerCounter];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        }];
                    });
                    break;
                }
            }
        });
    }
}

- (void)addNotification{
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(MQTTServerManagerStateChanged)
                                       name:MKMQTTServerManagerStateChangedNotification
                                     object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(networkStatusChanged)
                                       name:MKNetworkStatusChangedNotification
                                     object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveSwitchStateData:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(getDeviceList)
                                       name:MKNeedReadDataFromLocalNotification
                                     object:nil];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.customNaviView.leftButton setImage:LOADIMAGE(@"mokoLife_menuIcon", @"png") forState:UIControlStateNormal];
    [self.customNaviView.rightButton setImage:LOADIMAGE(@"mokoLife_addIcon", @"png") forState:UIControlStateNormal];
    [self.customNaviView setBackgroundColor:NAVIGATION_BAR_COLOR];
    [self.customNaviView addSubview:self.loadingView];
    [self.view addSubview:self.addDeviceView];
    [self.view addSubview:self.tableView];
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.customNaviView.mas_centerX);
        make.width.mas_equalTo(140.f);
        make.top.mas_equalTo(22.f);
        make.bottom.mas_equalTo(-10.f);
    }];
    [self.addDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.customNaviView.mas_bottom).mas_offset(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.customNaviView.mas_bottom).mas_offset(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view sendSubviewToBack:self.addDeviceView];
}

#pragma mark - setter & getter
- (MKAddDeviceView *)addDeviceView{
    if (!_addDeviceView) {
        _addDeviceView = [[MKAddDeviceView alloc] init];
        WS(weakSelf);
        _addDeviceView.addDeviceBlock = ^{
            [weakSelf rightButtonMethod];
        };
    }
    return _addDeviceView;
}

- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
    }
    return _loadingView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
