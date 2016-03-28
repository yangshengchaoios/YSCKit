//
//  BaseCollectionHeaderFooterView.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseCollectionHeaderFooterView.h"

NSString * const kParamItemHeaderIdentifier     = @"YSCKit_ItemHeader";
NSString * const kParamItemFooterIdentifier     = @"YSCKit_ItemFooter";

@implementation YSCBaseCollectionHeaderFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    [self resetFontSizeOfView];
    [self resetConstraintOfView];
}

#pragma mark - 注册与重用
+ (void)registerHeaderToCollectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:[[self class] nibNameOfView]
     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
            withReuseIdentifier:[[self class] identifier]];
}
+ (void)registerFooterToCollectionView:(UICollectionView *)collectionView {
    [collectionView registerNib:[[self class] nibNameOfView]
     forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
            withReuseIdentifier:[[self class] identifier]];
}
+ (instancetype)dequeueHeaderByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    YSCBaseCollectionHeaderFooterView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                   withReuseIdentifier:[[self class] identifier]
                                                                                          forIndexPath:indexPath];
    return header;
}
+ (instancetype)dequeueFooterByCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    YSCBaseCollectionHeaderFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                   withReuseIdentifier:[[self class] identifier]
                                                                                          forIndexPath:indexPath];
    return footer;
}
+ (NSString *)identifier {
    return NSStringFromClass(self.class);
}
+ (UINib *)nibNameOfView {
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
}

#pragma mark - 计算大小
+ (CGSize)sizeOfViewByObject:(NSObject *)object {
    return CGSizeMake(SCREEN_WIDTH, 35.0f);
}

#pragma mark - 呈现数据
- (void)layoutObject:(NSObject *)object {}

@end
