//
//  MKConfigServerModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKConfigServerModel : NSObject

/**
 主机
 */
@property (nonatomic, copy)NSString *host;

/**
 端口号
 */
@property (nonatomic, copy)NSString *port;

/**
 是否是清除session，默认yes
 */
@property (nonatomic, assign)BOOL cleanSession;

/**
 0:TCP，1:SSL
 */
@property (nonatomic, assign)NSInteger connectMode;

/**
 qos
 */
@property (nonatomic, copy)NSString *qos;

/**
 活跃时间
 */
@property (nonatomic, copy)NSString *keepAlive;

/**
 客户端id
 */
@property (nonatomic, copy)NSString *clientId;

/**
 用户名
 */
@property (nonatomic, copy)NSString *userName;

/**
 密码
 */
@property (nonatomic, copy)NSString *password;

/**
 必须的值是否都有了，host、port、qos、keep alive

 @return YES：必须参数都有了
 */
- (BOOL)needParametersHasValue;

/**
 更新属性值

 @param dic dic
 */
- (void)updateServerModelWithDic:(NSDictionary *)dic;

- (void)updateServerDataWithModel:(MKConfigServerModel *)model;

@end
