//
//  MKAddDeviceView.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceView.h"

static CGFloat const offset_X = 15.f;
static CGFloat const centerIconWidth = 268.f;
static CGFloat const centerIconHeight = 268.f;
@interface MKAddDeviceView()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *centerIcon;

@property (nonatomic, strong)UIButton *addButton;

@end

@implementation MKAddDeviceView
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.centerIcon];
        [self addSubview:self.addButton];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(52.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.centerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(centerIconWidth);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(centerIconHeight);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.right.mas_equalTo(-58.f);
        make.bottom.mas_equalTo(-70.f);
        make.height.mas_equalTo(50.f);
    }];
}

#pragma mark - event method
- (void)addButtonPressed{
    if (self.addDeviceBlock) {
        self.addDeviceBlock();
    }
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = UIColorFromRGB(0x0188cc);
        _msgLabel.font = MKFont(18.f);
        _msgLabel.text = @"Start your moko life";
    }
    return _msgLabel;
}

- (UIImageView *)centerIcon{
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
        _centerIcon.image = LOADIMAGE(@"mokoLife_centerIcon", @"png");
    }
    return _centerIcon;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Add Devices"
                                                              target:self
                                                              action:@selector(addButtonPressed)];
    }
    return _addButton;
}

@end
