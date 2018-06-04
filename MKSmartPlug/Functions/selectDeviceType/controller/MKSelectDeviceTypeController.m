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
    if (indexPath.row == 0) {
        MKAddDeviceController *vc = [[MKAddDeviceController alloc] initWithNavigationType:GYNaviTypeShow];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
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
    MKSelectDeviceTypeModel *typeModel = [[MKSelectDeviceTypeModel alloc] init];
    typeModel.msg = @"Moko plug";
    typeModel.leftIconName = @"selectDeviceType_plugIcon";
    [self.dataList addObject:typeModel];
    [self.tableView reloadData];
}

- (void)loadSubViews{
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.leftButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
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
