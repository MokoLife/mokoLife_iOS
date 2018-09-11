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

/**
 接收和设置多路开关状态的key

 @param index index，0~2
 @return key
 */
+ (NSString *)keyForSwitchStateWithIndex:(NSInteger)index;

/**
 接收和设置多路开关倒计时的key

 @param index index，0~2
 @return key
 */
+ (NSString *)keyForDelayTimeWithIndex:(NSInteger)index;

@end
