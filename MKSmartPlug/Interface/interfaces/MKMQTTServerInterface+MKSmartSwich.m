//
//  MKMQTTServerInterface+MKSmartSwich.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface+MKSmartSwich.h"
#import "MKMQTTServerErrorBlockAdopter.h"

@implementation MKMQTTServerInterface (MKSmartSwich)

+ (void)setSwichWithIndex:(NSInteger)index
                delayHour:(NSInteger)delay_hour
                 delayMin:(NSInteger)delay_minutes
                    topic:(NSString *)topic
                 sucBlock:(void (^)(void))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock{
    if (index < 0 || index > 2) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (delay_hour < 0 || delay_hour > 23) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (delay_minutes < 0 || delay_minutes > 59) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *indexString = [NSString stringWithFormat:@"%ld",(long)(index + 1)];
    NSDictionary *dataDic = @{
                              [@"delay_hour_0" stringByAppendingString:indexString]:@(delay_hour),
                              [@"delay_minute_0" stringByAppendingString:indexString]:@(delay_minutes),
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

@end
