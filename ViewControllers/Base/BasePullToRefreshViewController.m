//
//  BasePullToRefreshViewController.m
//  TGO2
//
//  Created by  YangShengchao on 14-4-18.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "BasePullToRefreshViewController.h"

@interface BasePullToRefreshViewController ()

@property (nonatomic, assign) NSInteger currentPageIndex;   //分页的页码指针
@property (nonatomic, assign) BOOL isTipsViewHidden;        //设置没有数据的提示view是否隐藏

@end

@implementation BasePullToRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageIndex = 1;                  //分页从1开始
    if (self.dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }
    
    //加载本地缓存
    if ([self shouldCacheArray]) {
        NSArray *cacheArray = [self loadCacheArray];
        if ([NSObject isNotEmpty:cacheArray]) {
            [self.dataArray addObjectsFromArray:cacheArray];
        }
    }
    
    //判断是否需要刷新功能
    if ([self refreshEnable]) {
		[self addRefreshHeaderView];
		//判断是否进入的时候就刷新
		if ([self shouldRefreshWhenEntered]) {
			[self.contentScrollView headerBeginRefreshing];
		}
	}
    
	//判断是否需要加载更多功能
	if ([self loadMoreEnable]) {
		[self addRefreshFooterView];
	}
}

- (void)addRefreshHeaderView {
	WeakSelfType blockSelf = self;
    [self.contentScrollView addHeaderWithCallback:^{
        [blockSelf refreshWithSuccessed:blockSelf.successBlock failed:blockSelf.failedBlock];
    }];
}

- (void)addRefreshFooterView {
	WeakSelfType blockSelf = self;
    [self.contentScrollView addHeaderWithCallback:^{
        [blockSelf loadMoreWithSuccessed:blockSelf.successBlock failed:blockSelf.failedBlock];
    }];
}

/**
 *  设置没有数据的提示view是显示还是隐藏
 *
 *  @param isTipsViewHidden
 */
- (void)setIsTipsViewHidden:(BOOL)isTipsViewHidden {
    _isTipsViewHidden = isTipsViewHidden;
    
    if (self.tipsView == nil) {
        self.tipsView = [TipsView showTips:[self hintStringWhenNoData]
                                       inView:[self contentScrollView]];
    }
    if (self.tipsView.hidden != isTipsViewHidden) {
        self.tipsView.hidden = isTipsViewHidden;
    }
}

/**
 *  下拉刷新
 *
 *  @param successed
 *  @param failed    
 */
- (void)refreshWithSuccessed:(PullToRefreshSuccessed)successed failed:(PullToRefreshFailed)failed {
	WeakSelfType blockSelf = self;
	[AFNManager getDataFromUrl:[self prefixOfUrl]
                      withAPI:[self methodWithPath]
	            andArrayParam:[self arrayParamWithPage:1]
	             andDictParam:[self dictParamWithPage:1]
	                dataModel:[self modelNameOfData]
	         requestSuccessed: ^(id responseObject) {
                 [blockSelf.contentScrollView headerEndRefreshing];
                 [blockSelf hideHUDLoading];
                 blockSelf.currentPageIndex = 1;
                 
                 //1. 获取结果数组
                 NSArray *dataArray = nil;
                 if ([responseObject isKindOfClass:[NSArray class]]) {
                     dataArray = (NSArray *)responseObject;
                 }
                 //------------
                 
                 //2. 根据组装后的数组刷新列表
                 NSArray *newDataArray = nil;
                 if ([dataArray count] > 0) {
                     newDataArray = [blockSelf preProcessData:dataArray];
                 }
                 blockSelf.isTipsViewHidden = ([newDataArray count] > 0);
                 if ([newDataArray count] > 0) {
                     [blockSelf reloadByReplacing:newDataArray];
                 }
                 else {
                     //清空已有的数据
                     [blockSelf.dataArray removeAllObjects];
                 }
                 //------------
                 
                 if (successed) {
                     successed();
                 }
                 [blockSelf reloadData];
             }
     
	           requestFailure: ^(NSInteger errorCode, NSString *errorMessage) {
                   [blockSelf.contentScrollView headerEndRefreshing];
                   [blockSelf showAlertVieWithMessage:errorMessage];
                   blockSelf.isTipsViewHidden = ([blockSelf.dataArray count] > 0);//判断总的数组是否为空
                   
                   if (failed) {
                       failed();
                   }
               }];
}

