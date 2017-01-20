//
//  YSCBaseCollectionViewCell.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCBaseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

/** 初始化方法 */
- (void)setup;
/** 注册 */
+ (void)registerCellToCollectionView:(UICollectionView *)collectionView;
/** 重用 */
+ (instancetype)dequeueCellByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

/** 计算大小 */
+ (CGSize)sizeOfCellByObject:(NSObject *)object;
/** 显示数据 */
- (void)layoutObject:(NSObject *)object;

@end
