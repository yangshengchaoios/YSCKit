//
//  YSCPullToRefreshHelper.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCPullToRefreshHelper.h"
#import "YSCTipsView.h"
#import "YSCRequestManager.h"
#import "MJRefresh.h"

@implementation YSCPullToRefreshHelper
- (void)dealloc {
    PRINT_DEALLOCING
}
- (id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}
- (void)_setup {
    self.sectionKeyArray = [NSMutableArray array];
    //基本属性
    self.sectionDataArray = [NSMutableArray array];
    self.cellDataArray = [NSMutableArray array];
    self.currentPageIndex = YSCConfigManagerInstance.defaultPageStartIndex - 1;
    self.tipsTimeoutIcon = YSCConfigManagerInstance.defaultTimeoutImageName;
    self.tipsFailedIcon = YSCConfigManagerInstance.defaultErrorImageName;
    self.tipsEmptyIcon = YSCConfigManagerInstance.defaultEmptyImageName;
    self.tipsEmptyText = YSCConfigManagerInstance.defaultEmptyMessage;
    
    //只要该block不能为nil！
    self.preProcessBlock = ^NSArray *(NSArray *array) {
        return array;
    };
}

#pragma mark - 属性设置
- (void)setEnableRefresh:(BOOL)enableRefresh {
    _enableRefresh = enableRefresh;
    if (enableRefresh) {
        @weakiy(self);
        self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weak_self _callCustomRefreshBlock:YSCConfigManagerInstance.defaultPageStartIndex];
        }];
    }
    else {
        self.scrollView.mj_header  = nil;
    }
}
- (void)setEnableLoadMore:(BOOL)enableLoadMore {
    _enableLoadMore = enableLoadMore;
    if (enableLoadMore) {
        @weakiy(self);
        self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weak_self _callCustomRefreshBlock:weak_self.currentPageIndex + 1];
        }];
    }
    else {
        self.scrollView.mj_footer = nil;
    }
}
- (void)setEnableTips:(BOOL)enableTips {
    _enableTips = enableTips;
    if (enableTips) {
        @weakiy(self);
        if ( ! self.tipsView) {
            self.tipsView = [YSCTipsView createYSCTipsViewOnView:self.scrollView
                                                    buttonAction:^{
                                                        [weak_self.scrollView.mj_header beginRefreshing];
                                                    }];
        }
        self.tipsView.hidden = YES;
    }
    else {
        if (self.tipsView) {
            [self.tipsView removeFromSuperview];
            self.tipsView = nil;
        }
    }
}

