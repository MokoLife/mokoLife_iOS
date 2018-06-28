//
//  MKDeviceInformationController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInformationController.h"
#import "MKBaseTableView.h"
#import "MKAboutCell.h"
#import "MKAboutModel.h"

@interface MKDeviceInformationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKDeviceInformationController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceInformationController销毁");
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
    //取消订阅固件主题
    [[MKMQTTServerManager sharedInstance] unsubscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"firmware_infor"]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveDeviceFirmware:)
                                       name:MKMQTTServerReceivedFirmwareInfoNotification
                                     object:nil];
    [self initReadTimer];
    //订阅固件信息通知
    [[MKMQTTServerManager sharedInstance] subscriptions:@[[self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"firmware_infor"]]];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Device Information";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKAboutCell *cell = [MKAboutCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark -
- (void)receiveDeviceFirmware:(NSNotification *)note{
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
    [[MKHudManager share] hide];
    [self getDatasWithInfo:deviceDic];
}

#pragma mark -

- (void)initReadTimer{
    self.readTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.readTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.readTimer, ^{
        weakSelf.readTimeout = YES;
        dispatch_cancel(weakSelf.readTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MKHudManager share] hide];
            [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
            [weakSelf.view showCentralToast:@"Get data failed!"];
            [weakSelf performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
        });
    });
    dispatch_resume(self.readTimer);
}

- (void)getDatasWithInfo:(NSDictionary *)infoDic{
    MKAboutModel *companyModel = [[MKAboutModel alloc] init];
    companyModel.leftMsg = @"Company Name";
    companyModel.rightMsg = infoDic[@"company_name"];
    [self.dataList addObject:companyModel];
    
    MKAboutModel *dateModel = [[MKAboutModel alloc] init];
    dateModel.leftMsg = @"Date of Manufacture";
    dateModel.rightMsg = infoDic[@"production_date"];
    [self.dataList addObject:dateModel];
    
    MKAboutModel *nameModel = [[MKAboutModel alloc] init];
    nameModel.leftMsg = @"Device Name";
    nameModel.rightMsg = infoDic[@"product_model"];
    [self.dataList addObject:nameModel];
    
    MKAboutModel *firmModel = [[MKAboutModel alloc] init];
    firmModel.leftMsg = @"Firmware Version";
    firmModel.rightMsg = infoDic[@"firmware_version"];
    [self.dataList addObject:firmModel];
    
    [self.tableView reloadData];
}

#pragma mark - setter & getter
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
