//
//  YSCTableView.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/26.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCTableView.h"
#import "MJRefresh.h"

@interface YSCTableView () <UITableViewDataSource, UITableViewDelegate>

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
    WEAKSELF
    //设置参数默认值
    self.sectionDataArray = [NSMutableArray array];
    self.cellDataArray = [NSMutableArray array];
    self.currentPageIndex = kDefaultPageStartIndex;
    self.requestType = RequestTypeGET;
    self.enableCache = NO;
    self.enableLoadMore = YES;
    self.enableRefresh = YES;
    self.enableTips = YES;
    self.prefixOfUrl = kResPathAppBaseUrl;
    self.tipsMessageWhenEmpty = kDefaultTipText;
    self.tipsSuccessIcon = @"icon_empty";
    self.tipsFailedIcon = @"icon_failed";
    self.cellSeperatorLeft = 0;
    self.cellSeperatorRight = 0;
    self.headerHeight = self.footerHeight = 0.01;
    
    self.tipsView = [YSCKTipsView CreateYSCTipsViewOnView:self
                                               edgeInsets:UIEdgeInsetsZero
                                              withMessage:self.tipsMessageWhenEmpty
                                                iconImage:[UIImage imageNamed:self.tipsSuccessIcon]
                                              buttonTitle:@"重新加载" buttonAction:^{
                                                  [weakSelf.header beginRefreshing];
                                              }];
    [self initTableView];
}
- (void)initTableView {
    //1. 注册cell、header、footer
    if (isNotEmpty(self.cellName)) {
        [NSClassFromString(self.cellName) registerCellToTableView:self];
    }
    if (isNotEmpty(self.headerName)) {
        [NSClassFromString(self.headerName) registerHeaderToTableView:self];
    }
    if (isNotEmpty(self.footerName)) {
        [NSClassFromString(self.footerName) registerHeaderToTableView:self];
    }
    
    //2. 设置cell的分割线
    self.separatorInset = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    self.layoutMargins = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    //3. 设置其他参数
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    self.dataSource = self;
    self.delegate = self;
    self.backgroundColor = kDefaultViewColor;
    self.separatorColor = kDefaultBorderColor;
}

//兼容下拉刷新和上拉加载更多
- (void)downloadAtIndex:(NSInteger)pageIndex {
    WEAKSELF
    YSCIdResultBlock resultBlock = ^(id responseObject, NSError *error) {
        BOOL isPullToRefresh = (kDefaultPageStartIndex == pageIndex); //是否下拉刷新
        isPullToRefresh ? [weakSelf.header endRefreshing] : [weakSelf.footer endRefreshing];
        //处理返回结果
        if (error) {
            [UIView showAlertVieWithMessage:@""];
            //TODO:call failed block
        }
        else {
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
                weakSelf.currentPageIndex = pageIndex;  //只要接口成功返回了数据，就把当前请求的页码保存起来
                if (weakSelf.preProcessBlock) { newDataArray = weakSelf.preProcessBlock(dataArray); }
            }
            
            //3. 根据新数组刷新界面显示
            if ([newDataArray count] > 0) {
                if (isPullToRefresh) {
                    [weakSelf.sectionDataArray removeAllObjects];
                    [weakSelf.cellDataArray removeAllObjects];
                }
                else {
                    [weakSelf beginUpdates];
                }
                //-----------------多section的刷新--------------
                NSMutableArray *insertedIndexPaths = [NSMutableArray array];
                for (S4StaffModel *model in newDataArray) {
                    NSInteger row = 0, section = 0;
                    if ([weakSelf.sectionDataArray containsObject:Trim(model.brandName)]) {
                        section = [weakSelf.sectionDataArray indexOfObject:Trim(model.brandName)];
                        NSMutableArray *tempArray = weakSelf.cellDataArray[section];
                        [tempArray addObject:model];
                        row = [tempArray count] - 1;
                    }
                    else {
                        row = 0;
                        section = [weakSelf.sectionDataArray count];
                        [weakSelf.sectionDataArray addObject:Trim(model.brandName)];
                        
                        NSMutableArray *tempArray = [NSMutableArray array];
                        [tempArray addObject:model];
                        [weakSelf.cellDataArray addObject:tempArray];
                        
                        if (NO == isPullToRefresh) {//insert section
                            [weakSelf insertSections:[NSIndexSet indexSetWithIndex:section]
                                    withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                    //insert row
                    if (NO == isPullToRefresh) {
                        [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
                    }
                }
                //--------------------------------------------
                //刷新TableView
                if (isPullToRefresh) {
                    [weakSelf reloadData];
                }
                else {//insert rows
                    [weakSelf insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf endUpdates];
                }
            }
            else {
                if (isPullToRefresh) {
                    [weakSelf.sectionDataArray removeAllObjects];
                    [weakSelf.cellDataArray removeAllObjects];
                    if (weakSelf.reloadBlock) {
                        weakSelf.reloadBlock();
                    }
                }
                else {
                    [UIView showResultThenHideOnWindow:@"没有更多了"];
                }
            }
        }
        weakSelf.tipsView.hidden = [NSArray isNotEmpty:weakSelf.cellDataArray];
    };
    
    //4. 开始网络访问
    if(RequestTypeGET == self.requestType) {
        [AFNManager getDataFromUrl:self.prefixOfUrl
                           withAPI:self.methodName
                      andDictParam:self.dictParam
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
                     andDictParam:self.dictParam
                        modelName:NSClassFromString(self.modelName)
                 requestSuccessed:^(id responseObjec) {
                     resultBlock(responseObjec, nil);
                 }
                   requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                       resultBlock(nil, CreateNSError(errorMessage));
                   }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionDataArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.cellDataArray[section];
    return [array count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUTOLAYOUT_LENGTH(self.headerHeight);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YSCBaseTableHeaderFooterView *header = nil;
    if (isNotEmpty(self.headerName)) {
        header = [NSClassFromString(self.headerName) dequeueHeaderByTableView:tableView];
        
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSCBaseTableViewCell *cell = [NSClassFromString(self.cellName) dequeueCellByTableView:tableView];
    NSArray *array = self.cellDataArray[indexPath.section];
    BaseDataModel *object = array[indexPath.row];
    if ([cell isKindOfClass:[YSCBaseTableViewCell class]]) {
        if ([object isKindOfClass:[NSArray class]]) {
            [cell layoutDataModels:(NSArray *)object];
        }
        else {
            [cell layoutDataModel:object];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.cellDataArray[indexPath.section];
    if ([NSClassFromString(self.cellName) isKindOfClass:[YSCBaseTableViewCell class]]) {
        return [NSClassFromString(self.cellName) HeightOfCellByDataModel:array[indexPath.row]];
    }
    else {
        return 44;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.layoutMargins = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
}


@end
