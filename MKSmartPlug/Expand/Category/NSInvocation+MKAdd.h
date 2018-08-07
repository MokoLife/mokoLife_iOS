//
//  NSInvocation+MKAdd.h
//  FitPolo
//
//  Created by aa on 17/7/4.
//  Copyright © 2017年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (MKAdd)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector arguments:(void*)firstArgument,...;

@end