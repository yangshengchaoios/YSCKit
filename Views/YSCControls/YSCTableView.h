//
//  YSCTableView.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//-------------定义block类型-------------
//typedef NSString *(^YSCStringSetBlock)(NSInteger index);
//typedef BOOL (^YSCBooleanSetBlock)(NSInteger index);
//typedef NSInteger *(^YSCIntegerSetBlock)(NSInteger index);
typedef NSArray *(^YSCArraySetBlock)(NSArray *array);
typedef void (^YSCObjectIndexPathResultBlock)(NSObject *object, NSIndexPath *indexPath);
typedef void (^YSCObjectIndexResultBlock)(NSObject *object, NSInteger section);
typedef NSDictionary *(^YSCDictionarySetBlock)(NSInteger pageIndex);
//typedef UIEdgeInsets *(^YSCEdgeInsetsSetBlock)(NSInteger index);
//typedef UIColor *(^YSCColorSetBlock)(NSInteger index);
//typedef CGSize (^YSCSizeSetBlock)(NSInteger index);
//typedef CGFloat (^YSCFloatSetBlock)(NSInteger index);


//------------------------------------
//  支持的功能：
//      1. 多section的上拉加载更多、下拉刷新
//      2. GET、POST
//      3. 列表为空的提示信息
//      4. cell左右边界设置
//      5. 对数据进行缓存
//  不支持的功能：多种header 或 多种cell
//
//------------------------------------
@interface YSCTableView : UITableView

#pragma mark - 基本属性
@property (nonatomic, strong) NSMutableArray *headerDataArray;
@property (nonatomic, strong) NSMutableArray *footerDataArray;
@property (nonatomic, strong) NSMutableArray *cellDataArray;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) RequestType requestType;

#pragma mark - 必要的属性
@property (nonatomic, copy) YSCDictionarySetBlock dictParamBlock;
@property (nonatomic, strong) IBInspectable NSString *methodName;
@property (nonatomic, strong) IBInspectable NSString *modelName;
@property (nonatomic, strong) IBInspectable NSString *cellName;
@property (nonatomic, strong) IBInspectable NSString *cacheFileName;//缓存数据保存的文件名称

#pragma mark - 已有默认定义的属性
@property (nonatomic, assign) IBInspectable BOOL enableCache;//是否启用缓存(NO)TODO:
@property (nonatomic, assign) IBInspectable BOOL enableRefresh;//是否启用下拉刷新(YES)
@property (nonatomic, assign) IBInspectable BOOL enableLoadMore;//是否启用上拉加载更多(YES)
@property (nonatomic, assign) IBInspectable BOOL enableTips;//当列表为空时，是否显示tipsView(YES)
@property (nonatomic, strong) IBInspectable NSString *headerName;//默认为空
@property (nonatomic, strong) IBInspectable NSString *footerName;//默认为空
@property (nonatomic, strong) IBInspectable NSString *prefixOfUrl;//接口地址前缀(kResPathBaseUrl)
@property (nonatomic, strong) IBInspectable NSString *tipsEmptyText;//内容为空时提示文本()
@property (nonatomic, strong) IBInspectable NSString *tipsEmptyIcon;//
@property (nonatomic, strong) IBInspectable NSString *tipsFailedIcon;//
@property (nonatomic, strong) IBInspectable NSString *tipsButtonTitle;//
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorLeft;
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorRight;
@property (nonatomic, strong) YSCKTipsView *tipsView;   //提示信息，默认隐藏

#pragma mark - 设置和回传
@property (nonatomic, copy) YSCBlock successBlock;
@property (nonatomic, copy) YSCBlock failedBlock;
@property (nonatomic, copy) YSCArraySetBlock preProcessBlock;//对于下载回来的一维数组进行清洗过滤
@property (nonatomic, copy) YSCObjectIndexResultBlock clickHeaderBlock;
@property (nonatomic, copy) YSCObjectIndexResultBlock clickFooterBlock;
@property (nonatomic, copy) YSCObjectIndexPathResultBlock clickCellBlock;

//兼容下拉刷新和上拉加载更多
- (void)downloadAtIndex:(NSInteger)pageIndex;

@end
