//
//  BaseTableViewCell.h
//  KQ
//
//  Created by yangshengchao on 14-11-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

+ (CGFloat)HeightOfCell:(CGSize)size;
- (void)layoutDataModel:(BaseDataModel *)dataModel;
- (void)layoutDataModels:(NSArray *)dataModelArray;

@end
