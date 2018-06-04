//
//  MKSettingsCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKBaseCell.h"

@interface MKSettingsCell : MKBaseCell

@property (nonatomic, copy)NSString *msg;

+ (MKSettingsCell *)initCellWithTable:(UITableView *)tableView;

@end
