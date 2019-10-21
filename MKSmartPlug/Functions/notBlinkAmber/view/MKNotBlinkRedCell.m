//
//  MKNotBlinkRedCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkRedCell.h"
#import "MKNotBlinkRedModel.h"

static CGFloat const offset_X = 20.f;

static NSString *const MKNotBlinkRedCellIdenty = @"MKNotBlinkRedCellIdenty";

@interface MKNotBlinkRedCell()

@property (nonatomic, strong)UILabel *stepLabel;

@property (nonatomic, strong)UILabel *operationLabel;

@property (nonatomic, strong)UIImageView *centerIcon;

@property (nonatomic, strong)UIView *lineView;

@end

@implementation MKNotBlinkRedCell

+ (MKNotBlinkRedCell *)initCellWithTableView:(UITableView *)tableView{
    MKNotBlinkRedCell *cell = [tableView dequeueReusableCellWithIdentifier:MKNotBlinkRedCellIdenty];
    if (!cell) {
        cell = [[MKNotBlinkRedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKNotBlinkRedCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.stepLabel];
        [self.contentView addSubview:self.operationLabel];
        [self.contentView addSubview:self.centerIcon];
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
    CGFloat iconWidth = 113.f;
    CGFloat iconHeight = 113.f;
    if (!ValidStr(self.dataModel.iconName)) {
        //如果是没有中间图片的
        iconWidth = 0.f;
        iconHeight = 0.f;
    }
    [self.centerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(iconWidth);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.mas_equalTo(self.operationLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(iconHeight);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKNotBlinkRedModel *)dataModel{
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
    if (ValidStr(_dataModel.iconName)) {
        self.centerIcon.image = LOADIMAGE(_dataModel.iconName, @"png");
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

- (UIImageView *)centerIcon{
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
    }
    return _centerIcon;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGB(0xd9d9d9);
    }
    return _lineView;
}

@end
