//
//  BaseCollectionHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kParamItemHeaderIdentifier;
FOUNDATION_EXPORT NSString * const kParamItemFooterIdentifier;

@interface YSCBaseCollectionHeaderFooterView : UICollectionReusableView

#pragma mark - 注册与重用
+ (void)registerHeaderToCollectionView:(UICollectionView *)collectionView;
+ (void)registerFooterToCollectionView:(UICollectionView *)collectionView;
+ (instancetype)dequeueHeaderByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)dequeueFooterByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;
+ (NSString *)identifier;
+ (UINib *)nibNameOfView;

#pragma mark - 计算大小
+ (CGSize)sizeOfViewByObject:(NSObject *)object;

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object;

@end
