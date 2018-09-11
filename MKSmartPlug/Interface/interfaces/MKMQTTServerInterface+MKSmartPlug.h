//
//  MKMQTTServerInterface+MKSmartPlug.h
//  MKSmartPlug
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

@interface MKMQTTServerInterface (MKSmartPlug)

/**
 Sets the switch state of the plug
 
 @param isOn           YES:ON£¨NO:OFF
 @param topic          Publish switch state topic
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)setSmartPlugSwitchState:(BOOL)isOn
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Plug for countdown. When the time is up, The socket will switch on/off according to the countdown settings
 
 @param delay_hour     Hour range:0~23
 @param delay_minutes  Minute range:0~59
 @param topic          Publish countdown topic
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)setPlugDelayHour:(NSInteger)delay_hour
                delayMin:(NSInteger)delay_minutes
                   topic:(NSString *)topic
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

@end
