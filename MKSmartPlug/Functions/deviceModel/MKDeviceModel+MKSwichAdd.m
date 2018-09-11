//
//  MKDeviceModel+MKSwichAdd.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel+MKSwichAdd.h"
#import <objc/runtime.h>

static const char *swichStateKey = "swichStateKey";
static const char *swich_way_nameDicKey = "swich_way_nameDicKey";
static const char *swich_way_StateDicKey = "swich_way_StateDicKey";

@implementation MKDeviceModel (MKSwichAdd)

- (void)setSwich_way_nameDic:(NSDictionary *)swich_way_nameDic{
    if (!ValidDict(swich_way_nameDic)) {
        return;
    }
    objc_setAssociatedObject(self, &swich_way_nameDicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &swich_way_nameDicKey, swich_way_nameDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)swich_way_nameDic{
    return objc_getAssociatedObject(self, &swich_way_nameDicKey);
}

- (void)setSwich_way_stateDic:(NSDictionary *)swich_way_stateDic{
    if (!ValidDict(swich_way_stateDic)) {
        return;
    }
    objc_setAssociatedObject(self, &swich_way_StateDicKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &swich_way_StateDicKey, swich_way_stateDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)swich_way_stateDic{
    return objc_getAssociatedObject(self, &swich_way_StateDicKey);
}

- (void)setSwichState:(MKSmartSwichState)swichState{
    objc_setAssociatedObject(self, &swichStateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &swichStateKey, @(swichState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKSmartSwichState)swichState{
    return [objc_getAssociatedObject(self, &swichStateKey) integerValue];
}

+ (NSString *)keyForSwitchStateWithIndex:(NSInteger)index{
    if (index < 0 || index > 2) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@%ld",@"switch_state_0",(long)(index + 1)];
    return key;
}

+ (NSString *)keyForDelayTimeWithIndex:(NSInteger)index{
    if (index < 0 || index > 2) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@%ld",@"delay_time_0",(long)(index + 1)];
    return key;
}

@end
