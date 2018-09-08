//
//  MKAddDeviceCenter.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAddDeviceKeys.h"

@interface MKAddDeviceCenter : NSObject

@property (nonatomic, assign)MKDeviceType deviceType;

+ (MKAddDeviceCenter *)sharedInstance;

+ (void)deallocCenter;

+ (UILabel *)connectAlertTitleLabel:(NSString *)title;

+ (UILabel *)connectAlertMsgLabel:(NSString *)text;
/**
 跳转到设置->wifi页面
 */
+ (void)gotoSystemWifiPage;

- (NSDictionary *)fecthAddDeviceParams;

- (NSDictionary *)fecthNotBlinkParams;

@end
