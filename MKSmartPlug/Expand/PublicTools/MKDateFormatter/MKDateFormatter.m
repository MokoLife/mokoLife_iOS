//
//  MKDateFormatter.m
//  FitPolo
//
//  Created by aa on 17/5/17.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKDateFormatter.h"
#import <objc/runtime.h>

static const char *formatterKey = "formatterKey";

@implementation MKDateFormatter

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

+ (void)commonDateProcess{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"'公元前/后:'G  '年份:'u'='yyyy'='yy '季度:'q'='qqq'='qqqq '月份:'M'='MMM'='MMMM '今天是今年第几周:'w '今天是本月第几周:'W  '今天是今年第几天:'D '今天是本月第几天:'d '星期:'c'='ccc'='cccc '上午/下午:'a '小时:'h'='H '分钟:'m '秒:'s '毫秒:'SSS  '这一天已过多少毫秒:'A  '时区名称:'zzzz'='vvvv '时区编号:'Z "];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);
}

@end
