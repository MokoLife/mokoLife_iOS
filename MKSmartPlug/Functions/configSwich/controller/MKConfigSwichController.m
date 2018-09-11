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
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
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
        NSString *key = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(i + 1)];
        NSString *state = (model.isOn ? @"on" : @"off");
        [dic setObject:state forKey:key];
    }
    NSString *changeKey = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(index + 1)];
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
    NSString *key = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(index + 1)];
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
    NSString *indexString = [NSString stringWithFormat:@"%ld",(long)(index + 1)];
    NSString *function = [@"delay_time_0" stringByAppendingString:indexString];
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:function];
    NSDictionary *dataDic = @{
                              [@"delay_hour_0" stringByAppendingString:indexString]:@([hour integerValue]),
                              [@"delay_minute_0" stringByAppendingString:indexString]:@([min integerValue]),
                              };
    WS(weakSelf);
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
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
        NSString *key = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(i + 1)];
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
        NSString *key = [NSString stringWithFormat:@"%@%ld",@"delay_time_0",(long)(i + 1)];
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
        NSString *key = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(i + 1)];
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
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
