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
#import "MKDeviceModel.h"
#import "MKAddDeviceView.h"
#import "MKDeviceListAdopter.h"
#import "MKDeviceDataBaseManager.h"
#import "EasyLodingView.h"

@interface MKDeviceListController ()<UITableViewDelegate, UITableViewDataSource>

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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDeviceList];
    //开始连接
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(MQTTServerManagerStateChanged)
                                       name:MKMQTTServerManagerStateChangedNotification
                                     object:nil];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceListCell *cell = [MKDeviceListCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
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
    if ([MKMQTTServerManager sharedInstance].managerState == MKSessionManagerStateConnected) {
        //开始成功
        [EasyLodingView hidenLoingInView:self.loadingView];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKSessionManagerStateError) {
        //连接出错
        [EasyLodingView hidenLoingInView:self.loadingView];
        return;
    }
}

#pragma mark - get device list
- (void)getDeviceList{
    WS(weakSelf);
//    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [MKDeviceDataBaseManager getLocalDeviceListWithSucBlock:^(NSArray<MKDeviceModel *> *deviceList) {
//        [[MKHudManager share] hide];
        [weakSelf processLocalDeviceDatas:deviceList];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)processLocalDeviceDatas:(NSArray<MKDeviceModel *> *)deviceList{
    if (!ValidArray(deviceList)) {
        //如果本地没有，则加载添加设备页面，
        [self reloadTableViewWithData:@[]];
        [self.view sendSubviewToBack:self.tableView];
        [self.view bringSubviewToFront:self.addDeviceView];
        return;
    }
    //如果本地有设备，显示设备列表
    [self reloadTableViewWithData:deviceList];
    [self.view sendSubviewToBack:self.addDeviceView];
    [self.view bringSubviewToFront:self.tableView];
}

- (void)reloadTableViewWithData:(NSArray <MKDeviceModel *> *)deviceList{
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:deviceList];
    [self.tableView reloadData];
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
