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

/**
 当前状态
 */
@property (nonatomic, assign, readonly)MKSessionManagerState managerState;

+ (MKMQTTServerConnectManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接mqtt server

 @param progressBlock 连接进度回调
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectMqttServerWithProgressBlock:(void (^)(CGFloat progress))progressBlock
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

@end
