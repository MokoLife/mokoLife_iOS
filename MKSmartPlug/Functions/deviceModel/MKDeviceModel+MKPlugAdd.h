//
//  MKDeviceModel+MKPlugAdd.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel (MKPlugAdd)

/**
 智能插座当前设备的状态，离线、开、关
 */
@property (nonatomic, assign)MKSmartPlugState plugState;

@end
