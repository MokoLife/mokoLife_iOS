//
//  MKDeviceListController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceListController.h"
#import "MKSettingsController.h"
#import "MKSelectDeviceTypeController.h"
#import "MKBaseTableView.h"
#import "MKDeviceModel.h"

@interface MKDeviceListController ()

@end

@implementation MKDeviceListController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceListController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.leftButton setImage:LOADIMAGE(@"mokoLife_menuIcon", @"png") forState:UIControlStateNormal];
    [self.rightButton setImage:LOADIMAGE(@"mokoLife_addIcon", @"png") forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Moko Life";
}

- (void)leftButtonMethod{
    MKSettingsController *vc = [[MKSettingsController alloc] initWithNavigationType:GYNaviTypeShow];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod{
    MKSelectDeviceTypeController *vc = [[MKSelectDeviceTypeController alloc] initWithNavigationType:GYNaviTypeShow];
    vc.isPrensent = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -

@end
