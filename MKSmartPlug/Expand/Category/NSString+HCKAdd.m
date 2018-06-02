//
//  NSString+HCKAdd.m
//  FitPolo
//
//  Created by aa on 17/5/10.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "NSString+HCKAdd.h"

@implementation NSString (HCKAdd)

/**
 判断当前string是否是全数字
 
 @return YES:全数字，NO:不是全数字
 */
- (BOOL)isRealNumbers{
    NSString *regex = @"^(0|[1-9][0-9]*)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

/**
 判断当前string是否是全汉字
 
 @return YES:全汉字，NO:不是全汉字
 */
- (BOOL)isChinese{
    if (self.length == 0) return NO;
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

/**
 判断当前string是否是全字母
 
 @return YES:全字母，NO:不是全字母
 */
- (BOOL)isLetter{
    if (self.length == 0) return NO;
    NSString *regex =@"[a-zA-Z]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

/**
 判断当前string是否全部是数字和字母
 
 @return YES:全部是数字和字母，NO:不是全部是数字和字母
 */
- (BOOL)isLetterOrRealNumbers{
    if (self.length == 0) return NO;
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)isValidatIP{
    if (!ValidStr(self)) return NO;
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [pred evaluateWithObject:self];
}

- (BOOL)checkClientId{
    if (!ValidStr(self)) {
        return NO;
    }
    NSString *regex = @"^[a-zA-Z_][a-zA-Z0-9_]{5,19}$";
    NSPredicate *clientIdPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [clientIdPre evaluateWithObject:self];
}

- (BOOL)checkUserName{
    if (!ValidStr(self)) {
        return NO;
    }
    NSString *regex = @"^[a-zA-Z_][a-zA-Z0-9_]{5,19}$";
    NSPredicate *userNamePre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [userNamePre evaluateWithObject:self];
}

- (BOOL)checkPassword{
    if (!ValidStr(self)) {
        return NO;
    }
    NSString *regex = @"^[a-zA-Z0-9_]{5,19}$$";
    NSPredicate *passwordPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [passwordPre evaluateWithObject:self];
}

/**
 判断当前字符串是否是url
 
 @return result
 */
- (BOOL)checkIsUrl{
    if (!ValidStr(self)) {
        return NO;
    }
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:self];
}

#pragma mark - ===============类方法====================

+ (CGSize)sizeWithLabel:(UILabel *)label
{
    NSString *text = label.text;
    if (text == nil)
        text = @"字体";
    return [NSString sizeWithText:text andFont:label.font andMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font
{
    return [NSString sizeWithText:text andFont:font andMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}

+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font andMaxSize:(CGSize)maxSize
{
    CGSize expectedLabelSize = CGSizeZero;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [paragraphStyle setLineSpacing:0];
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    expectedLabelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

@end
