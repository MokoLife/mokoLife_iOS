//
//  HCKDateFormatter.m
//  FitPolo
//
//  Created by aa on 17/5/17.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKDateFormatter.h"
#import <objc/runtime.h>

static const char *formatterKey = "formatterKey";

@implementation HCKDateFormatter

/**
 获取yyyy-MM-dd格式的formatter

 @return formatter
 */
+ (NSDateFormatter *)formatterWithYMD{
    NSDateFormatter *formatter = objc_getAssociatedObject(self, &formatterKey);
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
}

+ (NSString *)getCurrentSystemTime{
    return [[self formatterWithYMD] stringFromDate:[NSDate date]];
}

/**
 获取yyyy-MM-dd格式的日期
 
 @param timeString yyyy-MM-dd格式的字符串
 @return NSDate
 */
+ (NSDate *)getDateWithString:(NSString *)timeString{
    return [[self formatterWithYMD] dateFromString:timeString];
}

/**
 获取yyyy-MM-dd-HH-mm格式的formatter
 
 @return formatter
 */
+ (NSDateFormatter *)formmaterWithYMDHM{
    NSDateFormatter *formatter = objc_getAssociatedObject(self, &formatterKey);
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    return formatter;
}

/**
 获取yyyy-MM-dd-HH-mm格式的日期
 
 @param timeString yyyy-MM-dd-HH-mm格式的字符串
 @return NSDate
 */
+ (NSDate *)getDateYMDHMWithString:(NSString *)timeString{
    return [[self formmaterWithYMDHM] dateFromString:timeString];
}

+ (NSInteger)getUserAgeWithDateOfBirth:(NSInteger)birthYear{
    NSString *currentTime = [self getCurrentSystemTime];
    NSArray *currentTimeList = [currentTime componentsSeparatedByString:@"-"];
    NSInteger age = [currentTimeList[0] integerValue] - birthYear;
    return age;
}

/**
 判断startDate和当前手机系统时间之间的年数
 
 @param startDate startDate
 @return 年数
 */
+ (NSInteger)getYearCountWithStartDate:(NSString *)startDate{
    NSArray * currentTimeList = [[HCKDateFormatter getCurrentSystemTime] componentsSeparatedByString:@"-"];
    NSArray * startTimeList = [startDate componentsSeparatedByString:@"-"];
    NSInteger yearCount = [currentTimeList[0] integerValue] - [startTimeList[0] integerValue] + 1;
    return yearCount;
}

/**
 对于本地数据库，存储的日期格式都是年-月-日，计算两个日期之间的天数
 
 @param startTime 开始日期
 @param endTime 结束日期
 @return 天数
 */
+ (NSInteger)getNumberOfDaysBetween:(NSString *)startTime and:(NSString *)endTime{
    NSDate *startDate = [HCKDateFormatter getDateWithString:startTime];
    NSDate *endDate = [HCKDateFormatter getDateWithString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    if (time < 0) {
        return 0;
    }
    NSInteger count = (((NSUInteger)time) / (3600 * 24)) + 1;
    return count;
}

/**
 对于本地数据库，存储的日期格式都是年-月-日，计算两个日期之间的周数
 
 @param startTime 开始日期
 @param endTime 结束日期
 @return 周数
 */
+ (NSInteger)getNumberOfWeeksBetween:(NSString *)startTime and:(NSString *)endTime{
    NSInteger startWeek = [NSDate getWeekInfoWithDateString:startTime];
    NSInteger endWeek = [NSDate getWeekInfoWithDateString:endTime];
    NSInteger dayNum = [self getNumberOfDaysBetween:startTime and:endTime];
    dayNum = dayNum + (startWeek - 1);
    
    dayNum = dayNum + (7 - endWeek);
    NSLog(@"当前相差%f周",(dayNum / 7.f));
    return (dayNum / 7);
}

+ (void)commonDateProcess{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"'公元前/后:'G  '年份:'u'='yyyy'='yy '季度:'q'='qqq'='qqqq '月份:'M'='MMM'='MMMM '今天是今年第几周:'w '今天是本月第几周:'W  '今天是今年第几天:'D '今天是本月第几天:'d '星期:'c'='ccc'='cccc '上午/下午:'a '小时:'h'='H '分钟:'m '秒:'s '毫秒:'SSS  '这一天已过多少毫秒:'A  '时区名称:'zzzz'='vvvv '时区编号:'Z "];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);
}

@end
