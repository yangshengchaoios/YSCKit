//
//  YSCPhotoBrowseView.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/12.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCPhotoBrowseView.h"

@implementation YSCPhotoBrowseView

- (void)setup {
    [super setup];
    self.collectionView.pagingEnabled = YES;
    self.itemSeperator = 20;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isScrollHor) {
        self.collectionView.frame = CGRectMake(-AUTOLAYOUT_LENGTH(self.itemSeperator / 2), 0,
                                               CGRectGetWidth(self.bounds) + AUTOLAYOUT_LENGTH(self.itemSeperator),
                                               CGRectGetHeight(self.bounds));
    }
    else {
        self.collectionView.frame = CGRectMake(0, -AUTOLAYOUT_LENGTH(self.itemSeperator / 2),
                                               CGRectGetWidth(self.bounds),
                                               CGRectGetHeight(self.bounds) + AUTOLAYOUT_LENGTH(self.itemSeperator));
    }
}

#pragma mark - UICollectionViewDataSource

#pragma mark - UICollectionFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.isScrollHor) {
        return AUTOLAYOUT_EDGEINSETS(0, self.itemSeperator / 2, 0, self.itemSeperator / 2);
    }
    else {
        return AUTOLAYOUT_EDGEINSETS(self.itemSeperator / 2, 0, self.itemSeperator / 2, 0);
    }
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return AUTOLAYOUT_LENGTH(self.itemSeperator);
}

#pragma mark - UICollectionViewDelegate

@end
