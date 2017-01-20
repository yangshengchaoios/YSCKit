//
//  YSCGridBrowseView.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//


//====================================
//
//  宫格浏览器
//  支持水平和垂直两个方向浏览
//
//====================================
@interface YSCGridBrowseView : UIView
@property (nonatomic, assign) IBInspectable CGFloat minimumLineSpacing;     //间隔默认10pt
@property (nonatomic, assign) IBInspectable CGFloat itemEdgeTop;            //item的四周间隔
@property (nonatomic, assign) IBInspectable CGFloat itemEdgeLeft;
@property (nonatomic, assign) IBInspectable CGFloat itemEdgeBottom;
@property (nonatomic, assign) IBInspectable CGFloat itemEdgeRight;
@property (nonatomic, assign) IBInspectable BOOL isScrollHorizontal;        //Default YES
@property (nonatomic, strong) IBInspectable NSString *collectionViewCell;   //默认是Nib
@property (nonatomic, copy) void (^tapPageAtIndex)(NSInteger pageIndex, NSError *error);   //点击某个图片后回调

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) NSArray *dataArray;

- (void)refreshCollectionViewByItemArray:(NSArray *)itemArray;
@end
