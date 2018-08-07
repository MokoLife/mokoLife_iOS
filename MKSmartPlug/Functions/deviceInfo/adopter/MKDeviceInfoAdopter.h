//
//  MKDeviceInfoAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDeviceInfoAdopter : NSObject

+ (void)deleteDeviceWithModel:(MKDeviceModel *)deviceModel target:(UIViewController *)target reset:(BOOL)reset;

@end
