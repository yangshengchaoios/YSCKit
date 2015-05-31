//
//  BasePullToRefreshView.h
//  YSCKit
//
//  Created by yangshengchao on 15/1/4.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "HMSegmentedControl.h"
#import "MJRefresh.h"

typedef NS_ENUM(NSInteger, ContentViewType) {
    ContentViewTypeTableView = 0,       //默认
    ContentViewTypeCollectionView,
    ContentViewTypeScrollView,
    ContentViewTypeWebView
};

typedef NS_ENUM(NSInteger, UITableViewSeperatorType) {
    UITableViewSeperatorTypeEdge = 0,   //默认
    UITableViewSeperatorTypeCustom      //cell里自定义(即不用tableView本身的分割线)
};

//-------------------定义block类型-----------------------------------------------------

#pragma mark - 必须自定义的block
typedef NSString *(^MethodNameAtIndex)(NSInteger index);                 //接口方法
typedef NSDictionary *(^DictParamAtIndex)(NSInteger page, NSInteger index);     //请求参数封装
typedef Class (^ModelClassAtIndex)(NSInteger index);                     //默认BaseDataModel
typedef NSString *(^NibNameOfCellAtIndex)(NSInteger index);              //自定义的cell布局文件


#pragma mark - 已经有默认定义的block
typedef ContentViewType (^ContentViewTypeAtIndex)(NSInteger index);      //返回每个segment页面的类型
typedef NSArray *(^PreProcessDataAtIndex)(NSArray *array, NSInteger index);     //对网络返回数据进行预处理
typedef BOOL (^ShouldCacheDataAtIndex)(NSInteger index);                 //是否缓存当前页面的数据(默认NO)
typedef BOOL (^RefreshEnableAtIndex)(NSInteger index);                   //是否启用下拉刷新(默认YES)
typedef BOOL (^RefreshEnableWhenEnteredAtIndex)(NSInteger index);        //是否在第一次进入界面就触发下拉刷新(以后进入界面就根据当前页面的数据是否为空来判断是否触发下拉刷新，默认YES)
typedef BOOL (^LoadMoreEnableAtIndex)(NSInteger index);                  //是否启用加载更多(默认YES)
typedef BOOL (^ScrollEnableAtIndex)(NSInteger index);                    //是否启用加载更多(默认YES)
typedef NSInteger (^CellCountAtIndex)(NSInteger index);                  //控制显示条目
typedef NSString *(^PrefixOfUrlAtIndex)(NSInteger index);                //接口前缀(默认是业务接口前缀kResPathAppBaseUrl)
typedef NSString *(^HintStringAtIndex)(NSInteger index);                 //没有数据时的提示文本(当返回nil时，表示不显示TipsView)
typedef UIView *(^LayoutCell)(id data, NSIndexPath *indexPath, NSInteger index); //根据数据来布局界面
typedef RequestType (^RequestTypeAtIndex)(NSInteger index);              //
typedef UIEdgeInsets (^ContentViewContentInsetAtIndex)(NSInteger index); //contentView.contentInset

//UITableView特有
typedef CGFloat (^TableViewCellHeightAtIndex)(id data, NSIndexPath *indexPath, NSInteger index);
typedef UIColor *(^TableViewSeperatorColorAtIndex)(NSInteger index);
typedef UITableViewSeperatorType (^TableViewSeperatorTypeAtIndex)(NSInteger index);
typedef UIEdgeInsets (^TableViewSeperatorEdgeInsetAtIndex)(NSInteger index);
//UICollectionView特有
typedef CGSize (^ItemSizeAtIndex)(NSInteger index);
typedef UIEdgeInsets (^ItemEdgeInsetsAtIndex)(NSInteger index);
typedef CGFloat (^MinimumRowSpacingForSectionAtIndex)(NSInteger section, NSInteger index);//cell的最小行间距
typedef CGFloat (^MinimumColumnSpacingForSectionAtIndex)(NSInteger section, NSInteger index);//cell的最小列间距

#pragma mark - 可选设置的block
typedef void(^PullToRefreshSuccessedAtIndex)(NSInteger index);                  //接口返回成功的回调
typedef void(^PullToRefreshFailedAtIndex)(NSInteger index);                     //接口返回失败的回调
typedef void (^ClickCell)(id data, NSIndexPath *indexPath, NSInteger index);    //点击某个cell



/*************************************************************************************
 *
 *  兼容多数据源、多类型 下拉刷新和上拉加载更多
 *  TODO:暂时只支持UITableView、UICollectionView、UIScrollView
 *       未添加UMeng事件统计埋点
 *
 ************************************************************************************/
@interface YSCBasePullToRefreshView : UIView

//-------------------必要的属性---------------------------------------------------------
#pragma mark - 必要的属性
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentedBottomLineView;              //segmentedControl底部间隔线
@property (nonatomic, strong) NSArray *segmentedTitleArray;                 //用于控制contentView的个数
@property (nonatomic, strong) NSMutableArray *contentDataArray;             //二维数组
@property (nonatomic, strong) NSMutableArray *contentViewArray;             //contentView数组
@property (nonatomic, strong) NSMutableArray *contentPageIndexArray;        //分页的页码
@property (nonatomic, assign) NSInteger currentIndex;                       //当前的contentView位置

