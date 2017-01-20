//
//  YSCCollectionView.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCPullToRefreshHelper.h"

//------------------------------------
//  支持的功能：
//      1. 多section的上拉加载更多、下拉刷新
//      2. GET、POST
//      3. 列表为空的提示信息
//      4. 自定义任意单一确定的数据源
//      5. 动态设置header、cell、footer的size
//      6. 支持多种header、cell、footer的注册
//      7. 兼容外部数据源(前提是必须和列表数据源类型一致)
//------------------------------------
@interface YSCCollectionView : UICollectionView
// 封装了网络请求和tipsView的处理
@property (nonatomic, strong) YSCPullToRefreshHelper *helper;

@property (nonatomic, strong) IBInspectable NSString *cellName;
@property (nonatomic, strong) IBInspectable NSString *headerName;
@property (nonatomic, strong) IBInspectable NSString *footerName;
@property (nonatomic, assign) IBInspectable UIEdgeInsets cellEdgeInsets;

// blocks
/** 最小行间距(10) */
@property (nonatomic, copy) YSCSectionSetBlock minimumLineSpacingBlock;
/** 最小列间距(0) */
@property (nonatomic, copy) YSCSectionSetBlock minimumInteritemSpacingBlock;
/** 点击cell */
@property (nonatomic, copy) YSCObjectIndexPathBlock clickCellBlock;

//  name
@property (nonatomic, copy) YSCHeaderFooterNameSetBlock headerNameBlock;
@property (nonatomic, copy) YSCCellNameSetBlock cellNameBlock;
@property (nonatomic, copy) YSCHeaderFooterNameSetBlock footerNameBlock;

//  size
@property (nonatomic, copy) YSCHeaderFooterSizeSetBlock headerSizeBlock;
@property (nonatomic, copy) YSCCellSizeSetBlock cellSizeBlock;
@property (nonatomic, copy) YSCHeaderFooterSizeSetBlock footerSizeBlock;

//  layout
@property (nonatomic, copy) YSCViewObjectIndexPathBlock layoutHeaderView;
@property (nonatomic, copy) YSCViewObjectIndexPathBlock layoutCellView;
@property (nonatomic, copy) YSCViewObjectIndexPathBlock layoutFooterView;

// 注册header、cell、footer
- (void)registerHeaderName:(NSString *)headerName;
- (void)registerCellName:(NSString *)cellName;
- (void)registerFooterName:(NSString *)footerName;
@end
