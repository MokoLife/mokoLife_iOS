//
//  MKSettingsController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSettingsController.h"
#import "HCKBaseTableView.h"
#import "MKSettingsCell.h"
#import "MKConfigServerController.h"

@interface MKSettingsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)HCKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKSettingsController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKSettingsController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Settings";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //device
        MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    //app
    MKConfigServerController *vc = [[MKConfigServerController alloc] initWithNavigationType:GYNaviTypeShow];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKSettingsCell *cell = [MKSettingsCell initCellWithTable:tableView];
    cell.msg = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - setter & getter
- (HCKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[HCKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithObjects:@"MQTT settings for device", @"MQTT settings for APP", nil];
    }
    return _dataList;
}

@end
