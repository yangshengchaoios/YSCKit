//
//  BaseCollectionViewCell.h
//  YSCKit
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kParamItemCellIdentifier;

@interface YSCBaseCollectionViewCell : UICollectionViewCell

#pragma mark - 注册与重用
+ (void)registerCellToCollectionView:(UICollectionView *)collectionView;
+ (instancetype)dequeueCellByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath*)indexPath;
+ (NSString *)identifier;
+ (UINib *)nibNameOfCell;

#pragma mark - 计算大小
+ (CGSize)sizeOfCellByObject:(NSObject *)object;

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object;

@end
