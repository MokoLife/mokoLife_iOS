//
//  MKConfigSwichCell.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/10.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKConfigSwichModel;
@protocol MKConfigSwichCellDelegate;
@interface MKConfigSwichCell : UITableViewCell

@property (nonatomic, strong)MKConfigSwichModel *dataModel;

@property (nonatomic, weak)id <MKConfigSwichCellDelegate>delegate;

+ (MKConfigSwichCell *)initCellWithTable:(UITableView *)tableView;

@end

@protocol MKConfigSwichCellDelegate <NSObject>
- (void)changedSwichState:(BOOL)isOn index:(NSInteger)index;

- (void)modifySwichWayNameWithIndex:(NSInteger)index;

- (void)swichStartCountdownWithIndex:(NSInteger)index;

- (void)scheduleSwichWayWithIndex:(NSInteger)index;

@end
