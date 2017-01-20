//
//  YSCInfiniteLoopView.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  无限循环view
 */
@interface YSCInfiniteLoopView : UIView

@property (nonatomic, assign) NSInteger currentPageIndex;                   //当前页码(可以手动设置改变)
@property (nonatomic, assign) NSTimeInterval animationDuration;             //默认5秒
@property (nonatomic, assign) NSInteger totalPageCount;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, copy) UIView *(^pageViewAtIndex)(NSInteger pageIndex);
@property (nonatomic, copy) void(^tapPageAtIndex)(NSInteger pageIndex, UIView *contentView);
@property (nonatomic, copy) void(^pageDidChanged)(NSInteger pageIndex);

/** 加载数据 */
- (void)reloadData;
/** 该方法必须调用，否则无法释放timer */
- (void)stopLoop;

@end
