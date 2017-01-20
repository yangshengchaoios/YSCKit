//
//  YSCBaseCollectionHeaderFooterView.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseCollectionHeaderFooterView : UICollectionReusableView

/** 注册 */
+ (void)registerHeaderFooterToCollectionView:(UICollectionView *)collectionView kind:(NSString *)kind;
/** 重用 */
+ (instancetype)dequeueHeaderFooterByCollectionView:(UICollectionView *)collectionView kind:(NSString *)kind forIndexPath:(NSIndexPath *)indexPath;

/** 计算高度 */
+ (CGSize)sizeOfViewByObject:(NSObject *)object;
/** 显示数据 */
- (void)layoutObject:(NSObject *)object;

@end
