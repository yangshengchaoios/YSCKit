//
//  BaseTableViewCell.m
//  YSCKit
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseTableViewCell.h"

@implementation YSCBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self resetFontSizeOfView];         //递归缩放label和button的字体大小
    [self resetConstraintOfView];
}
+ (YSCBaseTableViewCell *)dequeueCellByTableView :(UITableView *)tableView {
    YSCBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] identifier]];
    return cell;
}
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerNib:[[self class] NibNameOfCell] forCellReuseIdentifier:[[self class] identifier]];
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_LENGTH(290);
}
+ (CGFloat)HeightOfCellByDataModel:(BaseDataModel *)dataModel {
    return 0;
}
+ (UINib *)NibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}
- (void)layoutDataModel:(BaseDataModel *)dataModel {
    
}
- (void)layoutDataModels:(NSArray *)dataModelArray {
    
}
@end
