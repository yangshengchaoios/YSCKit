//
//  BasePullToRefreshView.m
//  YSCKit
//
//  Created by yangshengchao on 15/1/4.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "YSCBasePullToRefreshView.h"

#define TagStartOfContentView   256
#define KeyOfCachedData         @"KeyOfCachedData"

@interface YSCBasePullToRefreshView() <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation YSCBasePullToRefreshView

//////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    NSLog(@"[%@] deallocing...", NSStringFromClass(self.class));
}

//手动实例化view的初始化方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

//xib中实例化view的初始化方法
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

/*
 当你调用 -setNeedsDisplay，UIKit 将会在这个视图的图层上调用 -setNeedsDisplay。这为图层设置了一个标识，标记为 dirty(直译是脏的意思，想不出用什么词比较贴切,污染？)，但还显示原来的内容。它实际上没做任何工作，所以多次调用 -setNeedsDisplay 并不会造成性能损失。
 我的理解：就是设置一个参数dirty = YES;
 */
- (void)setNeedsDisplay {
    [super setNeedsDisplay];
}

- (void)initSubviews {
    self.segmentedTitleArray = [NSMutableArray array];
    self.contentDataArray = [NSMutableArray array];
    self.contentViewArray = [NSMutableArray array];
    self.contentPageIndexArray = [NSMutableArray array];
    self.currentIndex = 0;
    
    self.contentViewSpace = 0;
    self.isUseSegmentedControl = NO;
    self.segmentedHeight = 44;
    self.segmentedLeading = 10;
    self.segmentedTailing = 10;
    
    [self initBlocks];
}


//////////////////////////////////////////////////////////////////////////////////////////
- (void)setNeedsLayout {
    [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
}

//////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
}

- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
}



//-------------------可供外部调用的方法---------------------------------------------------
#pragma mark - 可供外部调用的方法

