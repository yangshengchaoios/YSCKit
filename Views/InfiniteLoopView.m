//
//  InfiniteLoopView.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-16.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "InfiniteLoopView.h"

#define TagOfContentViewStart   56214
#define HeightOfPageControl     20

@interface InfiniteLoopView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *lastFireDate;

@end

@implementation InfiniteLoopView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
	[self initSubviews];
}

- (void)initSubviews {
    self.lastFireDate = [NSDate distantPast];
    //1. 添加scrollview
	self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	self.scrollView.autoresizingMask = 0xFF;
	self.scrollView.contentMode = UIViewContentModeCenter;
	self.scrollView.delegate = self;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.contentOffset = CGPointMake(0, 0);
	self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
	[self addSubview:self.scrollView];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [self.scrollView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    //2. 创建pagecontrol
    self.pageControl = [[SMPageControl alloc] init];
    self.pageControl.pageIndicatorImage = [ImageUtils resizeImage:[UIImage imageNamed:@"circle_pagecontrol_normal"]
                                                           toSize:AUTOLAYOUT_SIZE_WH(HeightOfPageControl, HeightOfPageControl)];
    self.pageControl.currentPageIndicatorImage = [ImageUtils resizeImage:[UIImage imageNamed:@"circle_pagecontrol_selected"]
                                                                  toSize:AUTOLAYOUT_SIZE_WH(HeightOfPageControl, HeightOfPageControl)];
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:AUTOLAYOUT_LENGTH(8)];
    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.pageControl autoMatchDimension:ALDimensionHeight
                             toDimension:ALDimensionWidth
                                  ofView:self.pageControl
                          withMultiplier:(HeightOfPageControl / self.width)];
    
    //4. 初始化参数设置
    self.pageControl.currentPage = 0;
    self.animationDuration = 5;
    self.autoresizesSubviews = YES;
}

#pragma mark - 设置属性

- (void)setCurrentPageIndex:(NSInteger)pageIndex {
    if (pageIndex < 0) {
        return;
    }
    
    _currentPageIndex = pageIndex;
    self.pageControl.currentPage = pageIndex;
    if (self.pageDidChanged) {
        self.pageDidChanged(pageIndex);
    }
    
    self.lastFireDate = [NSDate date];//暂停自动滑动
    
    //计算出需要的偏移量
    CGPoint newOffset = CGPointMake(0, 0);
    for (UIView *subview in self.scrollView.subviews) {
        if (TagOfContentViewStart + pageIndex == subview.tag) {
            newOffset = CGPointMake(subview.left, 0);
            break;
        }
    }
    [self.scrollView setContentOffset:newOffset animated:NO];
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    if (animationDuration <= 0) {
        return;
    }
    
    _animationDuration = animationDuration;
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:animationDuration
                                                  target:self
                                                selector:@selector(animationTimerDidFired:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)setTotalPageCount:(NSInteger)totalPageCount {
    if (totalPageCount <= 0) {
        return;
    }
    _totalPageCount = totalPageCount;
    _pageControl.numberOfPages = totalPageCount;
}

- (void)reloadData {
    if (self.totalPageCount == 0) {
        return;
    }
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger scrollPages = MAX(3, self.totalPageCount);
    if (self.totalPageCount % 2 == 0) {
        scrollPages = MAX(4, self.totalPageCount);
    }
    
    for (int i = 0; i < scrollPages; i++) {
        UIView *contentView = nil;
        if (self.totalPageCount == 1) {
            contentView = [self getPageViewAtIndex:0];
            contentView.tag = TagOfContentViewStart + 0;
        }
        else if (self.totalPageCount == 2) {
            if (i == 0 || i == 2) {
                contentView = [self getPageViewAtIndex:0];
                contentView.tag = TagOfContentViewStart + 0;
            }
            else if (i == 1 || i == 3) {
                contentView = [self getPageViewAtIndex:1];
                contentView.tag = TagOfContentViewStart + 1;
            }
        }
        else {
            contentView = [self getPageViewAtIndex:i];
            contentView.tag = TagOfContentViewStart + i;
        }
        
		contentView.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
		[contentView addGestureRecognizer:tapGesture];
		CGRect rightRect = contentView.frame;
		rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * i, 0);
		contentView.frame = rightRect;
		[self.scrollView addSubview:contentView];
    }
    self.scrollView.contentSize = CGSizeMake(scrollPages * CGRectGetWidth(self.scrollView.frame),
                                             CGRectGetHeight(self.scrollView.frame));
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.pageControl.currentPage = 0;
}

#pragma mark - 私有函数

- (UIView *)getPageViewAtIndex:(NSInteger)pageIndex {
    if (self.pageViewAtIndex) {
        UIView *view = self.pageViewAtIndex(pageIndex);
        if (view) {
            return view;
        }
    }
    
    UIView *emptyView = [[UIView alloc] initWithFrame:self.bounds];
    emptyView.backgroundColor = [UIColor redColor];
    return emptyView;
}

- (void)animationTimerDidFired:(NSTimer *)timer {
    if ([NSDate date].timeIntervalSince1970 - self.lastFireDate.timeIntervalSince1970 >= self.animationDuration) {
//        self.currentPageIndex = (self.pageControl.currentPage + 1) % self.pageControl.numberOfPages;
        
        CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), 0);
        [self.scrollView setContentOffset:newOffset animated:YES];//NOTE:这里会自动回调scrollViewDidEndScrollingAnimation
    }
}

/**
 *  重置scrollview里的所有子view的位置
 */
- (void)resetContentViews {
    int contentOffsetX = self.scrollView.contentOffset.x;
    BOOL isMoveToRight = YES;
    if (contentOffsetX >= self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame)) {
        isMoveToRight = YES;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - 2 * CGRectGetWidth(self.scrollView.frame), 0);
    }
    else if (contentOffsetX <= 0) {
        isMoveToRight = NO;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    }
    else {
        for (UIView *contentView in self.scrollView.subviews) {
            if (contentView.frame.origin.x == self.scrollView.contentOffset.x) {
                self.pageControl.currentPage = contentView.tag - TagOfContentViewStart;
            }
        }
        return;
    }
    
    //重置所有子view的坐标
    for (UIView *contentView in self.scrollView.subviews) {
        CGRect frame = contentView.frame;
        if (isMoveToRight) {//把第一个放在最后一位
            if (frame.origin.x < frame.size.width) {
                frame.origin.x = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
            }
            else {
                frame.origin.x -= frame.size.width;
            }
        }
        else {//将最后一个放在第一位
            if (frame.origin.x > self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame) - 5) {
                frame.origin.x = 0;
            }
            else {
                frame.origin.x += frame.size.width;
            }
        }
        contentView.frame = frame;
        
        //设置当前页码
        if (contentView.frame.origin.x == self.scrollView.contentOffset.x) {
            self.pageControl.currentPage = contentView.tag - TagOfContentViewStart;
        }
    }
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap {
    UIView *contentView = tap.view;
    NSInteger tapIndex = contentView.tag - TagOfContentViewStart;
	if (self.tapPageAtIndex) {
		self.tapPageAtIndex(tapIndex, contentView);
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self pauseTimer:self.timer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self resumeTimer:self.timer afterInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidScroll");
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetContentViews];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetContentViews];
}

#pragma mark - NSTimer暂停/恢复

- (void)pauseTimer:(NSTimer *)timer {
	if (![timer isValid]) {
		return;
	}
	[timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer:(NSTimer *)timer afterInterval:(NSTimeInterval)interval {
	if (![timer isValid]) {
		return;
	}
	[timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end
