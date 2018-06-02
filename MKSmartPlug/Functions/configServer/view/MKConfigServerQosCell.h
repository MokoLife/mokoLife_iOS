//
//  MKConfigServerQosCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConfigServerCellProtocol.h"

@interface MKConfigServerQosCell : UITableViewCell<MKConfigServerCellProtocol>

@property (nonatomic, strong)NSIndexPath *indexPath;

+ (MKConfigServerQosCell *)initCellWithTableView:(UITableView *)tableView;

@end
