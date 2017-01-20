//
//  YSCBaseTableHeaderFooterView.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableHeaderFooterView : UITableViewHeaderFooterView

/** 注册 */
+ (void)registerHeaderFooterToTableView:(UITableView *)tableView;
/** 重用 */
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView;

/** 计算高度 */
+ (CGFloat)heightOfViewByObject:(NSObject *)object;
/** 显示数据 */
- (void)layoutObject:(NSObject *)object;

@end
