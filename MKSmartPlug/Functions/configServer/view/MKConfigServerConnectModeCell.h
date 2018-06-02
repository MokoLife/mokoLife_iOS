//
//  MKConfigServerConnectModeCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/2.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConfigServerCellProtocol.h"

@interface MKConfigServerConnectModeCell : UITableViewCell<MKConfigServerCellProtocol>

+ (MKConfigServerConnectModeCell *)initCellWithTableView:(UITableView *)tableView;

@end
