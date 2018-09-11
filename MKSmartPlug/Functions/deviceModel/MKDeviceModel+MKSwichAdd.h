//
//  MKDeviceModel+MKSwichAdd.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel (MKSwichAdd)

@property (nonatomic, assign)MKSmartSwichState swichState;

/**
 面板里面有多路开关，名字不一样
 */
@property (nonatomic, strong)NSDictionary *swich_way_nameDic;

/**
 多路开关的状态
 */
@property (nonatomic, strong)NSDictionary *swich_way_stateDic;

@end
