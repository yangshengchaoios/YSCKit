//
//  BaseCollectionViewCell.m
//  YSCKit
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseCollectionViewCell.h"

@implementation YSCBaseCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self resetFontSizeOfView];         //递归缩放label和button的字体大小
    [self resetConstraintOfView];
}

+ (CGSize)SizeOfCell {
    return AUTOLAYOUT_SIZE_WH(290, 290);
}
+ (UINib *)NibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

- (void)layoutDataModel:(BaseDataModel *)dataModel {

}
- (void)layoutDataModels:(NSArray *)dataModelArray {

}

@end
