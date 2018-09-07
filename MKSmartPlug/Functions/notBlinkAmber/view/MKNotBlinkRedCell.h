//
//  MKNotBlinkRedCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKNotBlinkRedModel;
@interface MKNotBlinkRedCell : UITableViewCell

@property (nonatomic, strong)MKNotBlinkRedModel *dataModel;

+ (MKNotBlinkRedCell *)initCellWithTableView:(UITableView *)tableView;

@end
