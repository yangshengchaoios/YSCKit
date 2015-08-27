//
//  BaseTableViewHeaderFooterView.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseTableHeaderFooterView.h"

@implementation YSCBaseTableHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    [self resetFontSizeOfView];
    [self resetConstraintOfView];
}

#pragma mark - 注册与重用
+ (void)registerHeaderFooterToTableView:(UITableView *)tableView {
    [tableView registerNib:[[self class] NibNameOfView] forHeaderFooterViewReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueHeaderFooterByTableView:(UITableView *)tableView {
    YSCBaseTableHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[[self class] identifier]];
    return header;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)NibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算高度
+ (CGFloat)HeightOfViewByObject:(NSObject *)object {
    return 0.01;
}
+ (CGFloat)HeightOfView {
    return 0.01;
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object {}
- (void)layoutDataModel:(BaseDataModel *)dataModel {}
- (void)layoutDataModels:(NSArray *)dataModelArray {}

@end
