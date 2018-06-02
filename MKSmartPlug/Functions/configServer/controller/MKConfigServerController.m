//
//  MKConfigServerController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerController.h"
#import "HCKBaseTableView.h"
#import "MKConfigServerAdopter.h"
#import "MKConfigServerCellProtocol.h"
#import "MKConfigServerModel.h"

@interface MKConfigServerController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)HCKBaseTableView *tableView;

@end

@implementation MKConfigServerController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConfigServerController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    //qos选择器出现的时候需要隐藏键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configCellNeedHiddenKeyboard) name:configCellNeedHiddenKeyboardNotification
                                               object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"MQTT Server";
}

- (void)rightButtonMethod{
    WS(weakSelf);
    [MKConfigServerAdopter clearAction:^{
        [MKConfigServerAdopter clearAllConfigCellValuesWithTable:weakSelf.tableView];
    } cancelAction:^{
    }];
}

#pragma mark - delegate
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MKConfigServerAdopter configCellWithIndexPath:indexPath table:tableView];
}

#pragma mark -

#pragma mark - event method

/**
 qos选择器出现的时候需要隐藏键盘
 */
- (void)configCellNeedHiddenKeyboard{
    [MKConfigServerAdopter configCellResignFirstResponderWithTable:self.tableView];
}
- (void)saveButtonPressed{
    MKConfigServerModel *serverModel = [MKConfigServerAdopter currentServerModelWithTable:self.tableView];
    if (!serverModel || ![serverModel needParametersHasValue]) {
        //
        [self.view showCentralToast:@"Required options cannot be empty."];
        return;
    }
    BOOL paramCheck = [MKConfigServerAdopter checkConfigServerParams:serverModel target:self];
    if (!paramCheck) {
        //存在参数错误
        return;
    }
    //保存参数到本地
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.view setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    [self.rightButton setTitle:@"Clear" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - setter & getter
- (HCKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[HCKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [self tableFooter];
        _tableView.tableHeaderView = [self tableHeader];
    }
    return _tableView;
}

- (UIView *)tableHeader{
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20.f)];
    tableHeader.backgroundColor = UIColorFromRGB(0xf2f2f2);
    return tableHeader;
}

- (UIView *)tableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200.f)];
    tableFooter.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setBackgroundColor:NAVIGATION_BAR_COLOR];
    [saveButton.titleLabel setFont:HCKFont(18.f)];
    [saveButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton.layer setMasksToBounds:YES];
    [saveButton.layer setCornerRadius:5.f];
    [saveButton addTapAction:self selector:@selector(saveButtonPressed)];
    [tableFooter addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-75.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

@end
