//
//  MKSaveDeviceNameController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSaveDeviceNameController.h"
#import "MKTextField.h"
#import "MKDeviceDataBaseManager.h"

@interface MKSaveDeviceNameController ()<UITextFieldDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UIButton *doneButton;

@end

@implementation MKSaveDeviceNameController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKSaveDeviceNameController销毁");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.textField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    NSString *mac = [[self.deviceModel.device_mac stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
    mac = [mac substringWithRange:NSMakeRange(8, 4)];
    NSString *text = @"MK102-";
    if ([self.deviceModel.device_type isEqualToString:@"1"]) {
        //带计电量
        text = @"MK112-";
    }
    text = [text stringByAppendingString:mac];
    self.textField.text = text;
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Add Device";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - event method
- (void)doneButtonPressed{
    self.deviceModel.local_name = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    WS(weakSelf);
    [MKDeviceDataBaseManager updateDevice:self.deviceModel sucBlock:^{
        for (MKBaseViewController *vc in weakSelf.navigationController.viewControllers) {
            if ([vc isKindOfClass:NSClassFromString(@"MKSelectDeviceTypeController")]) {
                [vc leftButtonMethod];
                break ;
            }
        }
    } failedBlock:^(NSError *error) {
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.leftButton setHidden:YES];
    [self.view addSubview:self.msgLabel];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.doneButton];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(52.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(37.f);
        make.right.mas_equalTo(-37.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(52.f);
        make.height.mas_equalTo(45.f);
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(45.f);
        make.right.mas_equalTo(-45.f);
        make.bottom.mas_equalTo(-75.f);
        make.height.mas_equalTo(50.f);
    }];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = NAVIGATION_BAR_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(18.f);
        _msgLabel.text = @"Connection successful";
    }
    return _msgLabel;
}

- (MKTextField *)textField{
    if (!_textField) {
        _textField = [MKCommonlyUIHelper configServerTextField];
        _textField.delegate = self;
    }
    return _textField;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Done" target:self action:@selector(doneButtonPressed)];
    }
    return _doneButton;
}

@end
