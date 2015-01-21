//
//  BasePullToRefreshView.m
//  HYTCosmetic
//
//  Created by yangshengchao on 15/1/4.
//  Copyright (c) 2015年 ZhongDaYunKe. All rights reserved.
//

#import "BasePullToRefreshView.h"

@interface BasePullToRefreshView() <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation BasePullToRefreshView

//////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    NSLog(@"[%@] deallocing...", NSStringFromClass(self.class));
}

//手动实例化view的初始化方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame，%@", NSStringFromCGRect(self.frame));
        [self initSbuviews];
    }
    return self;
}

//xib中实例化view的初始化方法
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initWithCoder，%@", NSStringFromCGRect(self.frame));
        [self initSbuviews];
    }
    return self;
}

/*
 当你调用 -setNeedsDisplay，UIKit 将会在这个视图的图层上调用 -setNeedsDisplay。这为图层设置了一个标识，标记为 dirty(直译是脏的意思，想不出用什么词比较贴切,污染？)，但还显示原来的内容。它实际上没做任何工作，所以多次调用 -setNeedsDisplay 并不会造成性能损失。
 我的理解：就是设置一个参数dirty = YES;
 */
- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    NSLog(@"setNeedsDisplay，%@", NSStringFromCGRect(self.frame));
}

- (void)initSbuviews {
    NSLog(@"initSubviews，%@", NSStringFromCGRect(self.frame));
    self.contentDataArray = [NSMutableArray array];
    self.contentViewArray = [NSMutableArray array];
    self.contentPageIndexArray = [NSMutableArray array];
    self.currentIndex = 0;
    self.totalSegmentedCount = 1;
    self.isUseSegmentedControl = NO;
    
    [self initBlocks];
    
    
    
    //TODO:添加约束
}


//////////////////////////////////////////////////////////////////////////////////////////
- (void)setNeedsLayout {
    [super setNeedsLayout];
    NSLog(@"setNeedsLayout，%@", NSStringFromCGRect(self.frame));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews，%@", NSStringFromCGRect(self.frame));
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect:%@，frame=%@", NSStringFromCGRect(rect), NSStringFromCGRect(self.frame));
}

//////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    NSLog(@"layoutIfNeeded，%@", NSStringFromCGRect(self.frame));
}


- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    NSLog(@"setNeedsUpdateConstraints，%@", NSStringFromCGRect(self.frame));
}



//-------------------可供外部调用的方法---------------------------------------------------
#pragma mark - 可供外部调用的方法

- (void)layoutView {
    //1. 创建segmentedControlView
    //条件：1> 启用参数
    //     2> 外部没有自定义
    //     3> 数据源大余1个
    if (self.isUseSegmentedControl &&
        (nil == self.segmentedControlView) &&
        (self.totalSegmentedCount > 1)) {
        self.segmentedControlView = [[HMSegmentedControl alloc] initWithFrame:CGRectZero];
        self.segmentedControlView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.segmentedControlView];
        //添加约束
        [self.segmentedControlView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.segmentedControlView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.segmentedControlView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.scrollView];
    //添加约束
    
    
    for (int i = 0; i < self.totalSegmentedCount; i++) {
        ContentViewType type = self.contentViewTypeAtIndex(i);
        UIScrollView *scrollView = nil;
        if (ContentViewTypeTableView == type) {
            
        }
        else if (ContentViewTypeCollectionView == type) {
        
        }
        else if (ContentViewTypeScrollView == type) {
        
        }
        if (scrollView) {
            //添加约束
        }
    }
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
    NSInteger currentPageIndex = [self.contentPageIndexArray[index] integerValue];
    [self downloadPageData:currentPageIndex + 1 atIndex:index];
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
- (NSArray *)dataArray {
    return [self dataArrayAtIndex:self.currentIndex];
}
- (NSArray *)dataArrayAtIndex:(NSInteger)index {
    if (index < 0 || index >= [self.dataArray count]) {
        return nil;
    }
    else {
        NSArray *tempArray = self.dataArray[index];
        if ([tempArray isKindOfClass:[NSArray class]] && [NSArray isNotEmpty:tempArray]) {
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
        return nil;
    };
    self.layoutCell = ^UIView *(id data, NSIndexPath *indexPath, NSInteger index) {
        UIScrollView *contentView = [blockSelf contentViewAtIndex:index];
        if (nil != contentView) {
            if ([contentView isKindOfClass:[UITableView class]]) {
                BaseTableViewCell *cell = [(UITableView *)contentView dequeueReusableCellWithIdentifier:kCellIdentifier];
                if ([cell isKindOfClass:[BaseTableViewCell class]]) {
                    [cell layoutDataModel:data];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;//去掉cell的选中状态
                return cell;
            }
            else if ([contentView isKindOfClass:[UICollectionView class]]) {
                BaseCollectionViewCell *cell = [(UICollectionView *)contentView dequeueReusableCellWithReuseIdentifier:kItemCellIdentifier forIndexPath:indexPath];
                if ([cell isKindOfClass:[BaseCollectionViewCell class]]) {
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
}

//下载一页的数据(兼容下拉刷新和上拉加载更多)
- (void)downloadPageData:(NSInteger)pageIndex atIndex:(NSInteger)index {
    WeakSelfType blockSelf = self;
    //1. 定义网络返回成功的回调
    RequestSuccessed requestSuccessedBlock = ^(id responseObject){
        //        [blockSelf.contentScrollView headerEndRefreshing];
        [blockSelf hideHUDLoading];
        blockSelf.contentPageIndexArray[index] = @(kDefaultPageStartIndex);
        
        //1. 获取结果数组
        NSArray *dataArray = nil;
        if ([responseObject isKindOfClass:[NSArray class]]) {
            dataArray = (NSArray *)responseObject;
        }
        else if([responseObject isKindOfClass:[BaseDataModel class]]){
            dataArray = @[responseObject];
        }
        //------------
        
        //2. 根据组装后的数组刷新列表
        NSArray *newDataArray = nil;
        if ([dataArray count] > 0 && blockSelf.preProcessDataAtIndex) {
            newDataArray = blockSelf.preProcessDataAtIndex(dataArray, index);
        }
        if ([newDataArray count] > 0) {
            //            [blockSelf reloadByReplacing:newDataArray];
        }
        else {//清空已有的数据
            NSMutableArray *tempArray = blockSelf.contentDataArray[index];
            if ([tempArray isMemberOfClass:[NSMutableArray class]]) {
                [tempArray removeAllObjects];
            }
        }
        //------------
        
        if (blockSelf.successedAtIndex) {
            blockSelf.successedAtIndex(index);
        }
        [blockSelf reloadData];
    };
    
    //2. 定义网络返回失败的回调
    RequestFailure requestFailureBlock = ^(NSInteger errorCode, NSString *errorMessage){
        //        [blockSelf.contentScrollView headerEndRefreshing];
        [blockSelf showResultThenHide:errorMessage];
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
        dictParam = blockSelf.dictParamAtIndex(kDefaultPageStartIndex, index);
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

@end
