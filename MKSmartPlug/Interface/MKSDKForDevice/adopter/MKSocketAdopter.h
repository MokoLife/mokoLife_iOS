//
//  MKSocketAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKSocketAdopter : NSObject

+ (BOOL)isValidatIP:(NSString *)IPAddress;

/**
 字典转json字符串方法

 @param dict json
 @return string
 */
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

/**
 JSON字符串转化为字典
 
 @param jsonString string
 @return dic
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
