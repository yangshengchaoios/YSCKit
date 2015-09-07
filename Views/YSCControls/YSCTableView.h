//
//  YSCTableView.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//-------------定义block类型-------------
typedef NSArray *(^YSCArraySetBlock)(NSArray *array);
typedef void (^YSCObjectIndexPathResultBlock)(NSObject *object, NSIndexPath *indexPath);
typedef void (^YSCObjectIndexResultBlock)(NSObject *object, NSInteger section);
typedef NSDictionary *(^YSCDictionarySetBlock)(NSInteger pageIndex);
typedef void (^YSCViewObjectResultBlock)(UIView *view, NSObject *object);
typedef CGFloat (^YSCFloatSetBlock)(NSIndexPath *indexPath);


//------------------------------------
//  支持的功能：
//      1. 多section的上拉加载更多、下拉刷新
//      2. GET、POST
//      3. 列表为空的提示信息
//      4. cell左右边界设置
//      5. 对数据进行缓存
//      6. 自定义任意单一确定的数据源
//      7. 动态设置header、cell、footer的高度
//  不支持的功能：多种header 或 多种cell 或 多数据源
//
//------------------------------------
@interface YSCTableView : UITableView

@property (nonatomic, assign) BOOL closeResetFontAndConstraint;//关闭YSCBaseViewController中对该view进行缩放

#pragma mark - 基本属性
@property (nonatomic, strong) NSMutableArray *headerDataArray;
@property (nonatomic, strong) NSMutableArray *footerDataArray;
@property (nonatomic, strong) NSMutableArray *cellDataArray;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) RequestType requestType;
@property (nonatomic, strong) YSCKTipsView *tipsView;   //提示信息，默认隐藏

#pragma mark - 必要的属性
@property (nonatomic, copy) YSCDictionarySetBlock dictParamBlock;
@property (nonatomic, strong) IBInspectable NSString *methodName;
@property (nonatomic, strong) IBInspectable NSString *modelName;
@property (nonatomic, strong) IBInspectable NSString *cellName;

#pragma mark - 已有默认定义的属性
@property (nonatomic, strong) IBInspectable NSString *prefixOfUrl;//接口地址前缀(kResPathBaseUrl)
@property (nonatomic, strong) IBInspectable NSString *tipsEmptyText;//内容为空时提示文本()
@property (nonatomic, strong) IBInspectable NSString *tipsEmptyIcon;//
@property (nonatomic, strong) IBInspectable NSString *tipsFailedIcon;//
@property (nonatomic, strong) IBInspectable NSString *tipsButtonTitle;//

@property (nonatomic, strong) IBInspectable NSString *headerName;//默认为空
@property (nonatomic, strong) IBInspectable NSString *footerName;//默认为空
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorLeft;
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorRight;

@property (nonatomic, assign) IBInspectable BOOL enableRefresh;//是否启用下拉刷新(YES)
@property (nonatomic, assign) IBInspectable BOOL enableLoadMore;//是否启用上拉加载更多(YES)
@property (nonatomic, assign) IBInspectable BOOL enableTips;//当列表为空时，是否显示tipsView(YES)

#pragma mark - 设置和回传
@property (nonatomic, copy) YSCBlock successBlock;
@property (nonatomic, copy) YSCBlock failedBlock;
@property (nonatomic, copy) YSCArraySetBlock preProcessBlock;//对于下载回来的一维数组进行清洗过滤
@property (nonatomic, copy) YSCObjectIndexResultBlock clickHeaderBlock;
@property (nonatomic, copy) YSCObjectIndexResultBlock clickFooterBlock;
@property (nonatomic, copy) YSCObjectIndexPathResultBlock clickCellBlock;
@property (nonatomic, copy) YSCViewObjectResultBlock layoutHeader;
@property (nonatomic, copy) YSCViewObjectResultBlock layoutFooter;
@property (nonatomic, copy) YSCFloatSetBlock headerHeightBlock;
@property (nonatomic, copy) YSCFloatSetBlock cellHeightBlock;
@property (nonatomic, copy) YSCFloatSetBlock footerHeightBlock;

//创建对象，不用xib布局时使用
+ (instancetype)CreateYSCTableViewOnView:(UIView *)view;

//启动刷新(能加载一次缓存)
- (void)beginRefreshing;
- (void)beginRefreshingByAnimation:(BOOL)animation;
//当数据为空时执行下拉刷新
- (void)refreshWhenCellDataEmpty;

//开启缓存模式
- (void)enableCacheWithFileName:(NSString *)fileName;

//下载数据(可重写)
- (void)refreshAtPageIndex:(NSInteger)pageIndex;
- (void)refreshAtPageIndex:(NSInteger)pageIndex response:(NSObject *)responseObject error:(NSString *)errMsg;

- (BOOL)isCellDataEmpty;//判断cell数组是否为空
- (BOOL)isLastCellByIndexPath:(NSIndexPath *)indexPath;//判断cell是否最后一个
- (BOOL)isLastSectionByIndexPath:(NSIndexPath *)indexPath;//判断section是否最后一个

@end
