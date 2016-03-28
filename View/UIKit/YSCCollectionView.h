//
//  YSCCollectionView.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright (c) 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSCPullToRefreshHelper.h"

//------------------------------------
//  支持的功能：
//      1. 多section的上拉加载更多、下拉刷新
//      2. GET、POST
//      3. 列表为空的提示信息
//      4. 对数据进行缓存
//      5. 自定义任意单一确定的数据源
//      6. 兼容外部数据源(前提是必须和列表数据源类型一致)
//------------------------------------
@interface YSCCollectionView : UICollectionView
// 关闭YSCBaseViewController中对subview进行缩放
@property (nonatomic, assign) BOOL closeResetFontAndConstraint;
// 封装了网络请求和tipsView的处理
@property (nonatomic, strong) YSCPullToRefreshHelper *helper;

@property (nonatomic, strong) IBInspectable NSString *apiName;
@property (nonatomic, strong) IBInspectable NSString *modelName;
@property (nonatomic, strong) IBInspectable NSString *cellName;
@property (nonatomic, strong) IBInspectable NSString *headerName;
@property (nonatomic, strong) IBInspectable NSString *footerName;
@property (nonatomic, assign) IBInspectable UIEdgeInsets cellEdgeInsets;//边距

// blocks
@property (nonatomic, copy) YSCSectionSetBlock minimumLineSpacingBlock;
@property (nonatomic, copy) YSCSectionSetBlock minimumInteritemSpacingBlock;
@property (nonatomic, copy) YSCObjectIndexPathBlock clickCellBlock;

//  name
@property (nonatomic, copy) YSCHeaderFooterNameSetBlock headerNameBlock;
@property (nonatomic, copy) YSCCellNameSetBlock cellNameBlock;
@property (nonatomic, copy) YSCHeaderFooterNameSetBlock footerNameBlock;

//  layout
@property (nonatomic, copy) YSCViewObjectBlock layoutHeaderView;
@property (nonatomic, copy) YSCViewObjectBlock layoutCellView;
@property (nonatomic, copy) YSCViewObjectBlock layoutFooterView;

// 注册header、cell、footer
- (void)registerHeaderName:(NSString *)headerName;
- (void)registerCellName:(NSString *)cellName;
- (void)registerFooterName:(NSString *)footerName;
@end
