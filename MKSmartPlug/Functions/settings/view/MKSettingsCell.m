//
//  MKSettingsCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSettingsCell.h"

static CGFloat const rightIconWidth = 8.f;
static CGFloat const rightIconHeight = 15.f;

static NSString *const MKSettingsCellIdenty = @"MKSettingsCellIdenty";

@interface MKSettingsCell()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKSettingsCell

+ (MKSettingsCell *)initCellWithTable:(UITableView *)tableView{
    MKSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:MKSettingsCellIdenty];
    if (!cell) {
        cell = [[MKSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKSettingsCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(HCKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(rightIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(rightIconHeight);
    }];
}

#pragma mark - public method
- (void)setMsg:(NSString *)msg{
    _msg = nil;
    _msg = msg;
    if (!ValidStr(_msg)) {
        return;
    }
    self.msgLabel.text = _msg;
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = HCKFont(15.f);
    }
    return _msgLabel;
}

- (UIImageView *)rightIcon{
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADIMAGE(@"MKSmartPlugRightNextIcon", @"png");
    }
    return _rightIcon;
}

@end
