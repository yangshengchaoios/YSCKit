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
    [self resetFontSizeOfView];
    [self resetConstraintOfView];
}

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerNib:[[self class] NibNameOfCell] forCellReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView {
    YSCBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] identifier]];
    return cell;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)NibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算高度
+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return 44;
}
+ (CGFloat)HeightOfCell {
    return [self HeightOfCellByObject:nil];
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object { }
- (void)layoutDataModel:(BaseDataModel *)dataModel { [self layoutObject:dataModel]; }
- (void)layoutDataModels:(NSArray *)dataModelArray { [self layoutObject:dataModelArray]; }
@end
