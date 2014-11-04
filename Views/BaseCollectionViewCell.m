//
//  BaseCollectionViewCell.m
//  KQ
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "BaseCollectionViewCell.h"

@implementation BaseCollectionViewCell

+ (CGSize)SizeOfCell {
    return AUTOLAYOUT_SIZE([self SizeOfCellInXib]);
}
+ (CGSize)SizeOfCellInXib {
    return CGSizeMake(290, 290);
}
- (void)layoutDataModel:(BaseDataModel *)dataModel {

}
- (void)layoutDataModels:(NSArray *)dataModelArray {

}

@end
