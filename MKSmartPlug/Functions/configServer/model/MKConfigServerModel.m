//
//  MKConfigServerModel.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKConfigServerModel.h"

@implementation MKConfigServerModel

- (instancetype)init{
    if (self = [super init]) {
        self.cleanSession = YES;
    }
    return self;
}

/**
 必须的值是否都有了，host、port、qos、keep alive
 
 @return YES：必须参数都有了
 */
- (BOOL)needParametersHasValue{
    if (!ValidStr(self.host) || !ValidStr(self.port) || !ValidStr(self.qos) || !ValidStr(self.keepAlive)) {
        return NO;
    }
    return YES;
}

@end
