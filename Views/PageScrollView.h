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

@interface PageScrollView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
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

- (NSInteger)pageScrollViewTotalPages:(PageScrollView *)pageScrollView;
- (UIView *)pageScrollView:(PageScrollView *)pageScrollView viewAtPageIndex:(NSInteger)pageIndex;
- (void)pageScrollView:(PageScrollView *)pageScrollView didTapedAtPageIndex:(NSInteger)pageIndex;

@optional

- (BOOL)pageControlEnableTapped:(PageScrollView *)pageScrollView;

@end