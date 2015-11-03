//
//  YSCTableView.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCTableView.h"
#import "MJRefresh.h"

#define KeyOfHeaderData         @"KeyOfHeaderData"
#define KeyOfCellData           @"KeyOfCellData"
#define KeyOfFooterData         @"KeyOfFooterData"
#define KeyOfSectionKey         @"KeyOfSectionKey"

@interface YSCTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *sectionKeyArray;//用于存储分组的判断依据
@property (nonatomic, assign) BOOL isLoadedCache;//控制缓存只加载一次

@property (nonatomic, assign) BOOL enableCache;//是否启用缓存(NO)
@property (nonatomic, strong) NSString *cacheFileName;//缓存数据保存的文件名称
@end

@implementation YSCTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

//初始化配置参数
- (void)setup {
    //基本属性
    self.sectionKeyArray = [NSMutableArray array];
    self.headerDataArray = [NSMutableArray array];
    self.footerDataArray = [NSMutableArray array];
    self.cellDataArray = [NSMutableArray array];
    self.currentPageIndex = kDefaultPageStartIndex;
    self.requestType = RequestTypeGET;
    
    //必要的属性
    self.dictParamBlock = ^NSDictionary *(NSInteger pageIndex) {
        return @{kParamPageIndex : @(pageIndex),
                 kParamPageSize : @(kDefaultPageSize)};
    };
    
    //设置默认属性
    self.prefixOfUrl = kResPathAppBaseUrl;
    self.tipsEmptyText = kDefaultTipsEmptyText;
    self.tipsEmptyIcon = kDefaultTipsEmptyIcon;
    self.tipsFailedIcon = kDefaultTipsFailedIcon;
    self.tipsButtonTitle = kDefaultTipsButtonTitle;
    
    self.enableCache = NO;
    self.enableRefresh = YES;
    self.enableLoadMore = YES;
    self.enableTips = YES;
    
    //blocks
    self.successBlock = ^{};
    self.failedBlock = ^{};
    self.preProcessBlock = ^NSArray *(NSArray *array) {
        return array;
    };
    self.clickHeaderBlock = ^(NSObject *object, NSInteger section) {};
    self.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {};
    self.deleteCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {};
    self.clickFooterBlock = ^(NSObject *object, NSInteger section) {};
    self.layoutHeaderView = ^(UIView *view, NSObject *object) {};
    self.layoutCellView = ^(UIView *view, NSObject *object) {};
    self.layoutFooterView = ^(UIView *view, NSObject *object) {};
    
    [self initTableView];//初始化tableView
}
- (void)initTableView {
    //1. 注册cell、header、footer
    if (isNotEmpty(self.cellName)) {
        [NSClassFromString(self.cellName) registerCellToTableView:self];
    }
    if (isNotEmpty(self.headerName)) {
        [NSClassFromString(self.headerName) registerHeaderFooterToTableView:self];
    }
    if (isNotEmpty(self.footerName)) {
        [NSClassFromString(self.footerName) registerHeaderFooterToTableView:self];
    }
    
    //2. 设置cell的分割线
    [self resetCellEdgeInsets];
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = kDefaultBorderColor;//NOTE:xib < this
    
    //3. 设置其他参数
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.dataSource = self;
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - 属性设置
- (void)setCellName:(NSString *)cellName {
    _cellName = cellName;
    if (isNotEmpty(cellName)) {
        [NSClassFromString(self.cellName) registerCellToTableView:self];
    }
}
- (void)setHeaderName:(NSString *)headerName {
    _headerName = headerName;
    if (isNotEmpty(headerName)) {
        [NSClassFromString(self.headerName) registerHeaderFooterToTableView:self];
    }
}
- (void)setFooterName:(NSString *)footerName {
    _footerName = footerName;
    if (isNotEmpty(footerName)) {
        [NSClassFromString(self.footerName) registerHeaderFooterToTableView:self];
    }
}
- (void)setCellSeperatorLeft:(CGFloat)cellSeperatorLeft {
    _cellSeperatorLeft = AUTOLAYOUT_LENGTH(cellSeperatorLeft);
    [self resetCellEdgeInsets];
}
- (void)setCellSeperatorRight:(CGFloat)cellSeperatorRight {
    _cellSeperatorRight = AUTOLAYOUT_LENGTH(cellSeperatorRight);
    [self resetCellEdgeInsets];
}
- (void)setEnableRefresh:(BOOL)enableRefresh {
    _enableRefresh = enableRefresh;
    if (enableRefresh) {
        WEAKSELF
        self.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf refreshAtPageIndex:kDefaultPageStartIndex];
        }];
    }
    else {
        self.header  = nil;
    }
}
- (void)setEnableLoadMore:(BOOL)enableLoadMore {
    _enableLoadMore = enableLoadMore;
    if (enableLoadMore) {
        WEAKSELF
        self.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf refreshAtPageIndex:weakSelf.currentPageIndex + 1];
        }];
    }
    else {
        self.footer = nil;
    }
}
- (void)setEnableTips:(BOOL)enableTips {
    _enableTips = enableTips;
    if (enableTips && isEmpty(self.tipsView)) {
        WEAKSELF
        self.tipsView = [YSCKTipsView CreateYSCTipsViewOnView:self
                                                   edgeInsets:UIEdgeInsetsZero//TODO:
                                                  withMessage:self.tipsEmptyText
                                                    iconImage:[UIImage imageNamed:self.tipsEmptyIcon]
                                                  buttonTitle:self.tipsButtonTitle
                                                 buttonAction:^{
                                                     [weakSelf.header beginRefreshing];
                                                 }];
        self.tipsView.hidden = YES;
    }
    else {
        if (self.tipsView) {
            [self.tipsView removeFromSuperview];
            self.tipsView = nil;
        }
    }
}


