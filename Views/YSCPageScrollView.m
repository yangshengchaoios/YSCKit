//
//  PageScrollView.m
//  YSCKit
//
//  Created by 杨胜超 on 13-7-22.
//  Copyright (c) 2013年 杨胜超. All rights reserved.
//

#import "YSCPageScrollView.h"
#define TagOfPage 5678

@interface YSCPageScrollView (Private)

- (void)loadPageViewWithPage:(NSInteger)page;
- (void)setScrollPageVisible:(UIScrollView *)scrollView1 atPage:(NSInteger)page;
- (void)pageControlValueChanged;

@end

@implementation YSCPageScrollView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {  
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        pageControlEnableTapped = NO;
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.clipsToBounds = YES;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,
                                                                      self.bounds.size.height - 20,
                                                                      self.bounds.size.width,
                                                                      20)];
        pageControl.hidesForSinglePage = YES;
        [pageControl addTarget:self action:@selector(pageControlValueChanged) forControlEvents:UIControlEventValueChanged];
        if ([pageControl respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
            pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        }
        if ([pageControl respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]) {
            pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        }
        [self addSubview:scrollView];
        [self addSubview:pageControl];
    }
    return self;
}

- (void)reloadData {
    NSAssert(self.pageScrollDelegate, @"The pageScrollDelegate property is not allowed nil!");
    totalPages = [self.pageScrollDelegate pageScrollViewTotalPages:self];
    if ( [(UIViewController *)self.pageScrollDelegate respondsToSelector:@selector(pageControlEnableTapped:)] ) {
        pageControlEnableTapped = [self.pageScrollDelegate pageControlEnableTapped:self];
    }
//    pageControl.enabled = pageControlEnableTapped;
    pageControl.userInteractionEnabled = pageControlEnableTapped;
    pageControl.numberOfPages = totalPages;
    
    if (viewArray != nil && viewArray.count > 0) {
        for (NSObject *object in viewArray) {
            if (object != [NSNull null]) {
                UIView *view  = (UIView *)object;
                [view removeFromSuperview];
            }
        }
        [viewArray removeAllObjects];
    }
    
    if (viewArray == nil || viewArray.count != totalPages) {
        viewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < totalPages; i++) {
            [viewArray addObject:[NSNull null]];
        }
        scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * totalPages, scrollView.bounds.size.height);
    }
    pageControl.currentPage = 0;
    
    [self setScrollPageVisible:scrollView atPage:pageControl.currentPage];
    [self loadPageViewWithPage:0];
    [self loadPageViewWithPage:1];
}

- (void)loadPageViewWithPage:(NSInteger)page {
    if (page < 0) {
        return;
    }
    else if (page >= totalPages) {
        return;
    }
    
    UIView *view = [viewArray objectAtIndex:page];
    if ((NSNull *)view == [NSNull null]) {
        view = [self.pageScrollDelegate pageScrollView:self viewAtPageIndex:page];
        view.tag = TagOfPage + page;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
        recognizer.numberOfTouchesRequired = 1;//多少根手指
        recognizer.numberOfTapsRequired = 1;//点击几次
        recognizer.delegate = self;
        [view addGestureRecognizer:recognizer];
        
        [viewArray replaceObjectAtIndex:page withObject:view];
    }
    
    if (nil == view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        view.frame = frame;
        [scrollView addSubview:view];
    }
}

- (void)pageControlValueChanged { 
//    scrollView.scrollEnabled = YES;
    [self setScrollPageVisible:scrollView atPage:pageControl.currentPage];
}

- (void)setScrollPageVisible:(UIScrollView *)scrollView1 atPage:(NSInteger)page {
    //方法一
    CGRect frame = CGRectMake(page * scrollView1.bounds.size.width,
                              0,
                              scrollView1.bounds.size.width,
                              scrollView1.bounds.size.height);
    [scrollView1 scrollRectToVisible:frame animated:YES];
    
    //方法二
//    [scrollView setContentOffset:CGPointMake(page * scrollView1.bounds.size.width, 0) animated:NO];
}

- (NSInteger)currentPage {
    return pageControl.currentPage;
}

#pragma mark - UIGestureRecognizerDelegate

- (void) handleTapEvent:(UITapGestureRecognizer *)recognizer {
    [self.pageScrollDelegate pageScrollView:self didTapedAtPageIndex:recognizer.view.tag - TagOfPage];
}


#pragma mark - scrollview delegate

//只要在滚动就会回调该方法
- (void)scrollViewDidScroll:(UIScrollView *)sender {
}
 
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView1 {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView1 willDecelerate:(BOOL)decelerate {
//    scrollView1.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1 {
    CGFloat pageWidth = scrollView1.frame.size.width;
    int page = floor((scrollView1.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    [self loadPageViewWithPage:page - 1];
    [self loadPageViewWithPage:page];
    [self loadPageViewWithPage:page + 1];
    
//    scrollView1.scrollEnabled = YES;
}
@end
