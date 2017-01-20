//
//  YSCPullToRefreshHelper.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

@class YSCTipsView;

/** 定义(分页)加载功能用到的block */
typedef NSArray *(^YSCArraySetBlock)(NSArray *array);
typedef CGFloat (^YSCObjectIndexPathSetBlock)(NSObject *object, NSIndexPath *indexPath);
typedef CGFloat (^YSCObjectSectionSetBlock)(NSObject *object, NSInteger section);
typedef CGFloat (^YSCSectionSetBlock)(NSInteger section);
typedef NSString *(^YSCCellNameSetBlock)(NSObject *object, NSIndexPath *indexPath);
typedef NSString *(^YSCHeaderFooterNameSetBlock)(NSObject *object, NSInteger section);
typedef CGSize (^YSCHeaderFooterSizeSetBlock)(NSObject *object, NSInteger section);
typedef CGSize (^YSCCellSizeSetBlock)(NSObject *object, NSIndexPath *indexPath);
typedef void(^YSCLoadMoreBlock) (NSIndexSet *, NSArray<NSIndexPath *> *);
typedef void (^YSCObjectIndexPathBlock)(NSObject *object, NSIndexPath *indexPath);
typedef void (^YSCIndexPathBlock)(NSIndexPath *indexPath);
typedef void (^YSCViewObjectIndexPathBlock)(UIView *view, NSObject *object, NSIndexPath *indexPath);
typedef void (^YSCIntegerBlock)(NSInteger pageIndex);


//------------------------------------
//  作用：
//      1. 封装UITableView和UICollectionView的分页加载功能
//      2. 管理数据为空的tipsView显示
//
//------------------------------------
@interface YSCPullToRefreshHelper : NSObject
// view
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) YSCTipsView *tipsView;
@property (nonatomic, strong) NSString *tipsEmptyText;
@property (nonatomic, strong) NSString *tipsEmptyIcon;
@property (nonatomic, strong) NSString *tipsFailedIcon;
@property (nonatomic, strong) NSString *tipsTimeoutIcon;
@property (nonatomic, strong) NSString *tipsButtonTitle;
@property (nonatomic, assign) BOOL enableTips;//当列表为空时，是否显示tipsView(YES)

// 基本属性
@property (nonatomic, strong) NSMutableArray *sectionDataArray;
@property (nonatomic, strong) NSMutableArray *sectionKeyArray;//用于存储分组的判断依据
@property (nonatomic, strong) NSMutableArray *cellDataArray;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) BOOL enableRefresh;   //是否启用下拉刷新(YES)
@property (nonatomic, assign) BOOL enableLoadMore;  //是否启用上拉加载更多(YES)

// blocks
@property (nonatomic, copy) YSCIntegerBlock customRefreshBlock;
@property (nonatomic, copy) YSCArraySetBlock preProcessBlock;   //对于下载回来的一维数组进行清洗过滤
@property (nonatomic, copy) YSCBlock startLoadingBlock;         // 开始数据加载
@property (nonatomic, copy) YSCObjectBlock finishLoadingBlock;  // 加载数据结束
@property (nonatomic, copy) YSCLoadMoreBlock loadMoreBlock;
@property (nonatomic, copy) YSCIndexPathBlock deleteCellBlock;      // 删除cell

// 设置ScrollViewDelegate相关的回调
@property (nonatomic, copy) YSCBlock willBeginDraggingBlock;
@property (nonatomic, copy) YSCBlock didEndDraggingBlock;
@property (nonatomic, copy) YSCBlock didScrollBlock;
@property (nonatomic, copy) YSCBlock didEndScrollingAnimationBlock;
@property (nonatomic, copy) YSCBlock willBeginDeceleratingBlock;
@property (nonatomic, copy) YSCBlock didEndDeceleratingBlock;

/** 是否正在加载数据 */
- (BOOL)isLoading;

// 启动刷新
- (void)beginRefreshing;
- (void)beginRefreshingByAnimation:(BOOL)animation;
- (void)endRefreshing;

// 显示第几页数据
- (void)layoutObjectAtFirstPage:(NSObject *)object errorMessage:(NSString *)errorMessage;
- (void)layoutObject:(NSObject *)object atPageIndex:(NSInteger)pageIndex errorMessage:(NSString *)errorMessage;

/** 当数据为空时执行下拉刷新 */
- (void)beginRefreshingWhenCellDataIsEmpty;
/** 清空列表并刷新界面 */
- (void)clearDataAndRefreshView;

// 常用判断方法
- (BOOL)isCellDataEmpty;
- (BOOL)isLastCellByIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastSectionByIndexPath:(NSIndexPath *)indexPath;
- (NSObject *)getObjectByIndexPath:(NSIndexPath *)indexPath;
- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathByObject:(NSObject *)object;
@end
