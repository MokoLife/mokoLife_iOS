//
//  MKAddDeviceController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/1.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceController.h"
#import "MKSettingsController.h"

static CGFloat const offset_X = 15.f;
static CGFloat const centerIconWidth = 268.f;
static CGFloat const centerIconHeight = 268.f;

@interface MKAddDeviceController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *centerIcon;

@property (nonatomic, strong)UIButton *addButton;

@end

@implementation MKAddDeviceController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Moko Life";
}

- (void)leftButtonMethod{
    MKSettingsController *vc = [[MKSettingsController alloc] initWithNavigationType:GYNaviTypeShow];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod{
    
}

#pragma mark - event method
- (void)addButtonPressed{
    
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.leftButton setImage:LOADIMAGE(@"addDevice_menuIcon", @"png") forState:UIControlStateNormal];
    [self.rightButton setImage:LOADIMAGE(@"addDevice_addIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.msgLabel];
    [self.view addSubview:self.centerIcon];
    [self.view addSubview:self.addButton];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(52.f);
        make.height.mas_equalTo(HCKFont(18.f).lineHeight);
    }];
    [self.centerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(centerIconWidth);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(centerIconHeight);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.right.mas_equalTo(-58.f);
        make.bottom.mas_equalTo(-70.f);
        make.height.mas_equalTo(50.f);
    }];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = UIColorFromRGB(0x0188cc);
        _msgLabel.font = HCKFont(18.f);
        _msgLabel.text = @"Start your moko life";
    }
    return _msgLabel;
}

- (UIImageView *)centerIcon{
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
        _centerIcon.image = LOADIMAGE(@"addDevice_centerIcon", @"png");
    }
    return _centerIcon;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setBackgroundColor:NAVIGATION_BAR_COLOR];
        [_addButton.titleLabel setFont:HCKFont(18.f)];
        [_addButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_addButton setTitle:@"Add Devices" forState:UIControlStateNormal];
        [_addButton.layer setMasksToBounds:YES];
        [_addButton.layer setCornerRadius:5.f];
        [_addButton addTapAction:self selector:@selector(addButtonPressed)];
    }
    return _addButton;
}

@end