- (void)reloadByReplacing:(NSArray *)anArray {
	[self.dataArray removeAllObjects];
	[self.dataArray addObjectsFromArray:anArray];
    
	//保存数组至本地缓存（注意：只保存下拉刷新的数组！）
	if ([self shouldCacheArray]) {
		[self saveObject:anArray forKey:KeyOfCachedArray];
	}
}

/**
 *  上拉加载更多
 *
 *  @param successed
 *  @param failed
 */
- (void)loadMoreWithSuccessed:(PullToRefreshSuccessed)successed failed:(PullToRefreshFailed)failed {
	WeakSelfType blockSelf = self;
	[AFNManager getDataFromUrl:[self prefixOfUrl]
                      withAPI:[self methodWithPath]
	            andArrayParam:[self arrayParamWithPage:self.currentPageIndex + 1]
	             andDictParam:[self dictParamWithPage:self.currentPageIndex + 1]
	                dataModel:[self modelNameOfData]
	         requestSuccessed: ^(id responseObject) {
                 [blockSelf.contentScrollView footerEndRefreshing];
                 [blockSelf hideHUDLoading];
                 
                 //1. 获取结果数组
                 NSArray *dataArray = nil;
                 if ([responseObject isKindOfClass:[NSArray class]]) {
                     dataArray = (NSArray *)responseObject;
                 }
                 //------------
                 
                 //2. 根据组装后的数组刷新列表
                 NSArray *newDataArray = nil;
                 if ([dataArray count] > 0) {
                     blockSelf.currentPageIndex++;//只要返回有数据就自增
                     newDataArray = [blockSelf preProcessData:dataArray];
                 }
                 if ([newDataArray count] > 0) {
                     blockSelf.isTipsViewHidden = YES;
                     [blockSelf reloadByAdding:newDataArray];
                 }
                 else {
                     if ([blockSelf.dataArray count] == 0) {//判断总的数组是否为空
                         blockSelf.isTipsViewHidden = NO;
                     }
                     [blockSelf showResultThenHide:@"没有更多了"];
                 }
                 //------------
                 
                 if (successed) {
                     successed();
                 }
             }
	           requestFailure: ^(NSInteger errorCode,NSString *errorMessage) {
                   [blockSelf.contentScrollView footerEndRefreshing];
                   [blockSelf showResultThenHide:errorMessage];
                   blockSelf.isTipsViewHidden = ([blockSelf.dataArray count] > 0);//判断总的数组是否为空
                   
                   if (failed) {
                       failed();
                   }
               }];
}

- (void)reloadByAdding:(NSArray *)anArray {
	
}

#pragma mark - 可选的重写方法

//下拉刷新特有的缓存加载方法被基类的loadCache方法调用
- (NSArray *)loadCacheArray {
	NSArray *cachedArray = [self cachedObjectForKey:KeyOfCachedArray];
	if ([cachedArray isKindOfClass:[NSArray class]] && [NSArray isNotEmpty:cachedArray]) {
		return cachedArray;
	}
	else { //没有缓存内容
		return nil;
	}
}

- (NSArray *)preProcessData:(NSArray *)anArray {
	return anArray;
}

- (BOOL)shouldCacheArray {
	return NO;
}

- (BOOL)shouldRefreshWhenEntered {
	return YES;
}
- (BOOL)loadMoreEnable {
	return YES;
}

- (BOOL)refreshEnable {
	return YES;
}

- (NSInteger)cellCount {
	return [self.dataArray count];
}

- (NSString *)prefixOfUrl {
    return kResPathAppBaseUrl;
}

- (NSString *)hintStringWhenNoData {
    return @"暂时没有内容";
}

#pragma mark - 必须重写的方法

- (NSString *)methodWithPath {
	return @"";
}

- (NSString *)nibNameOfCell {
	return @"";
}

- (NSArray *)arrayParamWithPage:(NSInteger)page {
	return @[];
}

- (NSDictionary *)dictParamWithPage:(NSInteger)page {
	return @{};
}

- (NSString *)modelNameOfData {
	return @"CommonBaseModel";
}

- (UIView *)layoutCellWithData:(id)object atIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)clickedCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - 必须在一级子类里重写的方法

/**
 *  目前只支持UItableView和UICollectionView
 */
- (UIScrollView *)contentScrollView {
    return nil;
}
- (void)reloadData {

}

@end
