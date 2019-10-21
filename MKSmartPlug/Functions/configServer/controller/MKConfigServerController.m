//
//  MKConfigServerController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerController.h"
#import "MKBaseTableView.h"
#import "MKConfigServerAdopter.h"
#import "MKConfigServerCellProtocol.h"
#import "MKConfigServerModel.h"

@interface MKConfigServerController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKConfigServerModel *serverModel;

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
    if (self.controllerType == MKConfigServerForApp) {
        [self.serverModel updateServerDataWithModel:[MKMQTTServerDataManager sharedInstance].configServerModel];
    }else{
        [self.serverModel updateServerDataWithModel:[MKSmartPlugConnectManager sharedInstance].configServerModel];
    }
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法

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
    return ((self.controllerType == MKConfigServerForApp) ? 7 : 6);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MKConfigServerAdopter configCellWithIndexPath:indexPath
                                                    table:tableView
                                              configModel:self.serverModel
                                                    isApp:(self.controllerType == MKConfigServerForApp)];
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
    BOOL isApp = (self.controllerType == MKConfigServerForApp);
    MKConfigServerModel *serverModel = [MKConfigServerAdopter currentServerModelWithTable:self.tableView isApp:isApp];
    BOOL paramCheck = [MKConfigServerAdopter checkConfigServerParams:serverModel target:self];
    if (!paramCheck) {
        //存在参数错误
        return;
    }
    //保存参数到本地
    [MKConfigServerAdopter saveDataToLocal:serverModel target:self];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = (self.controllerType == MKConfigServerForApp ? @"MQTT settings for APP" : @"MQTT settings for device");
    [self.rightButton setTitle:@"Clear" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
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
        _tableView.backgroundColor = COLOR_WHITE_MACROS;
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
    
    UIButton *saveButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Save"
                                                                    target:self
                                                                    action:@selector(saveButtonPressed)];
    [tableFooter addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-75.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

- (MKConfigServerModel *)serverModel{
    if (!_serverModel) {
        _serverModel = [[MKConfigServerModel alloc] init];
    }
    return _serverModel;
}

@end
