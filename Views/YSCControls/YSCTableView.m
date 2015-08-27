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
@end

@implementation YSCTableView

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
    self.methodName = @"";
    self.modelName = @"";
    self.cellName = @"";
    
    //设置默认属性
    self.headerName = @"";
    self.footerName = @"";
    self.enableCache = NO;
    self.enableLoadMore = YES;
    self.enableRefresh = YES;
    self.enableTips = YES;
    self.prefixOfUrl = kResPathAppBaseUrl;
    self.tipsEmptyText = kDefaultTipsEmptyText;
    self.tipsEmptyIcon = kDefaultTipsEmptyIcon;
    self.tipsFailedIcon = kDefaultTipsFailedIcon;
    self.tipsButtonTitle = kDefaultTipsButtonTitle;
    self.cellSeperatorLeft = 0;
    self.cellSeperatorRight = 0;
    
    //blocks
    self.successBlock = ^{};
    self.failedBlock = ^{};
    self.preProcessBlock = ^NSArray *(NSArray *array) {
        return array;
    };
    self.clickHeaderBlock = ^(NSObject *object, NSInteger section) {};
    self.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {};
    self.clickFooterBlock = ^(NSObject *object, NSInteger section) {};
    
    [self loadCacheArray];//加载缓存
    [self initTableView];//初始化tableView
}
- (void)loadCacheArray {
    if (self.enableCache) {
        NSArray *array = GetCacheObjectByFile(KeyOfSectionKey, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.sectionKeyArray addObjectsFromArray:array];
        }
        array = GetCacheObjectByFile(KeyOfHeaderData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.headerDataArray addObjectsFromArray:array];
        }
        array = GetCacheObjectByFile(KeyOfCellData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.cellDataArray addObjectsFromArray:array];
        }
        array = GetCacheObjectByFile(KeyOfFooterData, self.cacheFileName);
        if (isNotEmpty(array)) {
            [self.footerDataArray addObjectsFromArray:array];
        }
    }
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
    self.separatorInset = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    self.layoutMargins = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    //3. 设置其他参数
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.dataSource = self;
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    self.separatorColor = kDefaultBorderColor;//TODO:test on xib
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
    }
    else {
        if (self.tipsView) {
            [self.tipsView removeFromSuperview];
            self.tipsView = nil;
        }
    }
}

//兼容下拉刷新和上拉加载更多
- (void)downloadAtIndex:(NSInteger)pageIndex {
    WEAKSELF
    YSCIdResultBlock resultBlock = ^(id responseObject, NSError *error) {
        BOOL isPullToRefresh = (kDefaultPageStartIndex == pageIndex); //是否下拉刷新
        isPullToRefresh ? [weakSelf.header endRefreshing] : [weakSelf.footer endRefreshing];
        //处理返回结果
        if (error) {
            NSString *errMsg = @"";
            [UIView showAlertVieWithMessage:errMsg];
            
            //数据加载失败的tips
            if (weakSelf.tipsView) {
                weakSelf.tipsView.iconImageView.image = [UIImage imageNamed:weakSelf.tipsFailedIcon];
                weakSelf.tipsView.messageLabel.text = errMsg;
            }
            weakSelf.failedBlock();
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
                newDataArray = weakSelf.preProcessBlock(dataArray);
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
                for (BaseDataModel *model in newDataArray) {
                    NSInteger row = 0, section = 0;
                    
                    if ([weakSelf.sectionKeyArray containsObject:Trim(model.sectionKey)]) {
                        section = [weakSelf.sectionKeyArray indexOfObject:Trim(model.sectionKey)];
                        NSMutableArray *tempArray = weakSelf.cellDataArray[section];
                        [tempArray addObject:model];
                        row = [tempArray count] - 1;
                    }
                    else {
                        row = 0;
                        section = [weakSelf.sectionKeyArray count];
                        [weakSelf.sectionKeyArray addObject:Trim(model.sectionKey)];
                        
                        //处理section header model(直接保存原始的model，在具体显示的时候再确定显示哪个属性)
                        [weakSelf.headerDataArray addObject:model];
                        
                        NSMutableArray *tempArray = [NSMutableArray array];
                        [tempArray addObject:model];
                        [weakSelf.cellDataArray addObject:tempArray];
                        
                        if (NO == isPullToRefresh) {//insert section
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
            weakSelf.successBlock();
            
            //5. 缓存数据
            if (weakSelf.enableCache) {
                SaveCacheObjectByFile(weakSelf.sectionKeyArray, KeyOfSectionKey, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.headerDataArray, KeyOfHeaderData, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.cellDataArray, KeyOfCellData, weakSelf.cacheFileName);
                SaveCacheObjectByFile(weakSelf.footerDataArray, KeyOfFooterData, weakSelf.cacheFileName);
            }
        }
        weakSelf.tipsView.hidden = [NSArray isNotEmpty:weakSelf.cellDataArray];
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
        [header layoutObject:self.headerDataArray[section]];
        
        WEAKSELF
        [header removeAllGestureRecognizers];
        [header bk_whenTapped:^{
            weakSelf.clickHeaderBlock(weakSelf.headerDataArray[section], section);
        }];
    }
    return header;
}
//CELL
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.cellDataArray[indexPath.section];
    if ([NSClassFromString(self.cellName) isKindOfClass:[YSCBaseTableViewCell class]]) {
        return [NSClassFromString(self.cellName) HeightOfCellByDataModel:array[indexPath.row]];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//FOOTER
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
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
        [footer layoutObject:self.footerDataArray[section]];
        
        WEAKSELF
        [footer removeAllGestureRecognizers];
        [footer bk_whenTapped:^{
            weakSelf.clickHeaderBlock(weakSelf.footerDataArray[section], section);
        }];
    }
    return footer;
}
//选择cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.cellDataArray[indexPath.section];
    self.clickCellBlock(array[indexPath.row], indexPath);
}
//
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.layoutMargins = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
}

@end
