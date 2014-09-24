//
//  InfiniteLoopView.h
//  TGO2
//
//  Created by  YangShengchao on 14-7-16.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>

#pragma mark - define blocks

/**
 *  返回页面的显示内容
 *
 *  @param pageIndex
 *
 *  @return
 */
typedef UIView *(^PageViewAtIndex)(NSInteger pageIndex);
/**
 *  点击页面执行操作
 *
 *  @param pageIndex
 */
typedef void(^TapPageAtIndex)(NSInteger pageIndex, UIView *contentView);
/**
 *  当页面切换到pageIndex时执行操作
 *
 *  @param pageIndex
 */
typedef void(^PageDidChangedAtIndex)(NSInteger pageIndex);




/**
 *  无限循环view
 */
@interface InfiniteLoopView : UIView

@property (nonatomic, assign) NSInteger currentPageIndex;                   //当前页码
@property (nonatomic, assign) NSTimeInterval animationDuration;             //默认5秒
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, copy) PageViewAtIndex pageViewAtIndex;
@property (nonatomic, copy) TapPageAtIndex tapPageAtIndex;
@property (nonatomic, copy) PageDidChangedAtIndex pageDidChangedAtIndex;

- (void)reloadData;

@end
