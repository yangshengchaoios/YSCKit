//
//  BasePullToRefreshContentViewController.m
//  TGO2
//
//  Created by  YangShengchao on 14-3-27.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "BasePullToRefreshContentViewController.h"

@interface BasePullToRefreshContentViewController ()

@end

@implementation BasePullToRefreshContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.collectionView registerNib:[UINib nibWithNibName:[self nibNameOfCell] bundle:nil] forCellWithReuseIdentifier:kItemCellIdentifier];
	self.collectionView.showsHorizontalScrollIndicator = NO;        //TODO:以后这里可以扩展
	self.collectionView.showsVerticalScrollIndicator = YES;
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = kDefaultViewColor;
    self.collectionView.alwaysBounceVertical = YES;
}
#pragma mark - 私有方法子类无需重写

- (void)reloadByAdding:(NSArray *)anArray {
    [super reloadByAdding:anArray];
    NSIndexSet *insertedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.dataArray count], [anArray count])];
    [self.dataArray insertObjects:anArray atIndexes:insertedIndexSet];
    
    WeakSelfType blockSelf = self;
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        int resultsSize = [anArray count];
        NSMutableArray *insertedIndexPaths = [NSMutableArray array];
        for (int i = resultsSize; i < resultsSize + anArray.count; i++) {
            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [blockSelf.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
    }
                                  completion:nil];
    [UIView setAnimationsEnabled:YES];
}

- (UIScrollView *)contentScrollView
{
    return self.collectionView;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - 子类必须重写的方法

- (UIView *)layoutCellWithData:(id)object atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kItemCellIdentifier forIndexPath:indexPath];
	return cell;
}

#pragma mark - UICollectionView特有的方法

- (CGSize)itemSize {
	return CGSizeMake(130, 140);
}

- (UIEdgeInsets)itemEdgeInsets {
	return UIEdgeInsetsMake(20, 20, 20, 20);
}
//cell的最小行间距
- (CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return 20.0f;
}
//cell的最小列间距
- (CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return 20.0f;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self cellCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	id objectModel = nil;
	if (indexPath.row < [self.dataArray count]) {
		objectModel = [self.dataArray objectAtIndex:indexPath.row];
	}
	UICollectionViewCell *cell = (UICollectionViewCell *)[self layoutCellWithData:objectModel atIndexPath:indexPath];
	return cell;
}

#pragma mark - UICollectionFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [self itemSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return [self itemEdgeInsets];
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return [self minimumLineSpacingForSectionAtIndex:section];
}

//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return [self minimumInteritemSpacingForSectionAtIndex:section];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	id objectModel = nil;
	if (indexPath.row < [self.dataArray count]) {
		objectModel = [self.dataArray objectAtIndex:indexPath.row];
	}
	[self clickedCell:objectModel atIndexPath:indexPath];
}

@end
