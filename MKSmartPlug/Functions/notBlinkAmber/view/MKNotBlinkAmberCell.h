//
//  MKNotBlinkAmberCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKNotBlinkAmberModel;
@interface MKNotBlinkAmberCell : UITableViewCell

@property (nonatomic, strong)MKNotBlinkAmberModel *dataModel;

+ (MKNotBlinkAmberCell *)initCellWithTableView:(UITableView *)tableView;

@end