//在设置完必要的属性后，必须调用该方法进行子view的初始化
- (void)layoutView {
    //1. 创建segmentedControl
    //条件：1> 启用参数
    //     2> 外部没有自定义
    //     3> 数据源大余1个
    if (self.isUseSegmentedControl && (nil == self.segmentedControl)) {
        [self initSegmentedControl];
    }
    
    //2. 创建scrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    //添加约束
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    if (self.segmentedControl) {
        [self.scrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.segmentedBottomLineView];
    }
    else {
        [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    }
    
    //3. 创建contentView
    [self initContentViews];
}

//触发下拉刷新
- (void)beginRefreshing {
    [self beginRefreshingAtIndex:self.currentIndex];
}
- (void)beginRefreshingAtIndex:(NSInteger)index {
    UIScrollView *contentView = [self contentViewAtIndex:index];
    if (nil != contentView) {
        [contentView headerBeginRefreshing];
    }
}

//触发上拉加载更多
- (void)beginLoadingMore {
    [self beginRefreshingAtIndex:self.currentIndex];
}
- (void)beginLoadingMoreAtIndex:(NSInteger)index {
    UIScrollView *contentView = [self contentViewAtIndex:index];
    if (nil != contentView) {
        [contentView footerBeginRefreshing];
    }
}

//网络访问下拉刷新
- (void)refreshData {
    [self refreshDataAtIndex:self.currentIndex];
}
- (void)refreshDataAtIndex:(NSInteger)index {
    [self downloadPageData:kDefaultPageStartIndex atIndex:index];
}

//网络访问上拉加载更多
- (void)loadMoreData {
    [self loadMoreDataAtIndex:self.currentIndex];
}
- (void)loadMoreDataAtIndex:(NSInteger)index {
    if (index >= 0 && index < [self.contentPageIndexArray count]) {
        NSInteger currentPageIndex = [self.contentPageIndexArray[index] integerValue];
        [self downloadPageData:(currentPageIndex + 1) atIndex:index];
    }
}

//刷新界面显示
- (void)reloadData {
    [self reloadDataAtIndex:self.currentIndex];
}
- (void)reloadDataAtIndex:(NSInteger)index {
    UIScrollView *contentView = [self contentViewAtIndex:index];
    if (nil != contentView) {
        if ([contentView isKindOfClass:[UITableView class]]) {
            [((UITableView *)contentView) reloadData];
        }
        else if ([contentView isKindOfClass:[UICollectionView class]]) {
            [((UICollectionView *)contentView) reloadData];
        }
    }
}

//获取数据
- (NSMutableArray *)dataArray {
    return [self dataArrayAtIndex:self.currentIndex];
}
- (NSMutableArray *)dataArrayAtIndex:(NSInteger)index {
    if (index < 0 || index >= [self.contentDataArray count]) {
        return nil;
    }
    else {
        NSMutableArray *tempArray = self.contentDataArray[index];
        if ([tempArray isKindOfClass:[NSMutableArray class]]) {
            return tempArray;
        }
        else {
            return nil;
        }
    }
}

//获取scrollView
- (UIScrollView *)contentView {
    return [self contentViewAtIndex:self.currentIndex];
}
- (UIScrollView *)contentViewAtIndex:(NSInteger)index {
    if (index >= 0 && index < [self.contentViewArray count]) {
        UIScrollView *contentView = self.contentViewArray[index];
        if ([contentView isKindOfClass:[UIScrollView class]]) {
            return contentView;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}


//-------------------私有方法---------------------------------------------------
#pragma mark - 私有方法
//设置初始化的block(在子类里可以改变初始化设置)
- (void)initBlocks {
    WeakSelfType blockSelf = self;
    self.contentViewTypeAtIndex = ^ContentViewType (NSInteger index) {
        return ContentViewTypeTableView;
    };
    self.preProcessDataAtIndex = ^NSArray *(NSArray *array, NSInteger index) {
        return array;
    };
    self.shouldCacheDataAtIndex = ^BOOL (NSInteger index) {
        return NO;
    };
    self.refreshEnableAtIndex = ^BOOL (NSInteger index) {
        return YES;
    };
    self.refreshEnableWhenEnteredAtIndex = ^BOOL (NSInteger index) {
        return YES;
    };
    self.loadMoreEnableAtIndex = ^BOOL (NSInteger index) {
        return YES;
    };
    self.scrollEnableAtIndex = ^BOOL (NSInteger index) {
        return YES;
    };
    self.cellCountAtIndex = ^NSInteger (NSInteger index) {
        NSArray *array = [blockSelf dataArrayAtIndex:index];
        if ([NSArray isNotEmpty:array]) {
            return (NSInteger)[array count];
        }
        else {
            return 0;
        }
    };
    self.prefixOfUrlAtIndex = ^NSString *(NSInteger index) {
        return kResPathAppBaseUrl;
    };
    self.hintStringAtIndex = ^NSString *(NSInteger index) {
        return @"返回数据为空";
    };
    self.layoutCell = ^UIView *(id data, NSIndexPath *indexPath, NSInteger index) {
        UIScrollView *contentView = [blockSelf contentViewAtIndex:index];
        if (nil != contentView) {
            contentView.scrollsToTop = NO;
            if ([contentView isKindOfClass:[UITableView class]]) {
                YSCBaseTableViewCell *cell = [(UITableView *)contentView dequeueReusableCellWithIdentifier:kCellIdentifier];
                if ([cell isKindOfClass:[YSCBaseTableViewCell class]]) {
                    [cell layoutDataModel:data];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;//去掉cell的选中状态
                return cell;
            }
            else if ([contentView isKindOfClass:[UICollectionView class]]) {
                YSCBaseCollectionViewCell *cell = [(UICollectionView *)contentView dequeueReusableCellWithReuseIdentifier:kItemCellIdentifier forIndexPath:indexPath];
                if ([cell isKindOfClass:[YSCBaseCollectionViewCell class]]) {
                    [cell layoutDataModel:data];
                }
                return cell;
            }
            else {
                return nil;
            }
        }
        else {
            return nil;
        }
    };
    self.requestTypeAtIndex = ^RequestType (NSInteger index) {
        return RequestTypeGET;
    };
    self.contentViewContentInsetAtIndex = ^UIEdgeInsets (NSInteger index) {
        return UIEdgeInsetsZero;
    };
    
    //UITableViewCell特有的
    self.tableViewCellHeightAtIndex = ^CGFloat (id data, NSIndexPath *indexPath, NSInteger index) {
        NSString *nibName = @"";
        if (blockSelf.nibNameOfCellAtIndex) {
            nibName = blockSelf.nibNameOfCellAtIndex(index);
        }
        if ([NSString isNotEmpty:nibName] &&
            [NSClassFromString(nibName) isSubclassOfClass:[YSCBaseTableViewCell class]]) {
            return [NSClassFromString(nibName) HeightOfCell];
        }
        else {
            return 44.0f;
        }
    };
    self.tableViewSeperatorColorAtIndex = ^UIColor *(NSInteger index) {
        return RGB(213, 213, 213);
    };
    self.tableViewSeperatorEdgeInsetAtIndex = ^UIEdgeInsets (NSInteger index) {
        return UIEdgeInsetsZero;
    };
    self.tableViewSeperatorTypeAtIndex = ^UITableViewSeperatorType (NSInteger index) {
        return UITableViewSeperatorTypeEdge;
    };
    
    //UICollectionView特有的
    self.itemSizeAtIndex = ^CGSize (NSInteger index) {
        NSString *nibName = @"";
        if (blockSelf.nibNameOfCellAtIndex) {
            nibName = blockSelf.nibNameOfCellAtIndex(index);
        }
        if ([NSString isNotEmpty:nibName] &&
            [NSClassFromString(nibName) isSubclassOfClass:[YSCBaseCollectionViewCell class]]) {
            return [NSClassFromString(nibName) SizeOfCell];
        }
        else {
            return CGSizeZero;
        }
    };
    self.itemEdgeInsetsAtIndex = ^UIEdgeInsets (NSInteger index) {
        return AUTOLAYOUT_EDGEINSETS(20, 20, 0, 20);//NOTE:这里设置bottom没有任何作用！
    };
    self.minimumRowSpacingForSectionAtIndex = ^CGFloat (NSInteger section, NSInteger index) {
        return AUTOLAYOUT_LENGTH(20);
    };
    self.minimumColumnSpacingForSectionAtIndex = ^CGFloat (NSInteger section, NSInteger index) {
        return 0;
    };
}
//初始化segmentedControl
- (void)initSegmentedControl {
    //0. 添加segmentedControl的背景view
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundView];
    [backgroundView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.segmentedLeading];
    [backgroundView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [backgroundView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:self.segmentedTailing];
    [backgroundView autoSetDimension:ALDimensionHeight toSize:self.segmentedHeight];
    //设置item之间的间隔线
    for (int i = 0; i < [self.segmentedTitleArray count] - 1; i++) {
        //TODO:
    }
    
    //1. 新建segementedControl
    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectZero];
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    [self addSubview:self.segmentedControl];
    
    //2. 添加约束
    [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:self.segmentedLeading];
    [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:self.segmentedTailing];
    [self.segmentedControl autoSetDimension:ALDimensionHeight toSize:self.segmentedHeight];
    
    //3. 设置基本属性
    if (nil == self.segmentedTitleArray) {
        self.segmentedTitleArray = [NSMutableArray array];
    }
    WeakSelfType blockSelf = self;
    self.segmentedControl.textColor = kDefaultTextColor;
    self.segmentedControl.selectedTextColor = kDefaultTextColor;
    self.segmentedControl.selectionIndicatorColor = [UIColor redColor];
    self.segmentedControl.font = AUTOLAYOUT_FONT(28);
    self.segmentedControl.sectionTitles = self.segmentedTitleArray;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorHeight = 2;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger pageIndex) {
        if (pageIndex == blockSelf.currentIndex) {
            return ;
        }
        blockSelf.currentIndex = pageIndex;
        CGFloat pageWidth = blockSelf.scrollView.width + blockSelf.contentViewSpace;
        [blockSelf.scrollView setContentOffset:CGPointMake(pageIndex * pageWidth, 0) animated:NO];
        
        //判断是否触发下拉刷新
        if ([NSArray isEmpty:[blockSelf dataArray]]) {
            [blockSelf beginRefreshing];
        }
        else {
            BOOL refreshEnableWhenEntered = YES;
            if (blockSelf.refreshEnableWhenEnteredAtIndex) {
                refreshEnableWhenEntered = blockSelf.refreshEnableWhenEnteredAtIndex(pageIndex);
            }
            if (refreshEnableWhenEntered) {
                [blockSelf beginRefreshing];
            }
        }
    }];
    
    //4. 设置底部间隔线
    self.segmentedBottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.segmentedBottomLineView.backgroundColor = RGB(170, 170, 170);
    [self addSubview:self.segmentedBottomLineView];
    [self bringSubviewToFront:self.segmentedControl];
    [self.segmentedBottomLineView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.segmentedBottomLineView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.segmentedControl withOffset:0];
    [self.segmentedBottomLineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.segmentedBottomLineView autoSetDimension:ALDimensionHeight toSize:AUTOLAYOUT_LENGTH(1)];
}
//初始化contentViews
- (void)initContentViews {
    if ([NSString isEmpty:self.viewControllerClassName]) {
        self.viewControllerClassName = NSStringFromClass([UIView currentViewController].class);
    }
    NSAssert(self.viewControllerClassName, @"can not find view's viewcontroller!");
    WeakSelfType blockSelf = self;
    if (nil == self.contentViewArray) {
        self.contentViewArray = [NSMutableArray array];
    }
    else {
        [self.contentViewArray removeAllObjects];
    }
    self.scrollView.scrollsToTop = NO;
    [self.scrollView removeAllSubviews];
    for (int i = 0; i < MAX(1, [self.segmentedTitleArray count]); i++) {
        ContentViewType type = self.contentViewTypeAtIndex(i);
        UIView *contentView = nil;
        NSString *nibName = @"";
        if (self.nibNameOfCellAtIndex) {
            nibName = self.nibNameOfCellAtIndex(i);
        }
        //1. 创建contentView
        if (ContentViewTypeTableView == type) {
            contentView = [[UITableView alloc] initWithFrame:CGRectZero];
            ((UITableView *)contentView).dataSource = self;
            ((UITableView *)contentView).delegate = self;
            ((UITableView *)contentView).tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
            ((UITableView *)contentView).tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
            if ([NSString isNotEmpty:nibName]) {
                [(UITableView *)contentView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
            }
            
            //获取seperator相关参数
            UITableViewSeperatorType seperatoryType = UITableViewSeperatorTypeEdge;
            if (self.tableViewSeperatorTypeAtIndex) {
                seperatoryType = self.tableViewSeperatorTypeAtIndex(i);
            }
            
            //设置分割线
            if (UITableViewSeperatorTypeCustom == seperatoryType) {
                ((UITableView *)contentView).separatorStyle = UITableViewCellSeparatorStyleNone;
            }
            else if (UITableViewSeperatorTypeEdge == seperatoryType) {
                ((UITableView *)contentView).separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                //颜色
                UIColor *color = RGB(213, 213, 213);
                if (self.tableViewSeperatorColorAtIndex) {
                    color = self.tableViewSeperatorColorAtIndex(i);
                }
                ((UITableView *)contentView).separatorColor = color;
                //设置seperatorInset
                UIEdgeInsets edgeInset = UIEdgeInsetsZero;
                if (self.tableViewSeperatorEdgeInsetAtIndex) {
                    edgeInset = self.tableViewSeperatorEdgeInsetAtIndex(i);
                }
                if ([(UITableView *)contentView respondsToSelector:@selector(setSeparatorInset:)]) {
                    [(UITableView *)contentView setSeparatorInset:edgeInset];
                }
                if ([(UITableView *)contentView respondsToSelector:@selector(setLayoutMargins:)]) {
                    [(UITableView *)contentView setLayoutMargins:edgeInset];
                }
            }
        }
        else if (ContentViewTypeCollectionView == type) {
            UICollectionViewLayout *layout = [UICollectionViewFlowLayout new];
            contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            ((UICollectionView *)contentView).dataSource = self;
            ((UICollectionView *)contentView).delegate = self;
            ((UICollectionView *)contentView).alwaysBounceVertical = YES;
            ((UICollectionView *)contentView).showsHorizontalScrollIndicator = YES;
            ((UICollectionView *)contentView).showsVerticalScrollIndicator = YES;
            if ([NSString isNotEmpty:nibName]) {
                [(UICollectionView *)contentView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:kItemCellIdentifier];
            }
        }
        else if (ContentViewTypeScrollView == type) {
            contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
            ((UIScrollView *)contentView).delegate = self;
        }
        else {
            contentView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        
        //2. 设置contentView
        if ([contentView isKindOfClass:[UIScrollView class]]) {
            if (self.contentViewContentInsetAtIndex) {
                ((UIScrollView *)contentView).contentInset = self.contentViewContentInsetAtIndex(i);
            }
        }
        contentView.backgroundColor = [UIColor clearColor];
        contentView.tag = TagStartOfContentView + i;
        [self.contentViewArray addObject:contentView];
        [self.scrollView addSubview:contentView];
        
        //3. 添加约束
        [contentView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [contentView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [contentView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView];
        [contentView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.scrollView];
        if (0 == i) {//第一个的leading要基于self.scrollView
            [contentView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        }
        else {
            [contentView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.contentViewArray[i - 1] withOffset:self.contentViewSpace];
        }
        if ([self.segmentedTitleArray count] - 1 == i) {//最后一个的trailing要基于self.scrollView
            [contentView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        }
        
        //4. 下拉刷新&上拉加载更多
        if ([contentView isKindOfClass:[UIScrollView class]]) {
            BOOL refreshEnable = YES;
            BOOL refreshEnableWhenEntered = YES;
            BOOL loadMoreEnable = YES;
            BOOL scrollEnable = YES;
            if (self.refreshEnableAtIndex) {
                refreshEnable = self.refreshEnableAtIndex(i);
            }
            if (self.refreshEnableWhenEnteredAtIndex) {
                refreshEnableWhenEntered = self.refreshEnableWhenEnteredAtIndex(i);
            }
            if (self.loadMoreEnableAtIndex) {
                loadMoreEnable = self.loadMoreEnableAtIndex(i);
            }
            if (self.scrollEnableAtIndex) {
                scrollEnable = self.scrollEnableAtIndex(i);
            }
            
            if (refreshEnable) {
                [(UIScrollView *)contentView addHeaderWithCallback:^{
                    [blockSelf refreshDataAtIndex:i];
                }];
                if (refreshEnableWhenEntered) {
                    [(UIScrollView *)contentView headerBeginRefreshing];
                }
            }
            if (loadMoreEnable) {
                [(UIScrollView *)contentView addFooterWithCallback:^{
                    [blockSelf loadMoreDataAtIndex:i];
                }];
            }
            ((UIScrollView *)contentView).scrollEnabled = scrollEnable;
        }
        
        //5. 初始化页码数组和数据源数组
        [self.contentPageIndexArray addObject:@(kDefaultPageStartIndex)];
        [self.contentDataArray addObject:[NSMutableArray array]];
        
        //6. 加载缓存数据
        BOOL shouldCacheData = NO;
        if (self.shouldCacheDataAtIndex) {
            shouldCacheData = self.shouldCacheDataAtIndex(i);
        }
        if (shouldCacheData) {
            NSArray *cacheArray = [self cachedObjectForKey:KeyOfCachedData atIndex:i];
            if ([cacheArray isKindOfClass:[NSArray class]] && [NSArray isNotEmpty:cacheArray]) {
                [[self dataArrayAtIndex:i] addObjectsFromArray:cacheArray];
            }
        }
    }
}
//下载一页的数据(兼容下拉刷新和上拉加载更多)
- (void)downloadPageData:(NSInteger)pageIndex atIndex:(NSInteger)index {
    WeakSelfType blockSelf = self;
    //1. 定义网络返回成功的回调
    RequestSuccessed requestSuccessedBlock = ^(id responseObject) {
        [blockSelf hideHUDLoading];
        BOOL isPullToRefresh = (kDefaultPageStartIndex == pageIndex); //是否下拉刷新
        if (isPullToRefresh) {
            [[blockSelf contentViewAtIndex:index] headerEndRefreshing];
        }
        else {
            [[blockSelf contentViewAtIndex:index] footerEndRefreshing];
        }
        
        //1. 获取结果数组
        NSArray *dataArray = nil;
        if ([responseObject isKindOfClass:[NSArray class]]) {
            dataArray = (NSArray *)responseObject;
        }
        else if([responseObject isKindOfClass:[BaseDataModel class]]){
            dataArray = @[responseObject];
        }
        
        //2. 根据组装后的数组刷新列表
        NSArray *newDataArray = nil;
        if ([dataArray count] > 0) {
            blockSelf.contentPageIndexArray[index] = @(pageIndex);  //只要接口成功返回了数据，就把当前请求的页码保存起来
            if (blockSelf.preProcessDataAtIndex) {
                newDataArray = blockSelf.preProcessDataAtIndex(dataArray, index);
            }
        }
        
        //3. 根据新数组刷新界面显示
        if (isPullToRefresh) {//处理下拉刷新
            if ([newDataArray count] > 0) {
                [blockSelf reloadByReplacing:newDataArray atIndex:index];
            }
            else {//假如经过处理后的数组为空，则需要清空之前的数据
                NSArray *tempArray = [blockSelf dataArrayAtIndex:index];
                if ([tempArray isMemberOfClass:[NSMutableArray class]]) {
                    [(NSMutableArray *)tempArray removeAllObjects];
                }
            }
            [blockSelf reloadDataAtIndex:index];
        }
        else {//处理加载更多
            if ([newDataArray count] > 0) {
                [blockSelf reloadByAdding:newDataArray atIndex:index];
            }
            else {
                [blockSelf showResultThenHide:@"没有更多了"];
            }
        }
        
        //4. 判断是否设置了回调
        if (blockSelf.successedAtIndex) {
            blockSelf.successedAtIndex(index);
        }
    };
    
    //2. 定义网络返回失败的回调
    RequestFailure requestFailureBlock = ^(NSInteger errorCode, NSString *errorMessage) {
        [blockSelf showResultThenHide:errorMessage];
        if (kDefaultPageStartIndex == pageIndex) {
            [[blockSelf contentViewAtIndex:index] headerEndRefreshing];
        }
        else {
            [[blockSelf contentViewAtIndex:index] footerEndRefreshing];
        }
        if (blockSelf.failedAtIndex) {
            blockSelf.failedAtIndex(index);
        }
    };
    
    //3. 获取网络访问的参数
    RequestType requestType = RequestTypeGET;
    if (blockSelf.requestTypeAtIndex) {
        requestType = blockSelf.requestTypeAtIndex(index);
    }
    NSString *prefixOfUrl = kResPathAppBaseUrl;
    if (blockSelf.prefixOfUrlAtIndex) {
        prefixOfUrl = blockSelf.prefixOfUrlAtIndex(index);
    }
    NSString *methodName = @"";
    if (blockSelf.methodNameAtIndex) {
        methodName = blockSelf.methodNameAtIndex(index);
    }
    NSDictionary *dictParam = nil;
    if (blockSelf.dictParamAtIndex) {
        dictParam = blockSelf.dictParamAtIndex(pageIndex, index);
    }
    Class modelClass = nil;
    if (blockSelf.modelClassAtIndex) {
        modelClass = blockSelf.modelClassAtIndex(index);
    }
    
    //4. 开始网络访问
    if(RequestTypeGET == requestType){
        [AFNManager getDataFromUrl:prefixOfUrl
                           withAPI:methodName
                      andDictParam:dictParam
                         modelName:modelClass
                  requestSuccessed:requestSuccessedBlock
                    requestFailure:requestFailureBlock];
    }else if(RequestTypePOST == requestType){
        [AFNManager postDataToUrl:prefixOfUrl
                          withAPI:methodName
                     andDictParam:dictParam
                        modelName:modelClass
                 requestSuccessed:requestSuccessedBlock
                   requestFailure:requestFailureBlock];
    }
}
//刷新界面
- (void)reloadByReplacing:(NSArray *)array atIndex:(NSInteger)index {
    NSMutableArray *currentDataArray = [self dataArrayAtIndex:index];
    [currentDataArray removeAllObjects];
    [currentDataArray addObjectsFromArray:array];
    
    BOOL shouldCacheData = NO;
    if (self.shouldCacheDataAtIndex) {
        shouldCacheData = self.shouldCacheDataAtIndex(index);
    }
    if (shouldCacheData) {
        [self saveObject:array forKey:KeyOfCachedData atIndex:index];
    }
}
//加载更多
- (void)reloadByAdding:(NSArray *)array atIndex:(NSInteger)index {
    UIScrollView *contentView = [self contentViewAtIndex:index];
    NSMutableArray *currentDataArray = [self dataArrayAtIndex:index];
    NSInteger oldCount = [currentDataArray count];
    [currentDataArray addObjectsFromArray:array];
    
    if ([contentView isKindOfClass:[UITableView class]]) {
        [UIView insertTableViewCell:(UITableView *)contentView oldCount:oldCount addCount:[array count]];
    }
    else if ([contentView isKindOfClass:[UICollectionView class]]) {
        [UIView insertCollectionViewCell:(UICollectionView *)contentView oldCount:oldCount addCount:[array count]];
    }
}
//获取缓存数组
- (NSArray *)cachedObjectForKey:(NSString *)cachedKey atIndex:(NSInteger)index {
    NSString *fileName = [NSString stringWithFormat:@"%@_%ld.dat", self.viewControllerClassName, index];
    NSString *filePath = [[[StorageManager sharedInstance] directoryPathOfLibraryCachesCommon] stringByAppendingPathComponent:fileName];
    NSDictionary *cacheInfo = [[StorageManager sharedInstance] unarchiveDictionaryFromFilePath:filePath];
    if ([cacheInfo objectForKey:cachedKey]) {
        return cacheInfo[cachedKey];
    }
    else {
        return nil;
    }
}
//缓存数组
- (void)saveObject:(NSArray *)object forKey:(NSString *)cachedKey atIndex:(NSInteger)index {
    ReturnWhenObjectIsEmpty(object);
    ReturnWhenObjectIsEmpty(cachedKey);
    
    @try {
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld.dat", self.viewControllerClassName, index];
        NSString *filePath = [[[StorageManager sharedInstance] directoryPathOfLibraryCachesCommon] stringByAppendingPathComponent:fileName];
        BOOL isSuccess = [[StorageManager sharedInstance] archiveDictionary:@{cachedKey : object}
                                                                 toFilePath:filePath
                                                                  overwrite:NO];
        if (isSuccess) {
            NSLog(@"缓存成功！");
        }
        else {
            NSLog(@"缓存失败！");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"将数组保存至本地缓存时出错！%@",
              exception); //可能是没有在对象里做序列号和反序列化！
    }
    @finally
    {
    }
}


//-------------------------------------------------------------------------------------------
//
//  UITableView相关回调方法
//
//-------------------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger index = tableView.tag - TagStartOfContentView;
    return 1;//TODO:
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger index = tableView.tag - TagStartOfContentView;
    if (self.cellCountAtIndex) {
        return self.cellCountAtIndex(index);
    }
    else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = tableView.tag - TagStartOfContentView;
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = self.dataArray[indexPath.row];
    }
    
    UITableViewCell *cell = nil;
    if (self.layoutCell) {
        cell = (UITableViewCell *)self.layoutCell(objectModel, indexPath, index);
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = tableView.tag - TagStartOfContentView;
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = self.dataArray[indexPath.row];
    }
    
    CGFloat rowHeight = 0;
    if (self.tableViewCellHeightAtIndex) {
        rowHeight = self.tableViewCellHeightAtIndex(objectModel, indexPath, index);
    }
    return rowHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = tableView.tag - TagStartOfContentView;
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = self.dataArray[indexPath.row];
    }
    
    if (self.clickCell) {
        self.clickCell(objectModel, indexPath, index);
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = tableView.tag - TagStartOfContentView;
    UITableViewSeperatorType seperatoryType = UITableViewSeperatorTypeEdge;
    if (self.tableViewSeperatorTypeAtIndex) {
        seperatoryType = self.tableViewSeperatorTypeAtIndex(index);
    }
    if (UITableViewSeperatorTypeEdge != seperatoryType) {
        return;//如果不是启用tableview本身的seperator的话就直接返回
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
        if (self.tableViewSeperatorEdgeInsetAtIndex) {
            edgeInset = self.tableViewSeperatorEdgeInsetAtIndex(index);
        }
        [cell setLayoutMargins:edgeInset];
    }
}


//-------------------------------------------------------------------------------------------
//
//  UICollectionView相关回调方法
//
//-------------------------------------------------------------------------------------------
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    return 1;//TODO:
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    if (self.cellCountAtIndex) {
        return self.cellCountAtIndex(index);
    }
    else {
        return 0;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = self.dataArray[indexPath.row];
    }
    
    UICollectionViewCell *cell = nil;
    if (self.layoutCell) {
        cell = (UICollectionViewCell *)self.layoutCell(objectModel, indexPath, index);
    }
    return cell;
}

#pragma mark - UICollectionFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    if (self.itemSizeAtIndex) {
        return self.itemSizeAtIndex(index);
    }
    else {
        return CGSizeZero;
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    if (self.itemEdgeInsetsAtIndex) {
        return self.itemEdgeInsetsAtIndex(index);
    }
    else {
        return UIEdgeInsetsZero;
    }
}
//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    if (self.minimumRowSpacingForSectionAtIndex) {
        return self.minimumRowSpacingForSectionAtIndex(section, index);
    }
    else {
        return 0;
    }
}
//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    if (self.minimumColumnSpacingForSectionAtIndex) {
        return self.minimumColumnSpacingForSectionAtIndex(section, index);
    }
    else {
        return 0;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = collectionView.tag - TagStartOfContentView;
    id objectModel = nil;
    if (indexPath.row < [self.dataArray count]) {
        objectModel = self.dataArray[indexPath.row];
    }
    
    if (self.clickCell) {
        self.clickCell(objectModel, indexPath, index);
    }
}


//-------------------------------------------------------------------------------------------
//
//  UIScrollView相关回调方法
//
//-------------------------------------------------------------------------------------------
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didWhenScrollViewEnded:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self didWhenScrollViewEnded:scrollView];
}
- (void)didWhenScrollViewEnded:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {//屏蔽contentView回调该方法
        return;
    }
    CGFloat pageWidth = scrollView.width + self.contentViewSpace;
    int pageIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.contentViewSpace > 0) {
        [scrollView setContentOffset:CGPointMake(pageIndex * pageWidth, 0) animated:NO];
    }
    [self.segmentedControl setSelectedSegmentIndex:pageIndex animated:YES];
    if (self.segmentedControl.indexChangeBlock) {
        self.segmentedControl.indexChangeBlock(pageIndex);
    }
}

@end
