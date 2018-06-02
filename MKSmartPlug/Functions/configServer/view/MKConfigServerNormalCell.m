//
//  MKConfigServerNormalCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerNormalCell.h"
#import "MKConfigServerAdopter.h"

static CGFloat const msgLabelWidth = 90.f;
static CGFloat const textFieldHeight = 45.f;

static NSString *const MKConfigServerNormalCellIdenty = @"MKConfigServerNormalCellIdenty";

@interface MKConfigServerNormalCell()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKConfigServerNormalCell

+ (MKConfigServerNormalCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerNormalCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerNormalCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(6.f);
        make.right.mas_equalTo(-21.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(textFieldHeight);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MKConfigServerCellProtocol
/**
 获取当前cell显示的数值
 
 @return @{
 @"row":@(row),
 @"xx":@"xx"
 @"xx":@"xx"
 }
 */
- (NSDictionary *)configServerCellValue{
    NSString *paramValue = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    return @{
             @"row":@(self.indexPath.row),
             @"paramValue":paramValue
             };
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    self.textField.text = @"";
}

/**
 隐藏键盘
 */
- (void)resignFirstResponder{
    [self.textField resignFirstResponder];
}

#pragma mark - public method
- (void)setMsg:(NSString *)msg{
    _msg = nil;
    _msg = msg;
    self.msgLabel.text = (!ValidStr(_msg) ? @"" : _msg);
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
    }
    return _msgLabel;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [MKConfigServerAdopter configServerTextField];
        _textField.delegate = self;
    }
    return _textField;
}

@end
