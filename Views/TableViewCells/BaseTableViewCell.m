//
//  BaseTableViewCell.m
//  YSCKit
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self resetFontSizeOfView];         //递归缩放label和button的字体大小
    [self resetConstraintOfView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
