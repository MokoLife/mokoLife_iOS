//
//  MKConfigServerConnectModeCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerConnectModeCell.h"
#import "MKConfigServerAdopter.h"

static CGFloat const iconWidth = 13.f;
static CGFloat const iconHeight = 13.f;
static CGFloat const labelWidth = 40.f;
static CGFloat const buttonViewWidth = 65.f;
static CGFloat const buttonViewHeight = 30.f;

static NSString *const MKConfigServerConnectModeCellIdenty = @"MKConfigServerConnectModeCellIdenty";

@interface MKConfigServerConnectModeCell()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIView *tcpView;

@property (nonatomic, strong)UIImageView *tcpIcon;

@property (nonatomic, strong)UIView *sslView;

@property (nonatomic, strong)UIImageView *sslIcon;

@property (nonatomic, assign)NSInteger modeNumber;

@end

@implementation MKConfigServerConnectModeCell

+ (MKConfigServerConnectModeCell *)initCellWithTableView:(UITableView *)tableView{
    MKConfigServerConnectModeCell *cell = [tableView dequeueReusableCellWithIdentifier:MKConfigServerConnectModeCellIdenty];
    if (!cell) {
        cell = [[MKConfigServerConnectModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKConfigServerConnectModeCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.tcpView];
        [self.contentView addSubview:self.sslView];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(125.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
    }];
    [self.tcpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(25.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.sslView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tcpView.mas_right).mas_offset(17.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(buttonViewHeight);
    }];
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
    return @{@"connectMode":@(self.modeNumber)};
}

/**
 将所有的信息设置为初始的值
 */
- (void)setToDefaultParameters{
    [self tcpViewPressed];
}

#pragma mark - event method
- (void)tcpViewPressed{
    self.modeNumber = 0;
    self.tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    self.sslIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
}

- (void)sslViewPressed{
    self.modeNumber = 1;
    self.tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    self.sslIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        _msgLabel.text = @"Connect Mode";
    }
    return _msgLabel;
}

- (UIImageView *)tcpIcon{
    if (!_tcpIcon) {
        _tcpIcon = [[UIImageView alloc] init];
        _tcpIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    }
    return _tcpIcon;
}

- (UIImageView *)sslIcon{
    if (!_sslIcon) {
        _sslIcon = [[UIImageView alloc] init];
        _sslIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    }
    return _sslIcon;
}

- (UIView *)tcpView{
    if (!_tcpView) {
        _tcpView = [[UIView alloc] init];
        [_tcpView addTapAction:self selector:@selector(tcpViewPressed)];
        
        [_tcpView addSubview:self.tcpIcon];
        
        [self.tcpIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_tcpView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *tcpLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        tcpLabel.text = @"TCP";
        [_tcpView addSubview:tcpLabel];
        [tcpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tcpIcon.mas_right).mas_offset(8.f);
            make.width.mas_equalTo(labelWidth);
            make.centerY.mas_equalTo(_tcpView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _tcpView;
}

- (UIView *)sslView{
    if (!_sslView) {
        _sslView = [[UIView alloc] init];
        [_sslView addTapAction:self selector:@selector(sslViewPressed)];
        
        [_sslView addSubview:self.sslIcon];
        
        [self.sslIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_sslView.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *sslLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        sslLabel.text = @"SSL";
        [_sslView addSubview:sslLabel];
        [sslLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.sslIcon.mas_right).mas_offset(8.f);
            make.width.mas_equalTo(labelWidth);
            make.centerY.mas_equalTo(_sslView.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _sslView;
}

@end
