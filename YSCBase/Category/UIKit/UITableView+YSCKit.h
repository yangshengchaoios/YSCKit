//
//  UITableView+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface UITableView (YSCKit)
- (void)ysc_updateWithBlock:(void (^)(UITableView *tableView))block;
- (void)ysc_scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)ysc_insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)ysc_clearSelectedRowsAnimated:(BOOL)animated;
@end
