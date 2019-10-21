//
//  MKAboutController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAboutController.h"
#import "MKBaseTableView.h"
#import "MKAboutCell.h"
#import "MKAboutModel.h"

@interface MKAboutController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKAboutController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAboutController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self getDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"About";
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
- (void)getDatas{
    MKAboutModel *aboutModel = [[MKAboutModel alloc] init];
    aboutModel.leftMsg = @"App version";
    aboutModel.rightMsg = kAppVersion;
    [self.dataList addObject:aboutModel];
    
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
