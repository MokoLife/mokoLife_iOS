//
//  MKDeviceInfoController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInfoController.h"
#import "MKBaseTableView.h"
#import "MKDeviceInfoCell.h"
#import "MKDeviceInfoModel.h"
#import "MKModifyLocalNameView.h"
#import "MKDeviceDataBaseManager.h"
#import "MKDeviceInfoAdopter.h"
#import "MKAboutController.h"
#import "MKDeviceInformationController.h"

@interface MKDeviceInfoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKDeviceInfoController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceInfoController销毁");
    //取消订阅
    [[MKMQTTServerManager sharedInstance] unsubscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"]]];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedUpdateResultNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self getDeviceLocalName];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"More";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //修改名称
        MKModifyLocalNameView *view = [[MKModifyLocalNameView alloc] init];
        WS(weakSelf);
        [view showConnectAlertView:self.deviceModel.local_name block:^(NSString *name) {
            [weakSelf updateDeviceLocalName:name];
        }];
        return;
    }
    if (indexPath.row == 3) {
        //关于
        MKAboutController *vc = [[MKAboutController alloc] initWithNavigationType:GYNaviTypeShow];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (![self canClickEnable]) {
        return;
    }
    if (indexPath.row == 1) {
        //设备信息
        [self readFirmwareInfo];
        return;
    }
    if (indexPath.row == 2) {
        //固件升级
        [self updateFirmware];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceInfoCell *cell = [MKDeviceInfoCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)removeButtonPressed{
    [MKDeviceInfoAdopter deleteDeviceWithModel:self.deviceModel target:self reset:NO];
}

- (void)resetButtonPressed{
    [MKDeviceInfoAdopter deleteDeviceWithModel:self.deviceModel target:self reset:YES];
}

- (void)readFirmwareInfo{
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"read_firmware_infor"];
    WS(weakSelf);
    [MKMQTTServerInterface readDeviceFirmwareInformationWithTopic:topic sucBlock:^{
        [[MKHudManager share] hide];
        MKDeviceInformationController *vc = [[MKDeviceInformationController alloc] initWithNavigationType:GYNaviTypeShow];
        MKDeviceModel *model = [[MKDeviceModel alloc] init];
        [model updatePropertyWithModel:weakSelf.deviceModel];
        vc.deviceModel = model;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - note
- (void)firmwareUpdateResult:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    //固件升级结果
    //取消订阅的固件升级主题,取消升级结果监听通知
    [[MKMQTTServerManager sharedInstance] unsubscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"]]];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedUpdateResultNotification object:nil];
    [[MKHudManager share] hide];
    if ([deviceDic[@"ota_result"] isEqualToString:@"R1"]) {
        //升级成功
        [self.view showCentralToast:@"Update Success!"];
        return;
    }
    //升级失败
    [self.view showCentralToast:@"Update Failed!"];
}

#pragma mark - 数据库操作
- (void)getDeviceLocalName{
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [MKDeviceDataBaseManager selectLocalNameWithMacAddress:self.deviceModel.device_mac sucBlock:^(NSString *localName) {
        [[MKHudManager share] hide];
        weakSelf.deviceModel.local_name = localName;
        [weakSelf loadDatas];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf loadDatas];
    }];
}

- (void)updateDeviceLocalName:(NSString *)localName{
    [[MKHudManager share] showHUDWithTitle:@"Setting" inView:self.view isPenetration:NO];
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:self.deviceModel];
    model.local_name = localName;
    WS(weakSelf);
    [MKDeviceDataBaseManager updateDevice:model sucBlock:^{
        [[MKHudManager share] hide];
        [weakSelf modifyNameSuccess:localName];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)updateFirmware{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return;
    }
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicAppType function:@"upgrade"];
    [[MKHudManager share] showHUDWithTitle:@"Updating..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [MKMQTTServerInterface updateFirmware:MKFirmwareUpdateHostTypeIP host:@"23.83.237.116" port:80 catalogue:@"smartplug/20180623/" topic:topic sucBlock:^{
        //发送成功订阅升级结果主题
        [[MKMQTTServerManager sharedInstance] subscriptions:@[[weakSelf.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"ota_upgrade_state"]]];
        //监听升级结果
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(firmwareUpdateResult:)
                                           name:MKMQTTServerReceivedUpdateResultNotification
                                         object:nil];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (BOOL)canClickEnable{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return NO;
    }
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected) {
        [self.view showCentralToast:@"Network error,please check."];
        return NO;
    }
    return YES;
}

#pragma mark - ui
- (void)loadSubViews{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)modifyNameSuccess:(NSString *)localName{
    self.deviceModel.local_name = localName;
    MKDeviceInfoModel *nameModel = self.dataList[0];
    nameModel.rightMsg = localName;
    [UIView performWithoutAnimation:^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }];
    [kNotificationCenterSington postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
}

- (void)loadDatas{
    MKDeviceInfoModel *nameModel = [[MKDeviceInfoModel alloc] init];
    nameModel.leftMsg = @"Modify device name";
    nameModel.rightMsg = self.deviceModel.local_name;
    [self.dataList addObject:nameModel];
    
    MKDeviceInfoModel *infoModel = [[MKDeviceInfoModel alloc] init];
    infoModel.leftMsg = @"Device information";
    [self.dataList addObject:infoModel];
    
    MKDeviceInfoModel *firmwareModel = [[MKDeviceInfoModel alloc] init];
    firmwareModel.leftMsg = @"Check firmware update";
    [self.dataList addObject:firmwareModel];
    
    MKDeviceInfoModel *aboutModel = [[MKDeviceInfoModel alloc] init];
    aboutModel.leftMsg = @"About";
    [self.dataList addObject:aboutModel];
    
    [self.tableView reloadData];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self footView];
    }
    return _tableView;
}

- (UIView *)footView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 3 * 44.f - 64.f)];
    footView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *removeButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Remove Device" target:self action:@selector(removeButtonPressed)];
    UIButton *resetButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Reset" target:self action:@selector(resetButtonPressed)];
    [footView addSubview:removeButton];
    [footView addSubview:resetButton];
    [removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(55.f);
        make.right.mas_equalTo(-55.f);
        make.bottom.mas_equalTo(resetButton.mas_top).mas_offset(-20.f);
        make.height.mas_equalTo(45.f);
    }];
    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(55.f);
        make.right.mas_equalTo(-55.f);
        make.bottom.mas_equalTo(-100.f);
        make.height.mas_equalTo(45.f);
    }];
    
    return footView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
