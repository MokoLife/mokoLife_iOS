//
//  MKElectricityCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKElectricityCell.h"
#import "MKElectricityModel.h"

static CGFloat const iconWidth = 25.f;
static CGFloat const iconHeight = 25.f;

static NSString *const MKElectricityCellIdenty = @"MKElectricityCellIdenty";

@interface MKElectricityCell()

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *valueLabel;

@end

@implementation MKElectricityCell

+ (MKElectricityCell *)initCellWithTableView:(UITableView *)tableView{
    MKElectricityCell *cell = [tableView dequeueReusableCellWithIdentifier:MKElectricityCellIdenty];
    if (!cell) {
        cell = [[MKElectricityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKElectricityCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.valueLabel];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(iconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(iconHeight);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(120.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKElectricityModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.iconName)) {
        self.icon.image = LOADIMAGE(_dataModel.iconName, @"png");
    }
    if (ValidStr(_dataModel.textMsg)) {
        self.msgLabel.text = _dataModel.textMsg;
    }
    if (ValidStr(_dataModel.value)) {
        self.valueLabel.text = _dataModel.value;
    }
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
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UILabel *)valueLabel{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.textColor = UIColorFromRGB(0x808080);
        _valueLabel.font = MKFont(15.f);
    }
    return _valueLabel;
}

@end
