//
//  MKElectricityController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKElectricityController.h"
#import "MKBaseTableView.h"
#import "MKElectricityCell.h"
#import "MKElectricityModel.h"

@interface MKElectricityController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKElectricityController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKElectricityController销毁");
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedElectricityNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self loadDatas];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveElectricityData:)
                                       name:MKMQTTServerReceivedElectricityNotification
                                     object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Electricity Management";
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
    MKElectricityCell *cell = [MKElectricityCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - Notification Event
- (void)receiveElectricityData:(NSNotification *)note{
    if (!ValidStr(self.device_mac)) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.device_mac]) {
        return;
    }
    if (ValidNum(deviceDic[@"current"])) {
        MKElectricityModel *currentModel = self.dataList[0];
        currentModel.value = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"current"] integerValue]];
    }
    if (ValidNum(deviceDic[@"voltage"])) {
        MKElectricityModel *volModel = self.dataList[1];
        volModel.value = [NSString stringWithFormat:@"%.1f",([deviceDic[@"voltage"] integerValue] * 0.1)];
    }
    if (ValidNum(deviceDic[@"power"])) {
        MKElectricityModel *powerModel = self.dataList[2];
        powerModel.value = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"power"] integerValue]];
    }
    [self.tableView reloadData];
}

#pragma mark - private method
- (void)loadDatas{
    MKElectricityModel *currentModel = [[MKElectricityModel alloc] init];
    currentModel.iconName = @"electricityCurrentIcon";
    currentModel.textMsg = @"Current(mA)";
    currentModel.value = @"0";
    [self.dataList addObject:currentModel];
    
    MKElectricityModel *volModel = [[MKElectricityModel alloc] init];
    volModel.iconName = @"electricityVoltageIcon";
    volModel.textMsg = @"Voltage(V)";
    volModel.value = @"0";
    [self.dataList addObject:volModel];
    
    MKElectricityModel *powerModel = [[MKElectricityModel alloc] init];
    powerModel.iconName = @"electricityPowerIcon";
    powerModel.textMsg = @"Power(W)";
    powerModel.value = @"0";
    [self.dataList addObject:powerModel];
    
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
        _dataList = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataList;
}

@end
