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

@interface MKDeviceInfoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKDeviceInfoController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceInfoController销毁");
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
    [[MKHudManager share] showHUDWithTitle:@"Deleting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [MKDeviceDataBaseManager deleteDeviceWithMacAddress:self.deviceModel.device_mac sucBlock:^{
        [[MKHudManager share] hide];
        
        [kNotificationCenterSington postNotificationName:MKNeedReadDataFromLocalNotification object:nil];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)resetButtonPressed{
    
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
