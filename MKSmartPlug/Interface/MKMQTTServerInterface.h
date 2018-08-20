//
//  MKMQTTServerInterface.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MKFirmwareUpdateHostType) {
    MKFirmwareUpdateHostTypeIP,
    MKFirmwareUpdateHostTypeUrl,
};

@interface MKMQTTServerInterface : NSObject

/**
 改变开关状态
 
 @param isOn isOn
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setSwitchState:(BOOL)isOn deviceModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target;

/**
 设置延时功能

 @param hour 延时时
 @param minutes 延时分
 @param deviceModel deviceModel
 @param target vc
 */
+ (void)setDelayHour:(NSString *)hour
             minutes:(NSString *)minutes
         deviceModel:(MKDeviceModel *)deviceModel
              target:(UIViewController *)target;

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
+ (void)setDelayHour:(NSInteger)delay_hour
            delayMin:(NSInteger)delay_minutes
               topic:(NSString *)topic
            sucBlock:(void (^)(void))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Factory Reset
 
 @param topic topic
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)resetDeviceWithTopic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Read device information
 
 @param topic topic
 @param sucBlock      Success callback
 @param failedBlock   Failed callback
 */
+ (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;
/**
 Plug OTA upgrade
 
 @param hostType hostType
 @param host          The IP address or domain name of the new firmware host
 @param port          Range£∫0~65535
 @param catalogue     The length is less than 100 bytes
 @param topic         Firmware upgrade topic
 @param sucBlock      Success callback
 @param failedBlock   Failed callback
 */
+ (void)updateFirmware:(MKFirmwareUpdateHostType)hostType
                  host:(NSString *)host
                  port:(NSInteger)port
             catalogue:(NSString *)catalogue
                 topic:(NSString *)topic
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

@end
