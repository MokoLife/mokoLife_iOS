//
//  MKConfigDeviceController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigDeviceController.h"
#import "MKConfigDeviceButtonView.h"
#import "MKConfigDeviceButtonModel.h"
#import "MKDeviceInfoController.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 50.f;
static CGFloat const buttonViewHeight = 50.f;

@interface MKConfigDeviceController ()<MKDeviceModelDelegate>

@property (nonatomic, strong)UIImageView *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)MKConfigDeviceButtonView *scheduleButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *timerButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *statisticsButton;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKDeviceModel *deviceModel;

@property (nonatomic, assign)BOOL plugIsOn;

@end

@implementation MKConfigDeviceController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKConfigDeviceController销毁");
    [self.deviceModel cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadDataList];
    [self configView];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveDeviceTopicData:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Moko Life";
}

- (void)rightButtonMethod{
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] initWithNavigationType:GYNaviTypeShow];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MKDeviceModelDelegate
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel{
    
}

#pragma mark - 通知处理
- (void)receiveDeviceTopicData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    [self.deviceModel resetTimerCounter];
    BOOL status = ([deviceDic[@"switch_state"] isEqualToString:@"on"]);
    if (self.plugIsOn == status) {
        return;
    }
    self.plugIsOn = status;
    [self configView];
}

#pragma mark - event method
- (void)switchButtonPressed{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        return;
    }
    self.plugIsOn = !self.plugIsOn;
    [self configView];
}

- (void)scheduleButtonPressed{
    
}

- (void)timerButtonPressed{
    
}

- (void)statisticsButtonPressed{
    
}

#pragma mark - public method
- (void)setDataModel:(MKDeviceModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    [self.deviceModel updatePropertyWithModel:_dataModel];
    [self.deviceModel startConnectTimer];
    self.plugIsOn = (self.deviceModel.device_state == smartPlugDeviceOn);
}

#pragma mark - config view
- (void)loadSubViews{
    [self.customNaviView.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.scheduleButton];
    [self.bottomView addSubview:self.timerButton];
    [self.bottomView addSubview:self.statisticsButton];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(switchButtonWidth);
        make.top.mas_equalTo(112.f);
        make.height.mas_equalTo(switchButtonHeight);
    }];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.right.mas_equalTo(-20.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(45.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0.f);
        make.bottom.mas_equalTo(-45.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.scheduleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
    [self.statisticsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
}

- (void)configView{
    [self.customNaviView setBackgroundColor:(self.plugIsOn ? NAVIGATION_BAR_COLOR : UIColorFromRGB(0x303a4b))];
    [self.view setBackgroundColor:(self.plugIsOn ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    NSString *switchIcon = (self.plugIsOn ? @"configPlugPage_switchButtonOn" : @"configPlugPage_switchButtonOff");
    self.switchButton.image = LOADIMAGE(switchIcon, @"png");
    self.stateLabel.textColor = (self.plugIsOn ? NAVIGATION_BAR_COLOR : UIColorFromRGB(0x808080));
    self.stateLabel.text = (self.plugIsOn ? @"Socket is on" : @"Socket is off");
    MKConfigDeviceButtonModel *scheduleModel = self.dataList[0];
    scheduleModel.iconName = (self.plugIsOn ? @"configPlugPage_scheduleOn" : @"configPlugPage_scheduleOff");
    scheduleModel.isOn = self.plugIsOn;
    self.scheduleButton.dataModel = scheduleModel;
    
    MKConfigDeviceButtonModel *timerModel = self.dataList[1];
    timerModel.iconName = (self.plugIsOn ? @"configPlugPage_TimerOn" : @"configPlugPage_TimerOff");
    timerModel.isOn = self.plugIsOn;
    self.timerButton.dataModel = timerModel;
    
    MKConfigDeviceButtonModel *statisticsModel = self.dataList[2];
    statisticsModel.iconName = (self.plugIsOn ? @"configPlugPage_statisticsOn" : @"configPlugPage_statisticsOff");
    statisticsModel.isOn = self.plugIsOn;
    self.statisticsButton.dataModel = statisticsModel;
}

- (void)loadDataList{
    MKConfigDeviceButtonModel *scheduleModel = [[MKConfigDeviceButtonModel alloc] init];
    scheduleModel.msg = @"Schedule";
    MKConfigDeviceButtonModel *timerModel = [[MKConfigDeviceButtonModel alloc] init];
    timerModel.msg = @"Timer";
    MKConfigDeviceButtonModel *statisticsModel = [[MKConfigDeviceButtonModel alloc] init];
    statisticsModel.msg = @"Statistics";
    
    [self.dataList addObject:scheduleModel];
    [self.dataList addObject:timerModel];
    [self.dataList addObject:statisticsModel];
}

#pragma mark - setter & getter
- (UIImageView *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UIImageView alloc] init];
        [_switchButton addTapAction:self selector:@selector(switchButtonPressed)];
    }
    return _switchButton;
}

- (UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = NAVIGATION_BAR_COLOR;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = MKFont(15.f);
        _stateLabel.text = @"Socket is on";
    }
    return _stateLabel;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = COLOR_CLEAR_MACROS;
    }
    return _bottomView;
}

- (MKConfigDeviceButtonView *)scheduleButton{
    if (!_scheduleButton) {
        _scheduleButton = [[MKConfigDeviceButtonView alloc] init];
        [_scheduleButton addTapAction:self selector:@selector(scheduleButtonPressed)];
    }
    return _scheduleButton;
}

- (MKConfigDeviceButtonView *)timerButton{
    if (!_timerButton) {
        _timerButton = [[MKConfigDeviceButtonView alloc] init];
        [_timerButton addTapAction:self selector:@selector(timerButtonPressed)];
    }
    return _timerButton;
}

- (MKConfigDeviceButtonView *)statisticsButton{
    if (!_statisticsButton) {
        _statisticsButton = [[MKConfigDeviceButtonView alloc] init];
        [_statisticsButton addTapAction:self selector:@selector(statisticsButtonPressed)];
    }
    return _statisticsButton;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataList;
}

- (MKDeviceModel *)deviceModel{
    if (!_deviceModel) {
        _deviceModel = [[MKDeviceModel alloc] init];
        _deviceModel.delegate = self;
    }
    return _deviceModel;
}

@end
