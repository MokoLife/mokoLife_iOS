//
//  MKSelectDeviceTypeController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSelectDeviceTypeController.h"
#import "MKBaseTableView.h"
#import "MKSelectDeviceTypeCell.h"
#import "MKSelectDeviceTypeModel.h"
#import "MKAddDeviceController.h"

@interface MKSelectDeviceTypeController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKSelectDeviceTypeController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKSelectDeviceTypeController销毁");
    [MKAddDeviceCenter deallocCenter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Select Device Type";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MKDeviceType deviceType = MKDevice_plug;
    if (indexPath.row == 1){
        //面板
        deviceType = MKDevice_swich;
    }
    [MKAddDeviceCenter sharedInstance].deviceType = deviceType;
    MKAddDeviceController *vc = [[MKAddDeviceController alloc] initWithNavigationType:GYNaviTypeShow];
    NSDictionary *params = [[MKAddDeviceCenter sharedInstance] fecthAddDeviceParams];
    [vc configAddDeviceController:params];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKSelectDeviceTypeCell *cell = [MKSelectDeviceTypeCell initCellWithTable:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark -
- (void)loadDatas{
    MKSelectDeviceTypeModel *plugModel = [[MKSelectDeviceTypeModel alloc] init];
    plugModel.msg = @"Moko plug";
    plugModel.leftIconName = @"selectDeviceType_plugIcon";
    [self.dataList addObject:plugModel];
    
    MKSelectDeviceTypeModel *swichModel = [[MKSelectDeviceTypeModel alloc] init];
    swichModel.msg = @"Wall Swich";
    swichModel.leftIconName = @"selectDeviceType_swichIcon";
    [self.dataList addObject:swichModel];
    [self.tableView reloadData];
}

- (void)loadSubViews{
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.leftButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
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
