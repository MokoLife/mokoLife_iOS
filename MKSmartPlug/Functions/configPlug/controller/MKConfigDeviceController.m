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
#import "MKConfigDeviceTimePickerView.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 50.f;
static CGFloat const buttonViewHeight = 50.f;

@interface MKConfigDeviceController ()<MKDeviceModelDelegate>

@property (nonatomic, strong)UIImageView *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UILabel *delayTimeLabel;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)MKConfigDeviceButtonView *scheduleButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *timerButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *statisticsButton;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKDeviceModel *deviceModel;

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
    [self addNotifications];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Moko Life";
}

- (void)rightButtonMethod{
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] initWithNavigationType:GYNaviTypeShow];
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:self.deviceModel];
    vc.deviceModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MKDeviceModelDelegate
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel{
    self.deviceModel.device_state = smartPlugDeviceOffline;
    [self configView];
}

#pragma mark - 通知处理
- (void)switchStateNotification:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    [self.deviceModel resetTimerCounter];
    BOOL status = ([deviceDic[@"switch_state"] isEqualToString:@"on"]);
    self.deviceModel.device_state = (status ? smartPlugDeviceOn : smartPlugDeviceStatusOff);
    [self configView];
}

- (void)delayTimeNotification:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    [self.deviceModel resetTimerCounter];
    NSString *timeMsg = [NSString stringWithFormat:@"%@:%@:%@",
                         deviceDic[@"delay_hour"],
                         deviceDic[@"delay_minute"],
                         deviceDic[@"delay_second"]];
    //倒计时结束0:0:0
    [self.delayTimeLabel setHidden:[timeMsg isEqualToString:@"0:0:0"]];
    NSString *stateMsg = [NSString stringWithFormat:@"%@ after %@", deviceDic[@"switch_state"], timeMsg];
    self.delayTimeLabel.text = stateMsg;
    self.delayTimeLabel.textColor = (self.deviceModel.device_state == smartPlugDeviceOn) ? NAVIGATION_BAR_COLOR : UIColorFromRGB(0x808080);
}

#pragma mark - event method
- (void)switchButtonPressed{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return;
    }
    BOOL isOn = (self.deviceModel.device_state == smartPlugDeviceOn);
    [MKMQTTServerInterface setSwitchState:!isOn deviceModel:self.deviceModel target:self];
}

- (void)scheduleButtonPressed{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return;
    }
    [self.view showCentralToast:@"The timing function needs to be improved."];
}

- (void)timerButtonPressed{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return;
    }
    BOOL isOn = (self.deviceModel.device_state == smartPlugDeviceOn);
    MKConfigDeviceTimeModel *timeModel = [[MKConfigDeviceTimeModel alloc] init];
    timeModel.hour = @"0";
    timeModel.minutes = @"0";
    timeModel.titleMsg = (isOn ? @"Countdown timer(off)" : @"Countdown timer(on)");
    MKConfigDeviceTimePickerView *pickView = [[MKConfigDeviceTimePickerView alloc] init];
    pickView.timeModel = timeModel;
    WS(weakSelf);
    [pickView showTimePickViewBlock:^(MKConfigDeviceTimeModel *timeModel) {
        [weakSelf setDelay:timeModel.hour delayMin:timeModel.minutes];
    }];
}

- (void)statisticsButtonPressed{
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return;
    }
}

#pragma mark - public method
- (void)setDataModel:(MKDeviceModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    [self.deviceModel updatePropertyWithModel:_dataModel];
    [self.deviceModel startStateMonitoringTimer];
}

#pragma mark - setting
- (void)setDelay:(NSString *)hour delayMin:(NSString *)min{
    [MKMQTTServerInterface setDelayHour:hour minutes:min deviceModel:self.deviceModel target:self];
}

#pragma mark - private method
- (void)addNotifications{
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(switchStateNotification:)
                                       name:MKMQTTServerReceivedSwitchStateNotification
                                     object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(delayTimeNotification:)
                                       name:MKMQTTServerReceivedDelayTimeNotification
                                     object:nil];
}

#pragma mark - config view
- (void)loadSubViews{
    [self.customNaviView.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.delayTimeLabel];
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
    [self.delayTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.right.mas_equalTo(-20.f);
        make.top.mas_equalTo(self.stateLabel.mas_bottom).mas_offset(20.f);
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
    [self.customNaviView setBackgroundColor:((self.deviceModel.device_state == smartPlugDeviceOn) ? NAVIGATION_BAR_COLOR : UIColorFromRGB(0x303a4b))];
    [self.view setBackgroundColor:((self.deviceModel.device_state == smartPlugDeviceOn) ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    NSString *switchIcon = ((self.deviceModel.device_state == smartPlugDeviceOn) ? @"configPlugPage_switchButtonOn" : @"configPlugPage_switchButtonOff");
    self.switchButton.image = LOADIMAGE(switchIcon, @"png");
    self.stateLabel.textColor = ((self.deviceModel.device_state == smartPlugDeviceOn) ? NAVIGATION_BAR_COLOR : UIColorFromRGB(0x808080));
    NSString *textMsg = @"Socket is off";
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        textMsg = @"Socket is offline";
    }else if (self.deviceModel.device_state == smartPlugDeviceOn){
        textMsg = @"Socket is on";
    }
    self.stateLabel.text = textMsg;
    
    if (self.deviceModel.device_state == smartPlugDeviceOffline) {
        [self.delayTimeLabel setHidden:YES];
    }
    
    MKConfigDeviceButtonModel *scheduleModel = self.dataList[0];
    scheduleModel.iconName = ((self.deviceModel.device_state == smartPlugDeviceOn) ? @"configPlugPage_scheduleOn" : @"configPlugPage_scheduleOff");
    scheduleModel.isOn = (self.deviceModel.device_state == smartPlugDeviceOn);
    self.scheduleButton.dataModel = scheduleModel;
    
    MKConfigDeviceButtonModel *timerModel = self.dataList[1];
    timerModel.iconName = ((self.deviceModel.device_state == smartPlugDeviceOn) ? @"configPlugPage_TimerOn" : @"configPlugPage_TimerOff");
    timerModel.isOn = (self.deviceModel.device_state == smartPlugDeviceOn);
    self.timerButton.dataModel = timerModel;
    
    MKConfigDeviceButtonModel *statisticsModel = self.dataList[2];
    statisticsModel.iconName = ((self.deviceModel.device_state == smartPlugDeviceOn) ? @"configPlugPage_statisticsOn" : @"configPlugPage_statisticsOff");
    statisticsModel.isOn = (self.deviceModel.device_state == smartPlugDeviceOn);
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

- (UILabel *)delayTimeLabel{
    if (!_delayTimeLabel) {
        _delayTimeLabel = [[UILabel alloc] init];
        _delayTimeLabel.textColor = NAVIGATION_BAR_COLOR;
        _delayTimeLabel.textAlignment = NSTextAlignmentCenter;
        _delayTimeLabel.font = MKFont(15.f);
    }
    return _delayTimeLabel;
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