#pragma mark - 外部调用方法
// 是否正在加载数据
- (BOOL)isLoading {
    return self.scrollView.mj_header.isRefreshing || self.scrollView.mj_footer.isRefreshing;
}
// 启动刷新(能加载一次缓存)
- (void)beginRefreshing {
    [self beginRefreshingByAnimation:YES];
}
- (void)beginRefreshingByAnimation:(BOOL)animation {
    [self _reloadData];
    if (animation && self.enableRefresh) {
        [self.scrollView.mj_header beginRefreshing];
    }
    else {
        [self _callCustomRefreshBlock:YSCConfigManagerInstance.defaultPageStartIndex];
    }
}
/** 对接数据源 */
- (void)_callCustomRefreshBlock:(NSInteger)pageIndex {
    if (self.startLoadingBlock) {
        self.startLoadingBlock();
    }
    if (self.customRefreshBlock) {
        self.customRefreshBlock(pageIndex);
    }
}
- (void)endRefreshing {
    if (self.scrollView.mj_header.isRefreshing) {
        [self.scrollView.mj_header endRefreshing];
    }
    if (self.scrollView.mj_footer.isRefreshing) {
        [self.scrollView.mj_footer endRefreshing];
    }
}
// 显示数据
- (void)layoutObjectAtFirstPage:(NSObject *)object errorMessage:(NSString *)errorMessage {
    [self layoutObject:object atPageIndex:YSCConfigManagerInstance.defaultPageStartIndex errorMessage:errorMessage];
}
- (void)layoutObject:(NSObject *)object atPageIndex:(NSInteger)pageIndex errorMessage:(NSString *)errorMessage {
    @weakiy(self);
    errorMessage = TRIM_STRING(errorMessage);
    BOOL isPullToRefresh = (YSCConfigManagerInstance.defaultPageStartIndex == pageIndex); //是否下拉刷新
    [weak_self endRefreshing];
    if ([errorMessage length] > 0) {
        if (self.tipsView) {
            [self.tipsView resetMessage:errorMessage];
            if ([YSCConfigManagerInstance.networkErrorTimeout isEqualToString:errorMessage]) {
                [self.tipsView resetImageName:self.tipsTimeoutIcon];
            }
            else if ([YSCConfigManagerInstance.networkErrorReturnEmptyData isEqualToString:errorMessage]) {
                [self.tipsView resetImageName:self.tipsEmptyIcon];
            }
            else {
                [self.tipsView resetImageName:self.tipsFailedIcon];
            }
            [self.tipsView resetActionWithButtonTitle:self.tipsButtonTitle buttonAction:^{
                [weak_self beginRefreshing];
            }];
        }
    }
    else {
        //1. 根据组装后的数组刷新列表
        NSArray *newDataArray = nil;
        if (OBJECT_ISNOT_EMPTY(object)) {
            self.currentPageIndex = pageIndex;  //只要接口成功返回了数据，就把当前请求的页码保存起来
            if (self.preProcessBlock) {
                newDataArray = self.preProcessBlock((NSArray *)object);
            }
        }
        
        //-----------开始对tableView进行操作-----------
        if (isPullToRefresh) {
            [self.sectionKeyArray removeAllObjects];
            [self.sectionDataArray removeAllObjects];
            [self.cellDataArray removeAllObjects];
        }
        
        //3. 根据新数组刷新界面显示(包括下拉刷新、上拉加载更多、并且支持多section)
        if ([newDataArray count] > 0) {
            NSMutableArray *insertedIndexPaths = [NSMutableArray array];
            NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
            // 3.1 遍历数据源
            for (NSObject *object in newDataArray) {
                NSInteger row = 0, section = 0;
                NSString *sectionKey = @"";//NOTE:兼容object是数组的情况
                SEL selector = NSSelectorFromString(@"sectionKey");
                if ([object respondsToSelector:selector]) {
                    IMP imp = [object methodForSelector:selector];
                    sectionKey = ((NSString * (*)(id, SEL))imp)(object, selector);
                }
                if ( ! sectionKey) {
                    sectionKey = @"";
                }
                
                if ([self.sectionKeyArray containsObject:sectionKey]) {
                    section = [self.sectionKeyArray indexOfObject:sectionKey];
                    NSMutableArray *tempArray = self.cellDataArray[section];
                    [tempArray addObject:object];
                    row = [tempArray count] - 1;
                }
                else {
                    row = 0;
                    section = [self.sectionKeyArray count];
                    [self.sectionKeyArray addObject:sectionKey];
                    
                    //处理section header model(直接保存原始的model，在具体显示的时候再确定显示哪个属性)
                    [self.sectionDataArray addObject:object];
                    
                    NSMutableArray *tempArray = [NSMutableArray array];
                    [tempArray addObject:object];
                    [self.cellDataArray addObject:tempArray];
                    
                    //add new section
                    if (( ! isPullToRefresh) && OBJECT_ISNOT_EMPTY(sectionKey)) {
                        [insertedSections addIndex:section];
                    }
                }
                //add new row
                if ( ! isPullToRefresh) {
                    [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                }
            }
            
            // 3.2 更新列表
            if (isPullToRefresh) {
                [self _reloadData];
            }
            else {
                if (self.loadMoreBlock) {
                    self.loadMoreBlock(insertedSections, insertedIndexPaths);
                }
            }
        }
        else {
            if (isPullToRefresh) {
                [self _reloadData];//防止旧数据得不到清除
            }
            else {
                [YSCHUD showHUDThenHideOnKeyWindowWithMessage:YSCConfigManagerInstance.defaultNoMoreMessage];
            }
        }
        
        //4. 数据为空的tips
        if (self.tipsView) {
            self.tipsView.actionButton.hidden = YES;
            [self.tipsView resetMessage:self.tipsEmptyText];
            [self.tipsView resetImageName:self.tipsEmptyIcon];
        }
    }
    
    self.tipsView.hidden = ( ! [self isCellDataEmpty]);
    if (self.tipsView.hidden && [errorMessage length] > 0) {
        // cellData不为空时如果有错误信息也要提示
        [YSCHUD showHUDThenHideOnKeyWindowWithMessage:errorMessage];
    }
    if (self.finishLoadingBlock) {
        self.finishLoadingBlock(errorMessage);
    }
}

//当数据为空时执行下拉刷新
- (void)beginRefreshingWhenCellDataIsEmpty {
    if ([self isCellDataEmpty]) {
        [self beginRefreshing];
    }
}
//清空列表并刷新界面
- (void)clearDataAndRefreshView {
    [self.sectionKeyArray removeAllObjects];
    [self.sectionDataArray removeAllObjects];
    [self.cellDataArray removeAllObjects];
    if (self.enableTips && self.tipsView.hidden) {
        self.tipsView.hidden = NO;
    }
    [self _reloadData];
}
- (BOOL)isCellDataEmpty {
    if (OBJECT_IS_EMPTY(self.cellDataArray)) {
        return YES;
    }
    //如果有空数组
    for (NSArray *array in self.cellDataArray) {
        if (OBJECT_ISNOT_EMPTY(array)) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)isLastCellByIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self.cellDataArray count] - 1) {
        NSArray *array = self.cellDataArray[indexPath.section];
        if (indexPath.row == [array count] - 1) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}
