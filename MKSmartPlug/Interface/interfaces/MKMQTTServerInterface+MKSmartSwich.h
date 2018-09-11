//
//  MKMQTTServerInterface+MKSmartSwich.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

@interface MKMQTTServerInterface (MKSmartSwich)

/**
 Swich for countdown. When the time is up, The socket will switch on/off according to the countdown settings

 @param index 目前面板有多路开关，index是需要倒计时的开关index，0~2
 @param delay_hour Hour range:0~23
 @param delay_minutes Minute range:0~59
 @param topic Publish countdown topic
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)setSwichWithIndex:(NSInteger)index
                delayHour:(NSInteger)delay_hour
                 delayMin:(NSInteger)delay_minutes
                    topic:(NSString *)topic
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

@end
