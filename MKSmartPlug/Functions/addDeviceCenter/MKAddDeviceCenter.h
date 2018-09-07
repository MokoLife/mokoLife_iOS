//
//  MKAddDeviceCenter.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKAddDeviceKeys.h"

@interface MKAddDeviceCenter : NSObject

@property (nonatomic, assign)currentDeviceType deviceType;

+ (MKAddDeviceCenter *)sharedInstance;

+ (void)deallocCenter;

- (NSDictionary *)fecthAddDeviceParams;

- (NSArray *)fecthNotBlinkAmberDataSource;

@end
