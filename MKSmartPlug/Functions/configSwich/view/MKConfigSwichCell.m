//
//  MKConfigSwichCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigSwichCell.h"
#import "MKConfigSwichModel.h"

static NSString *const MKConfigSwichCellIdenty = @"MKConfigSwichCellIdenty";

#define swichOnColor UIColorFromRGB(0x0188cc)

@interface MKConfigSwichCell()

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UILabel *countdownLabel;

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UIButton *modifyNameButton;

@property (nonatomic, strong)UIButton *timerButton;

@property (nonatomic, strong)UIButton *scheduleButton;

@end

@implementation MKConfigSwichCell

+ (MKConfigSwichCell *)initCellWithTable:(UITableView *)tableView{
    MKConfigSwichCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigSwichCellIdenty];
    if (!cell) {
        cell = [[MKConfigSwichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigSwichCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.countdownLabel];
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.modifyNameButton];
        [self.contentView addSubview:self.timerButton];
        [self.contentView addSubview:self.scheduleButton];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(95.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(95.f);
    }];
    [self.countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchButton.mas_right).mas_offset(15.f);
        make.width.mas_equalTo(120.f);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    [self.modifyNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.countdownLabel.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.modifyNameButton.mas_left).mas_offset(-5.f);
        make.left.mas_equalTo(self.countdownLabel.mas_right).mas_offset(5.f);
        make.centerY.mas_equalTo(self.modifyNameButton.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.scheduleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.bottom.mas_equalTo(-20.f);
        make.height.mas_equalTo(40.f);
    }];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.scheduleButton.mas_left).mas_offset(-20.f);
        make.width.mas_equalTo(60.f);
        make.bottom.mas_equalTo(-20.f);
        make.height.mas_equalTo(40.f);
    }];
}

#pragma mark - event method
- (void)switchButtonPressed{
    if ([self.delegate respondsToSelector:@selector(changedSwichState:index:)]) {
        [self.delegate changedSwichState:!self.switchButton.isSelected index:self.dataModel.index];
    }
}

- (void)modifyNameButtonPressed{
    if ([self.delegate respondsToSelector:@selector(modifySwichWayNameWithIndex:)]) {
        [self.delegate modifySwichWayNameWithIndex:self.dataModel.index];
    }
}

- (void)timerButtonPressed{
    if ([self.delegate respondsToSelector:@selector(swichStartCountdownWithIndex:)]) {
        [self.delegate swichStartCountdownWithIndex:self.dataModel.index];
    }
}

- (void)scheduleButtonPressed{
    if ([self.delegate respondsToSelector:@selector(scheduleSwichWayWithIndex:)]) {
        [self.delegate scheduleSwichWayWithIndex:self.dataModel.index];
    }
}

#pragma mark - public method
- (void)setDataModel:(MKConfigSwichModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    NSString *stateIconName = (_dataModel.isOn ? @"swich_state_on" : @"swich_state_off");
    self.switchButton.selected = _dataModel.isOn;
    [self.switchButton setImage:LOADIMAGE(stateIconName, @"png") forState:UIControlStateNormal];
    if (ValidStr(_dataModel.countdown) && ![_dataModel.countdown isEqualToString:@"0:0:0"]) {
        NSString *stateString = (_dataModel.isOn ? @"off after:" : @"on after:");
        self.countdownLabel.text = [stateString stringByAppendingString:_dataModel.countdown];
    }else{
        self.countdownLabel.text = @"";
    }
    if (ValidStr(_dataModel.currentWaySwitchName)) {
        self.deviceNameLabel.text = _dataModel.currentWaySwitchName;
    }else{
        self.deviceNameLabel.text = @"swich 1";
    }
}

#pragma mark - setter & getter
- (UIButton *)switchButton{
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:LOADIMAGE(@"swich_state_off", @"png") forState:UIControlStateNormal];
        [_switchButton addTapAction:self selector:@selector(switchButtonPressed)];
    }
    return _switchButton;
}

- (UILabel *)countdownLabel{
    if (!_countdownLabel) {
        _countdownLabel = [[UILabel alloc] init];
        _countdownLabel.textAlignment = NSTextAlignmentLeft;
        _countdownLabel.textColor = swichOnColor;
        _countdownLabel.font = MKFont(12.f);
    }
    return _countdownLabel;
}

- (UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textAlignment = NSTextAlignmentRight;
        _deviceNameLabel.textColor = swichOnColor;
        _deviceNameLabel.font = MKFont(13.f);
    }
    return _deviceNameLabel;
}

- (UIButton *)modifyNameButton{
    if (!_modifyNameButton) {
        _modifyNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modifyNameButton setImage:LOADIMAGE(@"swich_modifyDeviceNameIcon", @"png") forState:UIControlStateNormal];
        [_modifyNameButton addTapAction:self selector:@selector(modifyNameButtonPressed)];
    }
    return _modifyNameButton;
}

- (UIButton *)timerButton{
    if (!_timerButton) {
        _timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timerButton setTitle:@"Timer" forState:UIControlStateNormal];
        [_timerButton setTitleColor:swichOnColor forState:UIControlStateNormal];
        [_timerButton.titleLabel setFont:MKFont(13.f)];
        [_timerButton addTapAction:self selector:@selector(timerButtonPressed)];
        
        [_timerButton.layer setMasksToBounds:YES];
        [_timerButton.layer setBorderColor:swichOnColor.CGColor];
        [_timerButton.layer setBorderWidth:0.5f];
        [_timerButton.layer setCornerRadius:5.f];
    }
    return _timerButton;
}

- (UIButton *)scheduleButton{
    if (!_scheduleButton) {
        _scheduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scheduleButton setTitle:@"Schedule" forState:UIControlStateNormal];
        [_scheduleButton setTitleColor:swichOnColor forState:UIControlStateNormal];
        [_scheduleButton.titleLabel setFont:MKFont(13.f)];
        [_scheduleButton addTapAction:self selector:@selector(scheduleButtonPressed)];
        
        [_scheduleButton.layer setMasksToBounds:YES];
        [_scheduleButton.layer setBorderColor:swichOnColor.CGColor];
        [_scheduleButton.layer setBorderWidth:0.5f];
        [_scheduleButton.layer setCornerRadius:5.f];
    }
    return _scheduleButton;
}

@end

