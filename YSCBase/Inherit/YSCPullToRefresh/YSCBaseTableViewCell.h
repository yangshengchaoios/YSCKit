//
//  YSCBaseTableViewCell.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableViewCell : UITableViewCell

/** 初始化方法 */
- (void)setup;
/** 注册 */
+ (void)registerCellToTableView:(UITableView *)tableView;
/** 重用 */
+ (instancetype)dequeueCellByTableView:(UITableView *)tableView;

/** 计算高度 */
+ (CGFloat)heightOfCellByObject:(NSObject *)object;
/** 显示数据 */
- (void)layoutObject:(NSObject *)object;

@end
