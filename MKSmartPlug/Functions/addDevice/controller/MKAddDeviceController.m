//
//  MKAddDeviceController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "MKNotBlinkAmberController.h"
#import "MKAddDeviceAdopter.h"
#import "MKAddDeviceDataManager.h"

static CGFloat const offset_X = 20.f;
static CGFloat const centerGifWidth = 144.f;
static CGFloat const centerGifHeight = 253.f;

@interface MKAddDeviceController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)FLAnimatedImageView *gifIcon;

@property (nonatomic, strong)UILabel *linkLabel;

@property (nonatomic, strong)UIButton *blinkButton;

@property (nonatomic, strong)UILabel *instructionsLabel;

@property (nonatomic, strong)MKAddDeviceDataManager *dataManager;

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
    return @"Add Device";
}

#pragma mark - event method
- (void)linkLabelPressed{
    MKNotBlinkAmberController *vc = [[MKNotBlinkAmberController alloc] initWithNavigationType:GYNaviTypeShow];
    WS(weakSelf);
    vc.blinkButtonPressedBlock = ^{
        //点击了按钮之后需要等vc退出栈之后退出新的页面
        [weakSelf performSelector:@selector(blinkButtonPressed) withObject:nil afterDelay:0.3f];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)blinkButtonPressed{
    [self.dataManager startConfigProcessWithCompleteBlock:^(NSError *error, BOOL success) {

    }];
}

#pragma mark - loadSubViews
- (void)loadSubViews{
    [self.view addSubview:self.msgLabel];
    [self.view addSubview:self.gifIcon];
    [self.view addSubview:self.linkLabel];
    [self.view addSubview:self.blinkButton];
    [self.view addSubview:self.instructionsLabel];
    
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(kScreenWidth - 2 * offset_X, MAXFLOAT)];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(24.f);
        make.height.mas_equalTo(msgSize.height);
    }];
    [self.gifIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(centerGifWidth);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(64.f);
        make.height.mas_equalTo(centerGifHeight);
    }];
    CGSize linkSize = [NSString sizeWithText:self.linkLabel.text
                                     andFont:self.linkLabel.font
                                  andMaxSize:CGSizeMake(MAXFLOAT,
                                                        (iPhone6Plus ? MKFont(17).lineHeight : MKFont(16).lineHeight))];
    [self.linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(linkSize.width);
        make.top.mas_equalTo(self.gifIcon.mas_bottom).mas_offset(64.f);
        make.height.mas_equalTo((iPhone6Plus ? MKFont(17).lineHeight : MKFont(16).lineHeight));
    }];
    [self.blinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.linkLabel.mas_bottom).mas_offset(25.f);
        make.height.mas_equalTo(45.f);
    }];
    [self.instructionsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.blinkButton.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(MKFont(10.f).lineHeight);
    }];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = UIColorFromRGB(0x808080);
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Plug in the device and confirm that indicator is blinking amber";
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (FLAnimatedImageView *)gifIcon{
    if (!_gifIcon) {
        _gifIcon = [[FLAnimatedImageView alloc] init];
        NSString *imageName = [@"addDevice_centerGif" stringByAppendingString:(iPhone6Plus ? @"@3x" : @"@2x")];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"gif"];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        _gifIcon.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
    }
    return _gifIcon;
}

- (UILabel *)linkLabel{
    if (!_linkLabel) {
        _linkLabel = [MKCommonlyUIHelper clickEnableLabelWithText:@"My light is not blinking amber"
                                                        textColor:NAVIGATION_BAR_COLOR
                                                           target:self
                                                           action:@selector(linkLabelPressed)];
    }
    return _linkLabel;
}

- (UIButton *)blinkButton{
    if (!_blinkButton) {
        _blinkButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Indicator blink amber light"
                                                                target:self
                                                                action:@selector(blinkButtonPressed)];
    }
    return _blinkButton;
}

- (UILabel *)instructionsLabel{
    if (!_instructionsLabel) {
        _instructionsLabel = [[UILabel alloc] init];
        _instructionsLabel.textAlignment = NSTextAlignmentCenter;
        _instructionsLabel.textColor = UIColorFromRGB(0x808080);
        _instructionsLabel.font = MKFont(10.f);
        _instructionsLabel.numberOfLines = 0;
        _instructionsLabel.text = @"This app supports only 2.4GHz Wi-Fi network";
    }
    return _instructionsLabel;
}

- (MKAddDeviceDataManager *)dataManager{
    if (!_dataManager) {
        _dataManager = [MKAddDeviceDataManager addDeviceManager];
    }
    return _dataManager;
}

@end
