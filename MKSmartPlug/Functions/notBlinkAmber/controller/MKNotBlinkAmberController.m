//
//  MKNotBlinkAmberController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkAmberController.h"
#import "MKNotBlinkAmberCell.h"
#import "MKNotBlinkAmberModel.h"
#import "MKBaseTableView.h"

@interface MKNotBlinkAmberController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKNotBlinkAmberController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKNotBlinkAmberController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self getInitDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Operation Steps";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 225.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKNotBlinkAmberCell *cell = [MKNotBlinkAmberCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)blinkButtonPressed{
    [self leftButtonMethod];
    if (self.blinkButtonPressedBlock) {
        self.blinkButtonPressedBlock();
    }
}

#pragma mark - loadSubViews

- (void)getInitDatas{
    MKNotBlinkAmberModel *step1Model = [[MKNotBlinkAmberModel alloc] init];
    step1Model.stepMsg = @"Step 1";
    step1Model.operationMsg = @"Plug the device in power";
    step1Model.leftIconName = @"notBlinkAmberStep1_leftIcon";
    step1Model.rightIconName = @"notBlinkAmberStep1_rightIcon";
    [self.dataList addObject:step1Model];
    
    MKNotBlinkAmberModel *step2Model = [[MKNotBlinkAmberModel alloc] init];
    step2Model.stepMsg = @"Step 2";
    step2Model.operationMsg = @"Hold the button for 10s until the LED blink amber";
    step2Model.leftIconName = @"notBlinkAmberStep2_leftIcon";
    step2Model.rightIconName = @"notBlinkAmberStep2_rightIcon";
    [self.dataList addObject:step2Model];
    [self.tableView reloadData];
}

- (void)loadSubViews{
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
        
        _tableView.tableFooterView = [self tableFooter];
    }
    return _tableView;
}

- (UIView *)tableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150.f)];
    tableFooter.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *blinkButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Indicator blink amber light"
                                                                     target:self
                                                                     action:@selector(blinkButtonPressed)];
    [tableFooter addSubview:blinkButton];
    [blinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-50.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