#pragma mark - 外部可调用的方法
//创建对象，不用xib布局时使用
+ (instancetype)CreateYSCTableViewOnView:(UIView *)view {
    YSCTableView *tableView = [[YSCTableView alloc] initWithFrame:view.bounds];
    [view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top);
        make.left.equalTo(view.mas_left);
        make.bottom.equalTo(view.mas_bottom);
        make.right.equalTo(view.mas_right);
    }];
    return tableView;
}
//启动刷新(能加载一次缓存)
- (void)beginRefreshing {
    [self beginRefreshingByAnimation:YES];
}
- (void)beginRefreshingByAnimation:(BOOL)animation {
    [self loadCacheArray];//加载缓存
    if (animation) {
        [self.header beginRefreshing];
    }
    else {
        [self refreshAtPageIndex:kDefaultPageStartIndex];
    }
}
//当数据为空时执行下拉刷新
- (void)refreshWhenCellDataEmpty {
    if (isEmpty(self.cellDataArray)) {
        [self beginRefreshing];
    }
}

//开启缓存模式
- (void)enableCacheWithFileName:(NSString *)fileName {
    ReturnWhenObjectIsEmpty(fileName)
    self.enableCache = YES;
    self.cacheFileName = fileName;
}

//下载数据(可重写)
- (void)refreshAtPageIndex:(NSInteger)pageIndex {
    [self refreshAtPageIndex:pageIndex response:nil error:nil];
}
- (void)refreshAtPageIndex:(NSInteger)pageIndex response:(NSObject *)responseObject error:(NSString *)errMsg {
    WEAKSELF
    YSCIdResultBlock resultBlock = ^(id responseObject, NSError *error) {
        BOOL isPullToRefresh = (kDefaultPageStartIndex == pageIndex); //是否下拉刷新
        isPullToRefresh ? [weakSelf.header endRefreshing] : [weakSelf.footer endRefreshing];
        //处理返回结果
        if (error) {
            //数据加载失败的tips
            if (weakSelf.tipsView) {
                weakSelf.tipsView.iconImageView.image = [UIImage imageNamed:weakSelf.tipsFailedIcon];
                weakSelf.tipsView.messageLabel.text = error.localizedDescription;
            }
        }
        else {
            //1. 获取结果数组
            NSArray *dataArray = nil;
            if ([responseObject isKindOfClass:[NSArray class]]) {
                dataArray = (NSArray *)responseObject;
            }
            else if([responseObject isKindOfClass:[BaseDataModel class]]) {
                dataArray = @[responseObject];
            }
            
            //2. 根据组装后的数组刷新列表
            NSArray *newDataArray = nil;
            if ([dataArray count] > 0) {
                weakSelf.currentPageIndex = pageIndex;  //只要接口成功返回了数据，就把当前请求的页码保存起来
                if (weakSelf.preProcessBlock) {
                    newDataArray = weakSelf.preProcessBlock(dataArray);
                }
            }
            
            
            //-----------开始对tableView进行操作-----------
            if (isPullToRefresh) {
                [weakSelf.sectionKeyArray removeAllObjects];
                [weakSelf.headerDataArray removeAllObjects];
                [weakSelf.footerDataArray removeAllObjects];
                [weakSelf.cellDataArray removeAllObjects];
            }
            else {
                [weakSelf beginUpdates];
            }
            
            //3. 根据新数组刷新界面显示(包括下拉刷新、上拉加载更多、并且支持多section)
            if ([newDataArray count] > 0) {
                //-----------------多section的刷新--------------
                NSMutableArray *insertedIndexPaths = [NSMutableArray array];
                for (NSObject *object in newDataArray) {
                    NSInteger row = 0, section = 0;
                    NSString *sectionKey = @"";//NOTE:兼容object是数组的情况
                    if ([object isKindOfClass:[BaseDataModel class]]) {
                        sectionKey = Trim(((BaseDataModel *)object).sectionKey);
                    }
                    
                    if ([weakSelf.sectionKeyArray containsObject:Trim(sectionKey)]) {
                        section = [weakSelf.sectionKeyArray indexOfObject:Trim(sectionKey)];
                        NSMutableArray *tempArray = weakSelf.cellDataArray[section];
                        [tempArray addObject:object];
                        row = [tempArray count] - 1;
                    }
                    else {
                        row = 0;
                        section = [weakSelf.sectionKeyArray count];
                        [weakSelf.sectionKeyArray addObject:Trim(sectionKey)];
                        
                        //处理section header model(直接保存原始的model，在具体显示的时候再确定显示哪个属性)
                        [weakSelf.headerDataArray addObject:object];
                        
                        NSMutableArray *tempArray = [NSMutableArray array];
                        [tempArray addObject:object];
                        [weakSelf.cellDataArray addObject:tempArray];
                        
                        if (NO == isPullToRefresh && isNotEmpty(sectionKey)) {//insert section
                            [weakSelf insertSections:[NSIndexSet indexSetWithIndex:section]
                                    withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    //add new row
                    if (NO == isPullToRefresh) {
                        [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                }
                //--------------------------------------------
                
                if (NO == isPullToRefresh) {//insert rows
                    [weakSelf insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            else {
                if (NO == isPullToRefresh) {
                    [UIView showResultThenHideOnWindow:@"没有更多了"];
                }
            }
            
            //---------结束对tableView的操作-----------
            if (isPullToRefresh) {
                [weakSelf reloadData];
            }
            else {
                [weakSelf endUpdates];
            }
            
            
            //4. 数据为空的tips
            if (weakSelf.tipsView) {
                weakSelf.tipsView.iconImageView.image = [UIImage imageNamed:weakSelf.tipsEmptyIcon];
                weakSelf.tipsView.messageLabel.text = weakSelf.tipsEmptyText;
            }
            
            //5. 缓存数据
            if (weakSelf.enableCache && isNotEmpty(weakSelf.cacheFileName)) {
                SaveCacheObjectByFile(weakSelf.sectionKeyArray, KeyOfSectionKey, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.headerDataArray, KeyOfHeaderData, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.cellDataArray, KeyOfCellData, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.footerDataArray, KeyOfFooterData, weakSelf.cacheFileName);
            }
        }
        weakSelf.tipsView.hidden = [NSArray isNotEmpty:weakSelf.cellDataArray];

        //最后回调(可能会处理tipsView的显示与否的问题)
        if (error) {
            if (weakSelf.failedBlock) {
                weakSelf.failedBlock();
            }
        }
        else {
            if (weakSelf.successBlock) {
                weakSelf.successBlock();
            }
        }
    };
    
    //4. 开始网络访问
    if(RequestTypeGET == self.requestType) {
        [AFNManager getDataFromUrl:self.prefixOfUrl
                           withAPI:self.methodName
                      andDictParam:self.dictParamBlock(pageIndex)
                         modelName:NSClassFromString(self.modelName)
                  requestSuccessed:^(id responseObjec) {
                      resultBlock(responseObjec, nil);
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        resultBlock(nil, CreateNSError(errorMessage));
                    }];
    }
    else if(RequestTypePOST == self.requestType) {
        [AFNManager postDataToUrl:self.prefixOfUrl
                          withAPI:self.methodName
                     andDictParam:self.dictParamBlock(pageIndex)
                        modelName:NSClassFromString(self.modelName)
                 requestSuccessed:^(id responseObjec) {
                     resultBlock(responseObjec, nil);
                 }
                   requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                       resultBlock(nil, CreateNSError(errorMessage));
                   }];
    }
    else if (RequestTypeCustomResponse == self.requestType) {
        if (isEmpty(errMsg)) {
            resultBlock(responseObject, nil);
        }
        else {
            resultBlock(responseObject, CreateNSError(errMsg));
        }
    }
}

//判断是否为空
- (BOOL)isCellDataEmpty {
    return [self.cellDataArray count] == 0;
}
//判断cell是否最后一个
- (BOOL)isLastCellByIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self.headerDataArray count] - 1) {
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
//判断section是否最后一个
- (BOOL)isLastSectionByIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == [self.headerDataArray count] - 1;
}

#pragma mark - 私有方法
//加载缓存数组
- (void)loadCacheArray {
    if (self.enableCache && NO == self.isLoadedCache) {
        self.isLoadedCache = YES;//控制缓存只加载一次
        
        [self.sectionKeyArray removeAllObjects];
        NSArray *array = GetCacheObjectByFile(KeyOfSectionKey, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.sectionKeyArray addObjectsFromArray:array];
        }
        
        [self.headerDataArray removeAllObjects];
        array = GetCacheObjectByFile(KeyOfHeaderData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.headerDataArray addObjectsFromArray:array];
        }
        
        [self.cellDataArray removeAllObjects];
        array = GetCacheObjectByFile(KeyOfCellData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.cellDataArray addObjectsFromArray:array];
        }
        
        [self.footerDataArray removeAllObjects];
        array = GetCacheObjectByFile(KeyOfFooterData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.footerDataArray addObjectsFromArray:array];
        }
        [self reloadData];//TODO:test 是否需要reload？
    }
}
- (void)resetCellEdgeInsets {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:edgeInsets];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:edgeInsets];
    }
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellDataArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.cellDataArray[section];
    return [array count];
}
//HEADER
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.headerHeightBlock) {
        return self.headerHeightBlock([NSIndexPath indexPathForRow:0 inSection:section]);
    }
    if (isNotEmpty(self.headerName) && (section >= 0 && section < [self.headerDataArray count])) {
        return [NSClassFromString(self.headerName) HeightOfViewByObject:self.headerDataArray[section]];
    }
    else {
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YSCBaseTableHeaderFooterView *header = nil;
    if (isNotEmpty(self.headerName) && (section >= 0 && section < [self.headerDataArray count])) {
        header = [NSClassFromString(self.headerName) dequeueHeaderFooterByTableView:tableView];
        NSObject *object = self.headerDataArray[section];
        if ([header isKindOfClass:[YSCBaseTableHeaderFooterView class]]) {
            [header layoutObject:object];
        }
        if (self.layoutHeaderView) {
            self.layoutHeaderView(header, object);
        }
        
        WEAKSELF
        [header removeAllGestureRecognizers];
        [header bk_whenTapped:^{
            if (weakSelf.clickHeaderBlock) {
                weakSelf.clickHeaderBlock(weakSelf.headerDataArray[section], section);
            }
        }];
    }
    return header;
}
//CELL
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //1. 屏蔽通用cell的高度
    if (self.cellHeightBlock) {
        return self.cellHeightBlock(indexPath);
    }
    //2. 单个情况下的高度
    NSArray *array = self.cellDataArray[indexPath.section];
    if ([NSClassFromString(self.cellName) isSubclassOfClass:[YSCBaseTableViewCell class]]) {
        return [NSClassFromString(self.cellName) HeightOfCellByObject:array[indexPath.row]];
    }
    else {
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSCBaseTableViewCell *cell = [NSClassFromString(self.cellName) dequeueCellByTableView:tableView];
    NSArray *array = self.cellDataArray[indexPath.section];
    BaseDataModel *object = array[indexPath.row];
    if ([cell isKindOfClass:[YSCBaseTableViewCell class]]) {
        [cell layoutObject:object];
    }
    if (self.layoutCellView) {
        self.layoutCellView(cell, object);
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//FOOTER
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.footerHeightBlock) {
        return self.footerHeightBlock([NSIndexPath indexPathForRow:0 inSection:section]);
    }
    if (isNotEmpty(self.footerName) && (section >= 0 && section < [self.footerDataArray count])) {
        return [NSClassFromString(self.footerName) HeightOfViewByObject:self.footerDataArray[section]];
    }
    else {
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    YSCBaseTableHeaderFooterView *footer = nil;
    if (isNotEmpty(self.footerName) && (section >= 0 && section < [self.footerDataArray count])) {
        footer = [NSClassFromString(self.footerName) dequeueHeaderFooterByTableView:tableView];
        NSObject *object = self.footerDataArray[section];
        if ([footer isKindOfClass:[YSCBaseTableHeaderFooterView class]]) {
            [footer layoutObject:object];
        }
        if (self.layoutFooterView) {
            self.layoutFooterView(footer, object);
        }
        
        WEAKSELF
        [footer removeAllGestureRecognizers];
        [footer bk_whenTapped:^{
            if (weakSelf.clickFooterBlock) {
                weakSelf.clickFooterBlock(weakSelf.footerDataArray[section], section);
            }
        }];
    }
    return footer;
}
//选择cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.cellDataArray[indexPath.section];
    if (self.clickCellBlock) {
        self.clickCellBlock(array[indexPath.row], indexPath);
    }
}
//
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resetCellEdgeInsets];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.deleteCellBlock) {
            NSArray *array = self.cellDataArray[indexPath.section];
            self.deleteCellBlock(array[indexPath.row], indexPath);
        }
    }
}
//NOTE:系统自动多语言返回"删除"
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"删除";
//}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.enableCellEdit;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.willBeginDraggingBlock) {
        self.willBeginDraggingBlock();
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.didEndDraggingBlock) {
        self.didEndDraggingBlock();
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.didScrollBlock) {
        self.didScrollBlock();
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.didEndScrollingAnimationBlock) {
        self.didEndScrollingAnimationBlock();
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.willBeginDeceleratingBlock) {
        self.willBeginDeceleratingBlock();
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.didEndDeceleratingBlock) {
        self.didEndDeceleratingBlock();
    }
}

@end
