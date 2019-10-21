//
//  MKMQTTServerInterface.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"
#import "MKMQTTServerErrorBlockAdopter.h"

@implementation MKMQTTServerInterface

+ (void)updateFirmware:(MKFirmwareUpdateHostType)hostType
                  host:(NSString *)host
                  port:(NSInteger)port
             catalogue:(NSString *)catalogue
                 topic:(NSString *)topic
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock{
    if (!host || port < 0 || port > 65535 || !catalogue) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"type":@(hostType),
                              @"realm":host,
                              @"port":@(port),
                              @"catalogue":catalogue,
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)resetDeviceWithTopic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{} topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{} topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

@end
