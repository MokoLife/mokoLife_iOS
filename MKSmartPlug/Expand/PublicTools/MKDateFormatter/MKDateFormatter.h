//
//  MKDateFormatter.h
//  FitPolo
//
//  Created by aa on 17/5/17.
//  Copyright © 2017年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKDateFormatter : NSObject

/**
 获取yyyy-MM-dd格式的formatter
 
 @return formatter
 */
+ (NSDateFormatter *)formatterWithYMD;

/**
 获取当前系统时间，

 @return 时间字符串
 */
+ (NSString *)getCurrentSystemTime;

/**
 获取yyyy-MM-dd格式的日期

 @param timeString yyyy-MM-dd格式的字符串
 @return NSDate
 */
+ (NSDate *)getDateWithString:(NSString *)timeString;

/**
 获取yyyy-MM-dd-HH-mm格式的formatter
 
 @return formatter
 */
+ (NSDateFormatter *)formmaterWithYMDHM;

/**
 获取yyyy-MM-dd-HH-mm格式的日期
 
 @param timeString yyyy-MM-dd-HH-mm格式的字符串
 @return NSDate
 */
+ (NSDate *)getDateYMDHMWithString:(NSString *)timeString;

@end
