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
    
    [self resetFontSizeOfView];         //递归缩放label和button的字体大小
    [self resetConstraintOfView];
}
+ (instancetype)dequeueHeaderByTableView:(UITableView *)tableView {
    YSCBaseTableHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[[self class] identifier]];
    return header;
}
+ (void)registerHeaderToTableView:(UITableView *)tableView {
    [tableView registerNib:[[self class] NibNameOfView] forHeaderFooterViewReuseIdentifier:[[self class] identifier]];
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)NibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

+ (CGFloat)HeightOfView {
    return AUTOLAYOUT_LENGTH(75);
}
+ (CGFloat)HeightOfViewByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(75);
}
- (void)layoutObject:(NSObject *)object {

}

- (void)layoutDataModel:(BaseDataModel *)dataModel {
    
}

- (void)layoutDataModels:(NSArray *)dataModelArray {
    
}

@end
