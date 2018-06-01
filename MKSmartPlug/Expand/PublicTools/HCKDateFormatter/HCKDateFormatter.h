//
//  HCKDateFormatter.h
//  FitPolo
//
//  Created by aa on 17/5/17.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCKDateFormatter : NSObject

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

+ (NSInteger)getUserAgeWithDateOfBirth:(NSInteger)birthYear;

/**
 对于本地数据库，存储的日期格式都是年-月-日，计算两个日期之间的天数

 @param startTime 开始日期
 @param endTime 结束日期
 @return 天数
 */
+ (NSInteger)getNumberOfDaysBetween:(NSString *)startTime and:(NSString *)endTime;
/**
 对于本地数据库，存储的日期格式都是年-月-日，计算两个日期之间的周数
 
 @param startTime 开始日期
 @param endTime 结束日期
 @return 周数
 */
+ (NSInteger)getNumberOfWeeksBetween:(NSString *)startTime and:(NSString *)endTime;
/**
 判断startDate和当前手机系统时间之间的年数
 
 @param startDate startDate
 @return 年数
 */
+ (NSInteger)getYearCountWithStartDate:(NSString *)startDate;

@end
