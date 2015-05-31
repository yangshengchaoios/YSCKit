//
//  BaseCollectionViewCell.h
//  YSCKit
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseCollectionViewCell : UICollectionViewCell

+ (CGSize)SizeOfCell;
+ (UINib *)NibNameOfCell;
- (void)layoutDataModel:(BaseDataModel *)dataModel;
- (void)layoutDataModels:(NSArray *)dataModelArray;

@end