- (BOOL)isLastSectionByIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == [self.sectionDataArray count] - 1;
}
- (NSObject *)getObjectByIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= 0 && indexPath.section >= [self.cellDataArray count]) {
        return nil;
    }
    NSArray *array = self.cellDataArray[indexPath.section];
    if (indexPath.row >= 0 && indexPath.row >= [array count]) {
        return nil;
    }
    return array[indexPath.row];
}
- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < [self.cellDataArray count]) {
        NSMutableArray *array = self.cellDataArray[indexPath.section];
        if (indexPath.row < [array count]) {
            [array removeObjectAtIndex:indexPath.row];
            if (self.deleteCellBlock) {
                self.deleteCellBlock(indexPath);
            }
            if ([array count] == 0) {
                [self.cellDataArray removeObjectAtIndex:indexPath.section];
                [self.sectionKeyArray removeObjectAtIndex:indexPath.section];
                [self.sectionDataArray removeObjectAtIndex:indexPath.section];
            }
            
            // 显示数据为空的提示信息
            if ([self isCellDataEmpty] && self.tipsView) {
                self.tipsView.hidden = NO;
                self.tipsView.actionButton.hidden = YES;
                [self.tipsView resetMessage:self.tipsEmptyText];
                [self.tipsView resetImageName:self.tipsEmptyIcon];
            }
        }
    }
}
- (NSIndexPath *)indexPathByObject:(NSObject *)object {
    NSIndexPath *indexPath = nil;
    for (int i = 0; i < [self.cellDataArray count]; i++) {
        NSArray *array = self.cellDataArray[i];
        for (int j = 0; j < [array count]; j++) {
            NSObject *tempObject = array[j];
            if ([tempObject isEqual:object]) {
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                break;
            }
        }
    }
    return indexPath;
}

// 刷新界面
- (void)_reloadData {
    if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
        [self.scrollView performSelector:@selector(reloadData)];
    }
}
@end
