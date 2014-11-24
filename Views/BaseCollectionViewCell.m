//
//  BaseCollectionViewCell.m
//  KQ
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseCollectionViewCell.h"

@implementation BaseCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [UIView clearBackgroundColorOfView:self];       //递归设置tag>=1000的背景颜色为空
    [UIView resetFontSizeOfView:self];              //递归缩放label和button的字体大小
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
