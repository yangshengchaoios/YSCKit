//
//  PageScrollView.h
//  YSCKit
//
//  Created by 杨胜超 on 13-7-22.
//  Copyright (c) 2013年 杨胜超. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>
@protocol PageScrollDelegate;

@interface YSCPageScrollView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSInteger totalPages;
    BOOL pageControlEnableTapped;
    
    NSMutableArray *viewArray;
}

@property (nonatomic, assign) id<PageScrollDelegate> pageScrollDelegate;
@property (nonatomic, assign) NSInteger currentPage;

- (void)reloadData;

@end


@protocol PageScrollDelegate

@required

- (NSInteger)pageScrollViewTotalPages:(YSCPageScrollView *)pageScrollView;
- (UIView *)pageScrollView:(YSCPageScrollView *)pageScrollView viewAtPageIndex:(NSInteger)pageIndex;
- (void)pageScrollView:(YSCPageScrollView *)pageScrollView didTapedAtPageIndex:(NSInteger)pageIndex;

@optional

- (BOOL)pageControlEnableTapped:(YSCPageScrollView *)pageScrollView;

@end