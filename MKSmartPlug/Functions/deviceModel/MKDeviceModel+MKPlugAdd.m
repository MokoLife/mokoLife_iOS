//
//  MKDeviceModel+MKPlugAdd.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel+MKPlugAdd.h"
#import <objc/runtime.h>

static const char *plugStateKey = "plugStateKey";

@implementation MKDeviceModel (MKPlugAdd)

- (void)setPlugState:(MKSmartPlugState)plugState{
    objc_setAssociatedObject(self, &plugStateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &plugStateKey, @(plugState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKSmartPlugState)plugState{
    return [objc_getAssociatedObject(self, &plugStateKey) integerValue];
}

@end
