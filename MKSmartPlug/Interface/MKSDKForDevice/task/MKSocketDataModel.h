//
//  MKSocketDataModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSocketTaskID.h"

@interface MKSocketDataModel : NSObject

@property (nonatomic, copy)NSDictionary *returnData;

@property (nonatomic, assign)BOOL timeout;

@property (nonatomic, assign)MKSocketTaskID taskID;

@end
