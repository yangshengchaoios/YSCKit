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
typedef UIView *(^YSCViewSetBlock)(id object, NSIndexPath *indexPath);
typedef void (^YSCObjectIndexPathResultBlock)(id object, NSIndexPath *indexPath);
//typedef UIEdgeInsets *(^YSCEdgeInsetsSetBlock)(NSInteger index);
//typedef UIColor *(^YSCColorSetBlock)(NSInteger index);
//typedef CGSize (^YSCSizeSetBlock)(NSInteger index);
//typedef CGFloat (^YSCFloatSetBlock)(NSInteger index);
//typedef NSDictionary *(^YSCDictionarySetBlock)(NSInteger index);


@interface YSCTableView : UITableView
#pragma mark - 基本属性
@property (nonatomic, strong) NSMutableArray *sectionDataArray;
@property (nonatomic, strong) NSMutableArray *cellDataArray;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) YSCKTipsView *tipsView;   //提示信息，默认隐藏

#pragma mark - 必要的属性
@property (nonatomic, strong) IBInspectable NSString *methodName;
@property (nonatomic, strong) IBInspectable NSDictionary *dictParam;
@property (nonatomic, strong) IBInspectable NSString *modelName;
@property (nonatomic, strong) IBInspectable NSString *cellName;

#pragma mark - 已有默认定义的属性
@property (nonatomic, strong) IBInspectable NSString *headerName;
@property (nonatomic, assign) IBInspectable CGFloat headerHeight;
@property (nonatomic, strong) IBInspectable NSString *footerName;
@property (nonatomic, assign) IBInspectable CGFloat footerHeight;

@property (nonatomic, assign) IBInspectable NSInteger requestType;
@property (nonatomic, assign) IBInspectable BOOL enableCache;//是否启用缓存(NO)
@property (nonatomic, assign) IBInspectable BOOL enableRefresh;//是否启用下拉刷新(YES)
@property (nonatomic, assign) IBInspectable BOOL enableLoadMore;//是否启用上拉加载更多(YES)
@property (nonatomic, assign) IBInspectable BOOL enableTips;//当列表为空时，是否显示tipsView(YES)
@property (nonatomic, strong) IBInspectable NSString *prefixOfUrl;//接口地址前缀(kResPathBaseUrl)
@property (nonatomic, strong) IBInspectable NSString *tipsMessageWhenEmpty;//内容为空时提示文本()
@property (nonatomic, strong) IBInspectable NSString *tipsSuccessIcon;//
@property (nonatomic, strong) IBInspectable NSString *tipsFailedIcon;//
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorLeft;
@property (nonatomic, assign) IBInspectable CGFloat cellSeperatorRight;
@property (nonatomic, copy) YSCViewSetBlock layoutCellBlock; //由子类重写
@property (nonatomic, copy) YSCBlock reloadBlock;//由子类重写
@property (nonatomic, copy) YSCArraySetBlock preProcessBlock;
@property (nonatomic, copy) YSCArrayResultBlock reloadByAddingBlock;
@property (nonatomic, copy) YSCArrayResultBlock reloadByReplacingBlock;
@property (nonatomic, copy) YSCObjectIndexPathResultBlock clickCellBlock;


#pragma mark - 可选设置的属性

//兼容下拉刷新和上拉加载更多
- (void)downloadAtIndex:(NSInteger)pageIndex;


@end
