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
    if (!ValidStr(self.host)
        || !ValidStr(self.port)
        || !ValidStr(self.qos)
        || !ValidStr(self.keepAlive)
        || !ValidStr(self.clientId)
        || !ValidStr(self.userName)
        || !ValidStr(self.password)) {
        return NO;
    }
    return YES;
}

/**
 更新属性值
 
 @param dic dic
 */
- (void)updateServerModelWithDic:(NSDictionary *)dic{
    if (!ValidDict(dic)) {
        return;
    }
    if (ValidStr(dic[@"host"])) {
        self.host = dic[@"host"];
    }
    if (ValidStr(dic[@"port"])) {
        self.port = dic[@"port"];
    }
    self.cleanSession = [dic[@"cleanSession"] boolValue];
    self.connectMode = [dic[@"connectMode"] integerValue];
    if (ValidStr(dic[@"qos"])) {
        self.qos = dic[@"qos"];
    }
    if (ValidStr(dic[@"keepAlive"])) {
        self.keepAlive = dic[@"keepAlive"];
    }
    if (ValidStr(dic[@"clientId"])) {
        self.clientId = dic[@"clientId"];
    }
    if (ValidStr(dic[@"userName"])) {
        self.userName = dic[@"userName"];
    }
    if (ValidStr(dic[@"password"])) {
        self.password = dic[@"password"];
    }
}

- (void)updateServerDataWithModel:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    self.host = model.host;
    self.port = model.port;
    self.cleanSession = model.cleanSession;
    self.connectMode = model.connectMode;
    self.qos = model.qos;
    self.keepAlive = model.keepAlive;
    self.clientId = model.clientId;
    self.userName = model.userName;
    self.password = model.password;
}

@end
