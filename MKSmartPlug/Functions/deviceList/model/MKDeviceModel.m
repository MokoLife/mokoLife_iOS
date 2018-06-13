//
//  MKDeviceModel.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@implementation MKDeviceModel

/**
 订阅的主题
 
 @return 设备功能/设备名称/型号/mac/device/#
 */
- (NSString *)topicInfo{
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
            self.device_function,
            self.device_name,
            self.device_specifications,
            self.device_mac,
            @"device",@"#"];
}

@end