#pragma mark - 必须要设置的属性
@property (nonatomic, copy) MethodNameAtIndex methodNameAtIndex;
@property (nonatomic, copy) DictParamAtIndex dictParamAtIndex;
@property (nonatomic, copy) ModelClassAtIndex modelClassAtIndex;
@property (nonatomic, copy) NibNameOfCellAtIndex nibNameOfCellAtIndex;

#pragma mark - 已有默认定义的属性
@property (nonatomic, strong) NSString *viewControllerClassName;            //当前view所在的viewcontroller(用于缓存数据)
@property (nonatomic, assign) CGFloat contentViewSpace;                     //contentView之间的间隔(默认0)
@property (nonatomic, assign) BOOL isUseSegmentedControl;                   //是否启用segmentedControl(默认NO)
@property (nonatomic, assign) CGFloat segmentedHeight;                      //设置segmentedControlView的高度(默认44)
@property (nonatomic, assign) CGFloat segmentedLeading;                     //默认10
@property (nonatomic, assign) CGFloat segmentedTailing;                     //默认10
@property (nonatomic, copy) ContentViewTypeAtIndex contentViewTypeAtIndex;  //默认ContentViewTypeTableView
@property (nonatomic, copy) PreProcessDataAtIndex preProcessDataAtIndex;                  //默认不处理
@property (nonatomic, copy) ShouldCacheDataAtIndex shouldCacheDataAtIndex;  //默认NO
@property (nonatomic, copy) RefreshEnableAtIndex refreshEnableAtIndex;      //默认YES
@property (nonatomic, copy) RefreshEnableWhenEnteredAtIndex refreshEnableWhenEnteredAtIndex;//默认YES
@property (nonatomic, copy) LoadMoreEnableAtIndex loadMoreEnableAtIndex;    //默认YES
@property (nonatomic, copy) ScrollEnableAtIndex scrollEnableAtIndex;        //默认YES
@property (nonatomic, copy) CellCountAtIndex cellCountAtIndex;              //默认dataArray[i].count
@property (nonatomic, copy) PrefixOfUrlAtIndex prefixOfUrlAtIndex;          //默认kResPathAppBaseUrl
@property (nonatomic, copy) HintStringAtIndex hintStringAtIndex;            //默认提示信息"暂时没有内容"
@property (nonatomic, copy) LayoutCell layoutCell;                          //默认调用layoutDataModel:方法
@property (nonatomic, copy) RequestTypeAtIndex requestTypeAtIndex;          //默认RequestTypeGET
@property (nonatomic, copy) ContentViewContentInsetAtIndex contentViewContentInsetAtIndex;//默认UIEdgeZero
//UITableView特有
@property (nonatomic, copy) TableViewCellHeightAtIndex tableViewCellHeightAtIndex;
@property (nonatomic, copy) TableViewSeperatorColorAtIndex tableViewSeperatorColorAtIndex;  //默认 RGB(213, 213, 213)
@property (nonatomic, copy) TableViewSeperatorEdgeInsetAtIndex tableViewSeperatorEdgeInsetAtIndex;
@property (nonatomic, copy) TableViewSeperatorTypeAtIndex tableViewSeperatorTypeAtIndex;
//UICollectionView特有
@property (nonatomic, copy) ItemSizeAtIndex itemSizeAtIndex;
@property (nonatomic, copy) ItemEdgeInsetsAtIndex itemEdgeInsetsAtIndex;
@property (nonatomic, copy) MinimumRowSpacingForSectionAtIndex minimumRowSpacingForSectionAtIndex;
@property (nonatomic, copy) MinimumColumnSpacingForSectionAtIndex minimumColumnSpacingForSectionAtIndex;

#pragma mark - 可选设置的属性(即默认为nil)
@property (nonatomic, copy) PullToRefreshSuccessedAtIndex successedAtIndex;
@property (nonatomic, copy) PullToRefreshFailedAtIndex failedAtIndex;
@property (nonatomic, copy) ClickCell clickCell;


//-------------------可供外部调用的方法---------------------------------------------------

//在设置完必要的属性后，必须调用该方法进行子view的初始化
- (void)layoutView;

//触发下拉刷新
- (void)beginRefreshing;
- (void)beginRefreshingAtIndex:(NSInteger)index;

//触发上拉加载更多
- (void)beginLoadingMore;
- (void)beginLoadingMoreAtIndex:(NSInteger)index;

//网络访问下拉刷新
- (void)refreshData;
- (void)refreshDataAtIndex:(NSInteger)index;

//网络访问上拉加载更多
- (void)loadMoreData;
- (void)loadMoreDataAtIndex:(NSInteger)index;

//刷新界面显示
- (void)reloadData;
- (void)reloadDataAtIndex:(NSInteger)index;

//获取数据
- (NSMutableArray *)dataArray;
- (NSMutableArray *)dataArrayAtIndex:(NSInteger)index;

//获取contentView
- (UIScrollView *)contentView;
- (UIScrollView *)contentViewAtIndex:(NSInteger)index;

//设置初始化的block(在子类里可以改变初始化设置)
- (void)initBlocks;

@end
