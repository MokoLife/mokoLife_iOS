//
//  MKConfigDeviceTimePickerView.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigDeviceTimePickerView.h"

static float const animationDuration = .3f;
static CGFloat const kpickViewH = 300.f;

@implementation MKConfigDeviceTimeModel
@end

@interface MKConfigDeviceTimePickerView()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)UIPickerView *pickView;

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, copy)void (^timePickerBlock)(MKConfigDeviceTimeModel *timeModel);

@property (nonatomic, strong)NSMutableArray *hourList;

@property (nonatomic, strong)NSMutableArray *minList;

@end

@implementation MKConfigDeviceTimePickerView

- (void)dealloc{
    NSLog(@"MKConfigDeviceTimePickerView销毁");
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = kAppWindow.bounds;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.pickView];
        [self.bottomView addSubview:self.titleLabel];
        [self addTapAction:self selector:@selector(dismiss)];
    }
    return self;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44.f;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.hourList.count;
    }
    return self.minList.count;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *titleString = @"";
    if (component == 1) {
        titleString = self.minList[row];
    }else if (component == 0) {
        titleString = self.hourList[row];
    }
    NSAttributedString *attributedString = [MKAttributedString getAttributedString:@[titleString] fonts:@[MKFont(15.f)] colors:@[DEFAULT_TEXT_COLOR]];
    return attributedString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        self.timeModel.hour = [NSString stringWithFormat:@"%ld",(long)row];
        return;
    }
    self.timeModel.minutes = [NSString stringWithFormat:@"%ld",(long)row];
}

#pragma mark - Event Method

/**
 取消选择
 */
- (void)cancelButtonPressed{
    [self dismiss];
}

/**
 确认选择
 */
- (void)confirmButtonPressed{
    if (self.timePickerBlock) {
        self.timePickerBlock(self.timeModel);
    }
    [self dismiss];
}

#pragma mark - Public Method
- (void)showTimePickViewBlock:(void (^)(MKConfigDeviceTimeModel *timeModel))Block{
    if (!self.timeModel) {
        return;
    }
    [kAppWindow addSubview:self];
    self.titleLabel.text = self.timeModel.titleMsg;
    self.timePickerBlock = Block;
    NSDictionary *dic = [self getSelectedRows];
    [self.pickView reloadAllComponents];
    [self.pickView selectRow:[dic[@"hour"] integerValue] inComponent:0 animated:NO];
    [self.pickView selectRow:[dic[@"min"] integerValue] inComponent:1 animated:NO];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -kpickViewH);
    }];
}

#pragma mark - private method
- (void)dismiss
{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (NSDictionary *)getSelectedRows{
    NSInteger hourRow = 0;
    NSInteger minRow = 0;
    for (NSInteger i = 0; i < 24; i ++) {
        NSString *valueString = [NSString stringWithFormat:@"%ld",(long)i];
        NSString *unit = @"hours";
        if (i == 0 || i == 1) {
            unit = @"hour";
        }
        NSString *tempString = [valueString stringByAppendingString:unit];
        [self.hourList addObject:tempString];
        if ([self.timeModel.hour isEqualToString:valueString]) {
            hourRow = i;
        }
    }
    for (NSInteger i = 0; i < 60; i ++) {
        NSString *valueString = [NSString stringWithFormat:@"%ld",(long)i];
        NSString *unit = @"mins";
        if (i == 0 || i == 1) {
            unit = @"min";
        }
        NSString *tempString = [valueString stringByAppendingString:unit];
        [self.minList addObject:tempString];
        if ([self.timeModel.minutes isEqualToString:valueString]) {
            minRow = i;
        }
    }
    return @{
             @"hour":@(hourRow),
             @"min":@(minRow)
             };
}

#pragma mark - setter & getter
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kpickViewH)];
        _bottomView.backgroundColor = RGBCOLOR(244, 244, 244);
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        topView.backgroundColor = COLOR_WHITE_MACROS;
        [_bottomView addSubview:topView];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(10, 10, 60, 30);
        [cancelButton setBackgroundColor:COLOR_CLEAR_MACROS];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColorFromRGB(0x0188cc) forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:MKFont(16)];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:cancelButton];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame = CGRectMake(kScreenWidth - 10 - 60, 10, 60, 30);
        [confirmBtn setBackgroundColor:COLOR_CLEAR_MACROS];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:UIColorFromRGB(0x0188cc) forState:UIControlStateNormal];
        [confirmBtn.titleLabel setFont:MKFont(16)];
        [confirmBtn addTarget:self action:@selector(confirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:confirmBtn];
    }
    return _bottomView;
}

- (UIPickerView *)pickView{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, kpickViewH - 216, self.frame.size.width - 2 * 10, 216)];
        // 显示选中框,iOS10以后分割线默认的是透明的，并且默认是显示的，设置该属性没有意义了，
        _pickView.showsSelectionIndicator = YES;
        _pickView.dataSource = self;
        _pickView.delegate = self;
        _pickView.backgroundColor = COLOR_CLEAR_MACROS;
    }
    return _pickView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth, 30.f)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = UIColorFromRGB(0x999999);
        _titleLabel.font = MKFont(12.f);
    }
    return _titleLabel;
}

- (NSMutableArray *)hourList{
    if (!_hourList) {
        _hourList = [NSMutableArray arrayWithCapacity:24];
    }
    return _hourList;
}

- (NSMutableArray *)minList{
    if (!_minList) {
        _minList = [NSMutableArray arrayWithCapacity:60];
    }
    return _minList;
}

@end
