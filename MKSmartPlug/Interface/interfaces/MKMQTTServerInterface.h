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
