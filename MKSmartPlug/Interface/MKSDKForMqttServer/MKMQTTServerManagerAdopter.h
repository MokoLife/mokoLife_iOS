//
//  MKMQTTServerManagerAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKMQTTServerManagerAdopter : NSObject

+ (NSError *)getErrorWithCode:(NSInteger)code message:(NSString *)message;

+ (void)operationConnectFailedBlock:(void (^)(NSError *error))block;

@end
