//
//  BaseTableViewHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseTableHeaderFooterView : UITableViewHeaderFooterView

+ (instancetype)dequeueHeaderByTableView:(UITableView *)tableView;
+ (void)registerHeaderToTableView:(UITableView *)tableView;
+ (NSString *)identifier;

+ (CGFloat)HeightOfView;
+ (UINib *)NibNameOfView;
- (void)layoutDataModel:(BaseDataModel *)dataModel;
- (void)layoutDataModels:(NSArray *)dataModelArray;

@end
