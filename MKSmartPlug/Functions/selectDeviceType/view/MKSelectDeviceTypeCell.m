//
//  MKSelectDeviceTypeCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSelectDeviceTypeCell.h"
#import "MKSelectDeviceTypeModel.h"

static CGFloat const leftIconWidth = 33.f;
static CGFloat const leftIconHeight = 33.f;
static CGFloat const rightIconWidth = 8.f;
static CGFloat const rightIconHeight = 15.f;

static NSString *const MKSelectDeviceTypeCellIdenty = @"MKSelectDeviceTypeCellIdenty";

@interface MKSelectDeviceTypeCell()

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKSelectDeviceTypeCell

+ (MKSelectDeviceTypeCell *)initCellWithTable:(UITableView *)tableView{
    MKSelectDeviceTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:MKSelectDeviceTypeCellIdenty];
    if (!cell) {
        cell = [[MKSelectDeviceTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKSelectDeviceTypeCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightIcon];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(leftIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(leftIconHeight);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(rightIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(rightIconHeight);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKSelectDeviceTypeModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.msg)) {
        self.msgLabel.text = _dataModel.msg;
    }
    if (ValidStr(_dataModel.leftIconName)) {
        self.leftIcon.image = LOADIMAGE(_dataModel.leftIconName, @"png");
    }
}

#pragma mark - setter & getter
- (UIImageView *)leftIcon{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    return _leftIcon;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = UIColorFromRGB(0x0188cc);
        _msgLabel.font = MKFont(15.f);
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

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView;
}

@end
