//
//  MKNotBlinkAmberController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkAmberController.h"

@interface MKNotBlinkAmberController ()

@end

@implementation MKNotBlinkAmberController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKNotBlinkAmberController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Operation Steps";
}

#pragma mark - event method

#pragma mark - loadSubViews

#pragma mark - setter & getter


@end
