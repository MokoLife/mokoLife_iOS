//
//  MKMQTTServerConnectManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKConfigServerModel;
@interface MKMQTTServerConnectManager : NSObject

@property (nonatomic, strong, readonly)MKConfigServerModel *configServerModel;

+ (MKMQTTServerConnectManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接mqtt server

 */
- (void)connectServer;

/**
 订阅主题
 */
- (void)updateMQTTServerTopic:(NSArray <NSString *>*)topicList;

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData;

@end
