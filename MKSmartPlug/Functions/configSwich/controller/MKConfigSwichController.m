//
//  MKConfigSwichController.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigSwichController.h"
#import "MKBaseTableView.h"
#import "MKConfigSwichCell.h"
#import "MKConfigSwichModel.h"
#import "MKDeviceDataBaseManager.h"
#import "MKModifyLocalNameView.h"
#import "MKConfigDeviceTimePickerView.h"
#import "MKDeviceInfoController.h"

@interface MKConfigSwichController ()<UITableViewDelegate, UITableViewDataSource, MKConfigSwichCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKConfigSwichController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConfigSwichController销毁");
    [self.deviceModel cancel];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSwitchStateNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedDelayTimeNotification object:nil];
    //取消订阅倒计时主题
    [[MKMQTTServerManager sharedInstance] unsubscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delay_time"]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    UIView *footView = [self footerView];
    [self.view addSubview:footView];
    [footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(90.f);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(footView.mas_top);
    }];
    [self getTableDatas];
    [self addNotifications];
    //订阅倒计时主题
    [[MKMQTTServerManager sharedInstance] subscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delay_time"]]];
    [self.deviceModel startStateMonitoringTimer];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"MokoLife";
}

- (void)rightButtonMethod{
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] initWithNavigationType:GYNaviTypeShow];
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:self.deviceModel];
    model.swichState = self.deviceModel.swichState;
    vc.deviceModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5.f)];
    footer.backgroundColor = RGBCOLOR(239, 239, 239);
    return footer;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKConfigSwichCell *cell = [MKConfigSwichCell initCellWithTable:tableView];
    cell.dataModel = self.dataList[indexPath.section];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKConfigSwichCellDelegate
- (void)changedSwichState:(BOOL)isOn index:(NSInteger)index{
    if (![self canClickEnable]) {
        return;
    }
    if (index < 0 || index > self.dataList.count - 1) {
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKConfigSwichModel *model = self.dataList[i];
        NSString *state = (model.isOn ? @"on" : @"off");
        [dic setObject:state forKey:[MKDeviceModel keyForSwitchStateWithIndex:i]];
    }
    NSString *changeKey = [MKDeviceModel keyForSwitchStateWithIndex:index];
    NSString *changeState = (isOn ? @"on" : @"off");
    [dic setObject:changeState forKey:changeKey];
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"switch_state"];
    WS(weakSelf);
    [[MKMQTTServerManager sharedInstance] sendData:dic topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)modifySwichWayNameWithIndex:(NSInteger)index{
    MKConfigSwichModel *model = self.dataList[index];
    MKModifyLocalNameView *view = [[MKModifyLocalNameView alloc] init];
    WS(weakSelf);
    [view showConnectAlertView:model.currentWaySwitchName block:^(NSString *name) {
        [weakSelf updateSwichWayName:name index:index];
    }];
}

- (void)swichStartCountdownWithIndex:(NSInteger)index{
    if (![self canClickEnable]) {
        return;
    }
    MKConfigSwichModel *model = self.dataList[index];
    MKConfigDeviceTimeModel *timeModel = [[MKConfigDeviceTimeModel alloc] init];
    timeModel.hour = @"0";
    timeModel.minutes = @"0";
    timeModel.titleMsg = (model.isOn ? @"Countdown timer(off)" : @"Countdown timer(on)");
    MKConfigDeviceTimePickerView *pickView = [[MKConfigDeviceTimePickerView alloc] init];
    pickView.timeModel = timeModel;
    WS(weakSelf);
    [pickView showTimePickViewBlock:^(MKConfigDeviceTimeModel *timeModel) {
        [weakSelf startCountdownWithIndex:index hour:timeModel.hour min:timeModel.minutes];
    }];
}

- (void)scheduleSwichWayWithIndex:(NSInteger)index{
    if (![self canClickEnable]) {
        return;
    }
    [self.view showCentralToast:@"The timing function needs to be improved."];
}

#pragma mark - event method
- (void)updateSwichWayName:(NSString *)name index:(NSInteger)index{
    NSString *key = [MKDeviceModel keyForSwitchStateWithIndex:index];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.deviceModel.swich_way_nameDic];
    [dic setObject:name forKey:key];
    self.deviceModel.swich_way_nameDic = dic;
    WS(weakSelf);
    [MKDeviceDataBaseManager updateDevice:self.deviceModel sucBlock:^{
        [weakSelf getTableDatas];
        [kNotificationCenterSington postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
    } failedBlock:^(NSError *error) {
        
    }];
}

