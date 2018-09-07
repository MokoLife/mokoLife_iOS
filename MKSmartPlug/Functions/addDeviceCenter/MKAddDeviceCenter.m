//
//  MKAddDeviceCenter.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceCenter.h"

static dispatch_once_t onceToken;
static MKAddDeviceCenter *center = nil;

@implementation MKAddDeviceCenter

- (void)dealloc{
    NSLog(@"MKAddDeviceCenter销毁");
}

+ (MKAddDeviceCenter *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!center) {
            center = [MKAddDeviceCenter new];
        }
    });
    return center;
}

+ (void)deallocCenter{
    onceToken = 0;
    center = nil;
}

- (NSDictionary *)fecthAddDeviceParams{
    NSString *message = @"Plug in the device and confirm that indicator is blinking amber";
    NSString *gifName = @"addDevice_centerPlugGif";
    NSString *linkMessage = @"My light is not blinking amber";
    NSString *blinkButtonTitle = @"Indicator blink amber light";
    CGFloat gifWidth = 144.f;
    CGFloat gifHeight = 253.f;
    if (self.deviceType == device_swich) {
        message = @"Plug in the device and confirm that indicator is blinking red";
        gifName = @"addDevice_centerSwichGif";
        gifWidth = 200.f;
        gifHeight = 200.f;
        linkMessage = @"My light is not blinking red";
        blinkButtonTitle = @"Indicator blink red light";
        return @{
                 addDevice_messageKey:message,
                 addDevice_gifNameKey:gifName,
                 addDevice_gifWidthKey:@(gifWidth),
                 addDevice_gifHeightKey:@(gifHeight),
                 addDevice_linkMessageKey:linkMessage,
                 addDevice_blinkButtonTitleKey:blinkButtonTitle,
                 addDevice_currentDeviceTypeKey:@(device_swich),
                 };
    }
    //默认插座
    return @{
             addDevice_messageKey:message,
             addDevice_gifNameKey:gifName,
             addDevice_gifWidthKey:@(gifWidth),
             addDevice_gifHeightKey:@(gifHeight),
             addDevice_linkMessageKey:linkMessage,
             addDevice_blinkButtonTitleKey:blinkButtonTitle,
             addDevice_currentDeviceTypeKey:@(device_plug),
             };
}

- (NSArray *)fecthNotBlinkAmberDataSource{
    if (self.deviceType == device_swich) {
        NSDictionary *dic1 = @{
                                @"stepMsg":@"Step 1",
                                @"operationMsg":@"Plug the device in power",
                                @"iconName":@"",
                               };
        NSDictionary *dic2 = @{
                               @"stepMsg":@"Step 2",
                               @"operationMsg":@"Hold the button for 10s until the LED blink red",
                               @"iconName":@"notBlinkRedStep2Icon",
                               };
        NSDictionary *dic3 = @{
                               @"stepMsg":@"Step 3",
                               @"operationMsg":@"Confirm the indicator light is blinking",
                               @"iconName":@"notBlinkRedStep3Icon",
                               };
        return @[dic1,dic2,dic3];
    }
    NSDictionary *step1Dic = @{
                               @"stepMsg":@"Step 1",
                               @"operationMsg":@"Plug the device in power",
                               @"leftIconName":@"notBlinkAmberStep1_leftIcon",
                               @"rightIconName":@"notBlinkAmberStep1_rightIcon",
                               };
    NSDictionary *step2Dic = @{
                               @"stepMsg":@"Step 2",
                               @"operationMsg":@"Hold the button for 10s until the LED blink amber",
                               @"leftIconName":@"notBlinkAmberStep2_leftIcon",
                               @"rightIconName":@"notBlinkAmberStep2_rightIcon",
                               };
    return @[step1Dic,step2Dic];
}

@end
