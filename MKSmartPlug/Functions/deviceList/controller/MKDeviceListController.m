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
#import "MKConfigSwichController.h"

@interface MKDeviceListController ()<UITableViewDelegate, UITableViewDataSource, MKDeviceModelDelegate, MKDeviceListCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKAddDeviceView *addDeviceView;

@property (nonatomic, strong)UIView *loadingView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)CLLocationManager *locationManager;

@end

@implementation MKDeviceListController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceListController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNeedReadDataFromLocalNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTSessionManagerStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNeedUpdateSwichWayNameNotification object:nil];
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

- (void)leftButtonMethod{
    MKSettingsController *vc = [[MKSettingsController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod{
    if ([kSystemVersionString floatValue] >= 13 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        //未授权位置信息
        [self showAuthAlert];
        return;
    }
    [MKDeviceListAdopter addDeviceButtonPressed:self];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceModel *dataModel = self.dataList[indexPath.row];
    if (dataModel.device_mode == MKDevice_plug) {
        MKConfigDeviceController *vc = [[MKConfigDeviceController alloc] init];
        MKDeviceModel *model = [[MKDeviceModel alloc] init];
        [model updatePropertyWithModel:dataModel];
        model.plugState = dataModel.plugState;
        vc.dataModel = model;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (dataModel.device_mode == MKDevice_swich) {
        MKConfigSwichController *vc = [[MKConfigSwichController alloc] init];
        MKDeviceModel *model = [[MKDeviceModel alloc] init];
        [model updatePropertyWithModel:dataModel];
        model.swich_way_nameDic = [NSDictionary dictionaryWithDictionary:dataModel.swich_way_nameDic];
        model.swich_way_stateDic = [NSDictionary dictionaryWithDictionary:dataModel.swich_way_stateDic];
        model.swichState = dataModel.swichState;
        vc.deviceModel = model;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
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
    [self updateDeviceModelState:YES mac:deviceModel.device_mac stateDic:@{}];
}

#pragma mark - MKDeviceListCellDelegate
- (void)deviceSwitchStateChanged:(MKDeviceModel *)deviceModel isOn:(BOOL)isOn{
    if (!deviceModel || !ValidStr(deviceModel.device_mac)) {
        return;
    }
    if (deviceModel.device_mode == MKDevice_plug) {
        //插座
        if (deviceModel.plugState == MKSmartPlugOffline) {
            [self.view showCentralToast:@"Device offline,please check."];
            return;
        }
        [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
        NSString *topic = [deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"switch_state"];
        WS(weakSelf);
        [MKMQTTServerInterface setSmartPlugSwitchState:isOn topic:topic sucBlock:^{
            [[MKHudManager share] hide];
        } failedBlock:^(NSError *error) {
            [[MKHudManager share] hide];
            [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
        }];
    }
}

#pragma mark - MKMQTTServerManagerStateChangedDelegate
- (void)mqttServerManagerStateChanged{
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_swich]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_plug]) {
        //网络不可用
        [EasyLodingView hidenLoingInView:self.loadingView];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnecting) {
        //开始连接
        [EasyLodingView showLodingText:@"Connecting..." config:^EasyLodingConfig *{
            EasyLodingConfig *config = [EasyLodingConfig shared];
            config.lodingType = LodingShowTypeIndicatorLeft;
            config.textFont = MKFont(18.f);
            config.bgColor = UIColorFromRGB(0x0188cc);
            config.tintColor = COLOR_WHITE_MACROS;
            config.superView = self.loadingView;
            return config;
        }];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateError) {
        //连接出错
        [self.view showCentralToast:@"Connect MQTT Server error"];
    }
    [EasyLodingView hidenLoingInView:self.loadingView];
}

#pragma mark - Notification Method
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
    [self updateDeviceModelState:NO mac:deviceDic[@"mac"] stateDic:deviceDic];
}

- (void)updateSwichWayNameNotification:(NSNotification *)note{
    NSDictionary *dic = note.userInfo;
    if (!ValidDict(dic) || self.dataList.count == 0) {
        return;
    }
    /*
     @{@"swich_way_nameDic" : dic, @"device_mac" : weakSelf.deviceModel.device_mac}
     */
    @synchronized(self) {
        //需要执行的代码
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (NSInteger i = 0; i < self.dataList.count; i ++) {
                MKDeviceModel *model = self.dataList[i];
                if ([model.device_mac isEqualToString:dic[@"device_mac"]] && model.device_mode == MKDevice_swich) {
                    model.swich_way_nameDic = dic[@"swich_way_nameDic"];
                    break;
                }
            }
        });
    }
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
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected
        && [MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnecting) {
        [[MKMQTTServerDataManager sharedInstance] connectServer];
    }
    [self resetMQTTServerTopic];
}

- (void)resetMQTTServerTopic{
    if (!ValidArray(self.dataList)) {
        return;
    }
    NSMutableArray *topicList = [NSMutableArray arrayWithCapacity:self.dataList.count];
    for (MKDeviceModel *deviceModel in self.dataList) {
        [topicList addObject:[deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"switch_state"]];
    }
    [[MKMQTTServerManager sharedInstance] subscriptions:topicList];
}

#pragma mark -
- (void)updateDeviceModelState:(BOOL)offline mac:(NSString *)mac stateDic:(NSDictionary *)stateDic{
    @synchronized(self) {
        //需要执行的代码
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            for (NSInteger i = 0; i < self.dataList.count; i ++) {
                MKDeviceModel *model = self.dataList[i];
                if ([model.device_mac isEqualToString:mac]) {
                    if (offline && model.device_mode == MKDevice_swich) {
                        model.swichState = MKSmartSwichOffline;
                    }else if (!offline && model.device_mode == MKDevice_swich){
                        model.swich_way_stateDic = stateDic;
                        model.swichState = MKSmartSwichOnline;
                    }else if (offline && model.device_mode == MKDevice_plug){
                        model.plugState = MKSmartPlugOffline;
                    }else if (!offline && model.device_mode == MKDevice_plug){
                        MKSmartPlugState state = ([stateDic[@"switch_state"] isEqualToString:@"on"] ? MKSmartPlugOn : MKSmartPlugOff);
                        model.plugState = state;
                    }
                    [model resetTimerCounter];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(networkStatusChanged)
                                       name:MKNetworkStatusChangedNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(receiveSwitchStateData:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(getDeviceList)
                                       name:MKNeedReadDataFromLocalNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(mqttServerManagerStateChanged)
                                       name:MKMQTTSessionManagerStateChangedNotification
                                     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(updateSwichWayNameNotification:)
                                       name:MKNeedUpdateSwichWayNameNotification
                                     object:nil];
}

- (void)showAuthAlert {
    NSString *msg = @"Please go to Settings-Privacy-Location Services to turn on location services permission.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Note"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MKAddDeviceCenter gotoSystemWifiPage];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.leftButton setImage:LOADIMAGE(@"mokoLife_menuIcon", @"png") forState:UIControlStateNormal];
    [self.rightButton setImage:LOADIMAGE(@"mokoLife_addIcon", @"png") forState:UIControlStateNormal];
    self.titleLabel.text = @"Moko Life";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.titleLabel addSubview:self.loadingView];
    [self.view addSubview:self.addDeviceView];
    [self.view addSubview:self.tableView];
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(-5.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-5.f);
    }];
    [self.addDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
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

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

@end
