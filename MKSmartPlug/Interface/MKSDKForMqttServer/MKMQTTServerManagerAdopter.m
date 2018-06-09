//
//  MKMQTTServerManagerAdopter.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerManagerAdopter.h"

@implementation MKMQTTServerManagerAdopter

+ (NSError *)getErrorWithCode:(NSInteger)code message:(NSString *)message{
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.MKMQTTServerSDK"
                                                code:code
                                            userInfo:@{@"errorInfo":(message == nil ? @"" : message)}];
    return error;
}


+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block([self getErrorWithCode:-999 message:@"Connect failed"]);
        }
    });
}

@end
