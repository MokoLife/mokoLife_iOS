//
//  MKBaseTableView.m
//  FitPolo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "MKBaseTableView.h"

@implementation MKBaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.backgroundColor = COLOR_CLEAR_MACROS;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

@end
