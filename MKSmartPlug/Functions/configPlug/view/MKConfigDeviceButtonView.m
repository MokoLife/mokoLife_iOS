//
//  MKConfigDeviceButtonView.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigDeviceButtonView.h"
#import "MKConfigDeviceButtonModel.h"

static CGFloat const iconWidth = 25.f;
static CGFloat const iconHeight = 28.f;

@interface MKConfigDeviceButtonView()

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKConfigDeviceButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.msgLabel];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(iconWidth);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(iconHeight);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(self.mas_width);
        make.bottom.mas_equalTo(-5.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKConfigDeviceButtonModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.iconName)) {
        self.icon.image = LOADIMAGE(_dataModel.iconName, @"png");
    }
    if (ValidStr(_dataModel.msg)) {
        self.msgLabel.text = _dataModel.msg;
    }
    self.msgLabel.textColor = (_dataModel.isOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
}

#pragma mark - setter & getter
- (UIImageView *)icon{
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = UIColorFromRGB(0x0188cc);
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(10.f);
    }
    return _msgLabel;
}
@end
