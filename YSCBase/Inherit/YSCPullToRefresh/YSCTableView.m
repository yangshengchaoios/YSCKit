//
//  YSCTableView.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCTableView.h"

@interface YSCTableView () <UITableViewDataSource, UITableViewDelegate> @end
@implementation YSCTableView
- (void)dealloc {
    PRINT_DEALLOCING
}
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self _setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup];
    }
    return self;
}


#pragma mark - 初始化配置参数
- (void)_setup {
    self.helper = [[YSCPullToRefreshHelper alloc] init];
    self.helper.scrollView = self;
    //设置默认属性
    self.helper.enableRefresh = YES;
    self.helper.enableLoadMore = YES;
    self.helper.enableTips = YES;
    @weakiy(self);
    self.helper.loadMoreBlock = ^(NSIndexSet *sections, NSArray<NSIndexPath *> *indexPaths) {
        [weak_self beginUpdates];
        if ([sections count] > 0) {
            [weak_self insertSections:sections withRowAnimation:UITableViewRowAnimationNone];
        }
        [weak_self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [weak_self endUpdates];
    };
    self.helper.deleteCellBlock = ^(NSIndexPath *indexPath) {
        [weak_self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [self initTableView];
}
- (void)initTableView {
    //1. 注册cell、header、footer
    [self registerHeaderName:self.headerName];
    [self registerCellName:self.cellName];
    [self registerFooterName:self.footerName];
    
    //2. 设置cell的分割线
    [self resetCellEdgeInsets];
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = [UIColor colorWithRed:220 / 255.0f green:220 / 255.0f blue:220 / 255.0f alpha:1.0f];//NOTE:xib < this
    
    //3. 设置其他参数
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.backgroundColor = [UIColor clearColor];
    self.dataSource = self;
    self.delegate = self;
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


#pragma mark - 属性设置
- (void)setCellName:(NSString *)cellName {
    _cellName = cellName;
    [self registerCellName:cellName];
}
- (void)setHeaderName:(NSString *)headerName {
    _headerName = headerName;
    [self registerHeaderName:headerName];
}
- (void)setFooterName:(NSString *)footerName {
    _footerName = footerName;
    [self registerFooterName:footerName];
}
- (void)setCellSeperatorLeft:(CGFloat)cellSeperatorLeft {
    _cellSeperatorLeft = cellSeperatorLeft;
    [self resetCellEdgeInsets];
}
- (void)setCellSeperatorRight:(CGFloat)cellSeperatorRight {
    _cellSeperatorRight = cellSeperatorRight;
    [self resetCellEdgeInsets];
}


#pragma mark - 注册header、cell、footer
- (void)registerHeaderName:(NSString *)headerName {
    if (OBJECT_ISNOT_EMPTY(headerName)) {
        _headerName = headerName;
        if (IS_NIB_EXISTS(headerName)) {
            [self registerNib:[UINib nibWithNibName:headerName bundle:nil]
forHeaderFooterViewReuseIdentifier:headerName];
        }
        else {
            [self registerClass:NSClassFromString(headerName)
forHeaderFooterViewReuseIdentifier:headerName];
        }
    }
}
- (void)registerCellName:(NSString *)cellName {
    if (OBJECT_ISNOT_EMPTY(cellName)) {
        _cellName = cellName;
        if (IS_NIB_EXISTS(cellName)) {
            [self registerNib:[UINib nibWithNibName:cellName bundle:nil]
       forCellReuseIdentifier:cellName];
        }
        else {
            [self registerClass:NSClassFromString(cellName)
       forCellReuseIdentifier:cellName];
        }
    }
}
- (void)registerFooterName:(NSString *)footerName {
    if (OBJECT_ISNOT_EMPTY(footerName)) {
        _footerName = footerName;
        if (IS_NIB_EXISTS(footerName)) {
            [self registerNib:[UINib nibWithNibName:footerName bundle:nil]
forHeaderFooterViewReuseIdentifier:footerName];
        }
        else {
            [self registerClass:NSClassFromString(footerName)
forHeaderFooterViewReuseIdentifier:footerName];
        }
    }
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.helper.cellDataArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.helper.cellDataArray[section];
    return [array count];
}
//HEADER
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section >= 0 && section < [self.helper.sectionDataArray count])) {
        NSString *headerName = self.headerName;
        NSObject *headerObject = self.helper.sectionDataArray[section];
        if (self.headerNameBlock) {
            headerName = self.headerNameBlock(headerObject, section);
        }
        if (OBJECT_ISNOT_EMPTY(headerName)) {
            if (self.headerHeightBlock) {
                return self.headerHeightBlock(headerObject, section);
            }
            else {
                if ([NSClassFromString(headerName) respondsToSelector:@selector(heightOfViewByObject:)]) {
                    return [NSClassFromString(headerName) heightOfViewByObject:headerObject];
                }
            }
        }
    }
    
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = nil;
    if ((section >= 0 && section < [self.helper.sectionDataArray count])) {
        NSString *headerName = self.headerName;
        NSObject *headerObject = self.helper.sectionDataArray[section];
        if (self.headerNameBlock) {
            headerName = self.headerNameBlock(headerObject, section);
        }
        
        if (OBJECT_ISNOT_EMPTY(headerName)) {
            header = [self dequeueReusableHeaderFooterViewWithIdentifier:headerName];
            if ([header respondsToSelector:@selector(layoutObject:)]) {
                [header performSelector:@selector(layoutObject:) withObject:headerObject];
            }
            if (self.layoutHeaderView) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                self.layoutHeaderView(header, headerObject, indexPath);
            }
        }
    }
    return header;
}
//CELL
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *cellObject = [self.helper getObjectByIndexPath:indexPath];
    //0. 屏蔽通用cell的高度
    if (self.cellHeightBlock) {
        return self.cellHeightBlock(cellObject, indexPath);
    }
    //1. 单个情况下的高度
    NSString *cellName = self.cellName;
    if (self.cellNameBlock) {
        NSString *tempName = self.cellNameBlock(cellObject, indexPath);
        if (OBJECT_ISNOT_EMPTY(tempName)) {
            cellName = tempName;
        }
    }
    if (OBJECT_ISNOT_EMPTY(cellName) && [NSClassFromString(cellName) respondsToSelector:@selector(heightOfCellByObject:)]) {
        return [NSClassFromString(cellName) heightOfCellByObject:cellObject];
    }
    else {
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSObject *cellObject = [self.helper getObjectByIndexPath:indexPath];
    NSString *cellName = self.cellName;
    if (self.cellNameBlock) {
        NSString *tempName = self.cellNameBlock(cellObject, indexPath);
        if (OBJECT_ISNOT_EMPTY(tempName)) {
            cellName = tempName;
        }
    }
    cell = [self dequeueReusableCellWithIdentifier:cellName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(layoutObject:)]) {
        [cell performSelector:@selector(layoutObject:) withObject:cellObject];
    }
    if (self.layoutCellView) {
        self.layoutCellView(cell, cellObject, indexPath);
    }
    return cell;
}
//FOOTER
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ((section >= 0 && section < [self.helper.sectionDataArray count])) {
        NSString *footerName = self.footerName;
        NSObject *footerObject = self.helper.sectionDataArray[section];
        if (self.footerNameBlock) {
            footerName = self.footerNameBlock(footerObject, section);
        }
        if (OBJECT_ISNOT_EMPTY(footerName)) {
            if (self.footerHeightBlock) {
                return self.footerHeightBlock(footerObject, section);
            }
            else {
                if ([NSClassFromString(footerName) respondsToSelector:@selector(heightOfViewByObject:)]) {
                    return [NSClassFromString(footerName) heightOfViewByObject:footerObject];
                }
            }
        }
    }
    
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = nil;
    if ((section >= 0 && section < [self.helper.sectionDataArray count])) {
        NSString *footerName = self.footerName;
        NSObject *footerObject = self.helper.sectionDataArray[section];
        if (self.footerNameBlock) {
            footerName = self.footerNameBlock(footerObject, section);
        }
        
        if (OBJECT_ISNOT_EMPTY(footerName)) {
            footer = [self dequeueReusableHeaderFooterViewWithIdentifier:footerName];
            if ([footer respondsToSelector:@selector(layoutObject:)]) {
                [footer performSelector:@selector(layoutObject:) withObject:footerObject];
            }
            if (self.layoutFooterView) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                self.layoutFooterView(footer, footerObject, indexPath);
            }
        }
    }
    return footer;
}
//选择cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickCellBlock) {
        NSObject *object = [self.helper getObjectByIndexPath:indexPath];
        self.clickCellBlock(object, indexPath);
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.unClickCellBlock) {
        NSObject *object = [self.helper getObjectByIndexPath:indexPath];
        self.unClickCellBlock(object, indexPath);
    }
}

