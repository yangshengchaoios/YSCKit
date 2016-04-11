//
//  BaseCollectionViewCell.m
//  YSCKit
//
//  Created by yangshengchao on 14-11-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseCollectionViewCell.h"

NSString * const kParamItemCellIdentifier   = @"YSCKit_ItemCell";

@implementation YSCBaseCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.clipsToBounds = YES;
    [self resetSize];
}

#pragma mark - 注册与重用
+ (void)registerCellToCollectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:[[self class] nibNameOfCell] forCellWithReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueCellByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath*)indexPath {
    YSCBaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[[self class] identifier] forIndexPath:indexPath];
    return cell;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)nibNameOfCell {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算大小
+ (CGSize)sizeOfCellByObject:(NSObject *)object {
    return CGSizeMake(145, 145);
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object {}

@end
