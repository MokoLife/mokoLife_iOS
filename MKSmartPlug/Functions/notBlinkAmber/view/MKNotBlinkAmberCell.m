//
//  MKNotBlinkAmberCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkAmberCell.h"
#import "MKNotBlinkAmberModel.h"

static CGFloat const offset_X = 20.f;
static CGFloat const leftIconWidth = 108.f;
static CGFloat const leftIconHeight = 115.f;
static CGFloat const rightIconWidth = 108.f;
static CGFloat const rightIconHeight = 115.f;

static NSString *const MKNotBlinkAmberCellIdenty = @"MKNotBlinkAmberCellIdenty";

@interface MKNotBlinkAmberCell()

@property (nonatomic, strong)UILabel *stepLabel;

@property (nonatomic, strong)UILabel *operationLabel;

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UIImageView *rightIcon;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKNotBlinkAmberCell

+ (MKNotBlinkAmberCell *)initCellWithTableView:(UITableView *)tableView{
    MKNotBlinkAmberCell *cell = [tableView dequeueReusableCellWithIdentifier:MKNotBlinkAmberCellIdenty];
    if (!cell) {
        cell = [[MKNotBlinkAmberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKNotBlinkAmberCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.stepLabel];
        [self.contentView addSubview:self.operationLabel];
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.rightIcon];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize stepSize = [NSString sizeWithText:self.stepLabel.text
                                     andFont:self.stepLabel.font
                                  andMaxSize:CGSizeMake(kScreenWidth - 2 * offset_X, MAXFLOAT)];
    [self.stepLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(30);
        make.height.mas_equalTo(stepSize.height);
    }];
    
    CGSize operationSize = [NSString sizeWithText:self.operationLabel.text
                                          andFont:self.operationLabel.font
                                       andMaxSize:CGSizeMake(kScreenWidth - 2 * offset_X, MAXFLOAT)];
    [self.operationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.stepLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(operationSize.height);
    }];
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(leftIconWidth);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-25.f);
        make.top.mas_equalTo(self.operationLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(leftIconHeight);
    }];
    [self.rightIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(25.f);
        make.width.mas_equalTo(rightIconWidth);
        make.centerY.mas_equalTo(self.leftIcon.mas_centerY);
        make.height.mas_equalTo(rightIconHeight);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKNotBlinkAmberModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.stepMsg)) {
        self.stepLabel.text = _dataModel.stepMsg;
    }
    if (ValidStr(_dataModel.operationMsg)) {
        self.operationLabel.text = _dataModel.operationMsg;
    }
    if (ValidStr(_dataModel.leftIconName)) {
        self.leftIcon.image = LOADIMAGE(_dataModel.leftIconName, @"png");
    }
    if (ValidStr(_dataModel.rightIconName)) {
        self.rightIcon.image = LOADIMAGE(_dataModel.rightIconName, @"png");
    }
    [self setNeedsLayout];
}

#pragma mark - setter & getter
- (UILabel *)stepLabel{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        _stepLabel.textColor = UIColorFromRGB(0x0188cc);
        _stepLabel.textAlignment = NSTextAlignmentCenter;
        _stepLabel.font = MKFont(18.f);
        _stepLabel.numberOfLines = 0;
    }
    return _stepLabel;
}

- (UILabel *)operationLabel{
    if (!_operationLabel) {
        _operationLabel = [[UILabel alloc] init];
        _operationLabel.textColor = UIColorFromRGB(0x808080);
        _operationLabel.textAlignment = NSTextAlignmentCenter;
        _operationLabel.font = MKFont(12.f);
        _operationLabel.numberOfLines = 0;
    }
    return _operationLabel;
}

- (UIImageView *)leftIcon{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    return _leftIcon;
}

- (UIImageView *)rightIcon{
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
    }
    return _rightIcon;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xd9d9d9);
    }
    return _lineView;
}

@end