- (void)startCountdownWithIndex:(NSInteger)index hour:(NSString *)hour min:(NSString *)min{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    NSString *function = [MKDeviceModel keyForDelayTimeWithIndex:index];
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:function];
    WS(weakSelf);
    [MKMQTTServerInterface setSwichWithIndex:index delayHour:[hour integerValue] delayMin:[min integerValue] topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)setAllSwichWayOnMethod{
    [self setSwichAllWaySwitchStateOn:YES];
}

- (void)setAllSwichWayOffMethod{
    [self setSwichAllWaySwitchStateOn:NO];
}

#pragma mark - 通知处理
- (void)switchStateNotification:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    self.deviceModel.swichState = MKSmartSwichOnline;
    [self.deviceModel resetTimerCounter];
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKConfigSwichModel *model = self.dataList[i];
        NSString *key = [MKDeviceModel keyForSwitchStateWithIndex:i];
        model.isOn = [deviceDic[key] isEqualToString:@"on"];
    }
    [self.tableView reloadData];
}

- (void)delayTimeNotification:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    [self.deviceModel resetTimerCounter];
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        NSString *key = [MKDeviceModel keyForDelayTimeWithIndex:i];
        MKConfigSwichModel *model = self.dataList[i];
        model.countdown = deviceDic[key];
    }
    [self.tableView reloadData];
}

#pragma mark -
- (void)addNotifications{
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(switchStateNotification:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(delayTimeNotification:)
                                       name:MKMQTTServerReceivedDelayTimeNotification
                                     object:nil];
}

- (BOOL)canClickEnable{
    if (self.deviceModel.swichState == MKSmartSwichOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return NO;
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected) {
        [self.view showCentralToast:@"Network error,please check."];
        return NO;
    }
    return YES;
}

- (void)setSwichAllWaySwitchStateOn:(BOOL)allOn{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        NSString *state = (allOn ? @"on" : @"off");
        [dic setObject:state forKey:[MKDeviceModel keyForSwitchStateWithIndex:i]];
    }
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"switch_state"];
    WS(weakSelf);
    [[MKMQTTServerManager sharedInstance] sendData:dic topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - local data

- (void)getTableDatas{
    if (!self.deviceModel) {
        return;
    }
    [self.dataList removeAllObjects];
    NSInteger listCount = [self.deviceModel.device_type integerValue];
    NSDictionary *swichNameDic = self.deviceModel.swich_way_nameDic;
    NSDictionary *swichStateDic = self.deviceModel.swich_way_stateDic;
    for (NSInteger i = 0; i < listCount; i ++) {
        MKConfigSwichModel *model = [[MKConfigSwichModel alloc] init];
        NSString *key = [MKDeviceModel keyForSwitchStateWithIndex:i];
        model.currentWaySwitchName = swichNameDic[key];
        model.index = i;
        model.isOn = [swichStateDic[key] isEqualToString:@"on"];
        [self.dataList addObject:model];
    }
    [self.tableView reloadData];
}

#pragma mark -

- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)bottomButtonViewWithTitle:(NSString *)title iconName:(NSString *)iconName sel:(SEL)sel{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = LOADIMAGE(iconName, @"png");
    [buttonView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(buttonView.mas_centerX);
        make.width.mas_equalTo(25.f);
        make.height.mas_equalTo(25.f);
    }];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColorFromRGB(0x0188cc);
    titleLabel.font = MKFont(12.f);
    titleLabel.text = title;
    [buttonView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    [buttonView addTapAction:self selector:sel];
    return buttonView;
}

- (UIView *)footerView{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = COLOR_WHITE_MACROS;
    UIView *allOnView = [self bottomButtonViewWithTitle:@"ALL ON"
                                               iconName:@"configSwichAllOff"
                                                    sel:@selector(setAllSwichWayOnMethod)];
    UIView *allOffView = [self bottomButtonViewWithTitle:@"ALL OFF"
                                                iconName:@"configSwichAllOn"
                                                     sel:@selector(setAllSwichWayOffMethod)];
    [footerView addSubview:allOnView];
    [footerView addSubview:allOffView];
    [allOnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(footerView.mas_centerX).mas_offset(-50.f);
        make.width.mas_equalTo(50.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(50.f);
    }];
    [allOffView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(footerView.mas_centerX).mas_offset(50.f);
        make.width.mas_equalTo(50.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(50.f);
    }];
    return footerView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
