//
//  MKConfigDeviceButtonModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/13.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseDataModel.h"

@interface MKConfigDeviceButtonModel : MKBaseDataModel

@property (nonatomic, copy)NSString *iconName;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, assign)BOOL isOn;

@end
