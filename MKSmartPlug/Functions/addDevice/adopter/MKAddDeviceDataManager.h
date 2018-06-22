//
//  MKAddDeviceDataManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKAddDeviceDataManager : NSObject

+ (MKAddDeviceDataManager *)addDeviceManager;

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock;

@end
