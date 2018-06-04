//
//  MKNotBlinkAmberCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkAmberCell.h"

@interface MKNotBlinkAmberCell()

@property (nonatomic, strong)UILabel *stepLabel;

@property (nonatomic, strong)UILabel *operationLabel;

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKNotBlinkAmberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.stepLabel];
        [self.contentView addSubview:self.operationLabel];
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - setter & getter
- (UILabel *)stepLabel{
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] init];
        _stepLabel.textColor = NAVIGATION_BAR_COLOR;
        _stepLabel.textAlignment = NSTextAlignmentCenter;
        _stepLabel.font = MKFont(18.f);
    }
    return _stepLabel;
}

- (UILabel *)operationLabel{
    if (!_operationLabel) {
        _operationLabel = [[UILabel alloc] init];
        _operationLabel.textColor = UIColorFromRGB(0x808080);
        _operationLabel.textAlignment = NSTextAlignmentCenter;
        _operationLabel.font = MKFont(12.f);
    }
    return _operationLabel;
}

@end