//其它
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, self.cellSeperatorLeft, 0, self.cellSeperatorRight);
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:edgeInsets];
    }
    if (self.willDisplayCell) {
        NSObject *object = [self.helper getObjectByIndexPath:indexPath];
        self.willDisplayCell(cell, object, indexPath);
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if (self.didEndDisplayintCell) {
        NSObject *object = [self.helper getObjectByIndexPath:indexPath];
        self.didEndDisplayintCell(cell, object, indexPath);
    }
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *object = [self.helper getObjectByIndexPath:indexPath];
    if (self.willBeginEditingBlock) {
        self.willBeginEditingBlock(object, indexPath);
    }
}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    NSObject *object = [self.helper getObjectByIndexPath:indexPath];
    if (self.didEndEditingBlock) {
        self.didEndEditingBlock(object, indexPath);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.helper.willBeginDraggingBlock) {
        self.helper.willBeginDraggingBlock();
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.helper.didEndDraggingBlock) {
        self.helper.didEndDraggingBlock();
    }
    if ( ! decelerate) {// 如果在滚动结束后没有加速度，则不会调用！这里强制滚动结束后都调用
        [self scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.helper.didScrollBlock) {
        self.helper.didScrollBlock();
    }
}
/** scrollRectToVisible:animated: 结束后才会调用(与decelerate不冲突！) */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.helper.didEndScrollingAnimationBlock) {
        self.helper.didEndScrollingAnimationBlock();
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.helper.willBeginDeceleratingBlock) {
        self.helper.willBeginDeceleratingBlock();
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.helper.didEndDeceleratingBlock) {
        self.helper.didEndDeceleratingBlock();
    }
}

@end
