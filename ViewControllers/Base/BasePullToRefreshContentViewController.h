//
//  BasePullToRefreshContentViewController.h
//  TGO2
//
//  Created by  YangShengchao on 14-3-27.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import "BasePullToRefreshViewController.h"

@interface BasePullToRefreshContentViewController : BasePullToRefreshViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;

#pragma mark - UICollectionView特有的方法

- (CGSize)itemSize;                                                     //item大小
- (UIEdgeInsets)itemEdgeInsets;                                         //item边距
- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section;      //cell的最小行间距
- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section; //cell的最小列间距

@end
