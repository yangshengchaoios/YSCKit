//
//  BaseTableViewCell.m
//  KQ
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)HeightOfCell {
    return AUTOLAYOUT_HEIGHT([self SizeOfCellInXib]);
}
+ (CGSize)SizeOfCellInXib {
    return CGSizeMake(290, 290);
}

- (void)layoutDataModel:(BaseDataModel *)dataModel {
    
}

- (void)layoutDataModels:(NSArray *)dataModelArray {
    
}
@end
