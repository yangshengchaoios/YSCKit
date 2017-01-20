//
//  UIScrollView+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIScrollView+YSCKit.h"

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation UIScrollView (YSCKit)
- (CGFloat)_ysc_verticalOffsetForTop {
    CGFloat topInset = self.contentInset.top;
    return -topInset;
}
- (CGFloat)_ysc_verticalOffsetForBottom {
    CGFloat scrollViewHeight = self.bounds.size.height;
    CGFloat scrollContentSizeHeight = self.contentSize.height;
    CGFloat bottomInset = self.contentInset.bottom;
    CGFloat scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight;
    return scrollViewBottomOffset;
}

- (BOOL)ysc_isAtTop {
    return (self.contentOffset.y <= [self _ysc_verticalOffsetForTop]);
}
- (BOOL)ysc_isAtBottom {
    return (self.contentOffset.y >= [self _ysc_verticalOffsetForBottom]);
}
- (BOOL)ysc_isSwipingRight {
    CGPoint translation = [self.panGestureRecognizer translationInView:self.superview];
    return translation.x > 0;
}
- (BOOL)ysc_isSwipingLeft {
    return ! [self ysc_isSwipingRight];
}
- (BOOL)ysc_isSwipingDown {
    CGPoint translation = [self.panGestureRecognizer translationInView:self.superview];
    return translation.y > 0;
}
- (BOOL)ysc_isSwipingUp {
    return ! [self ysc_isSwipingDown];
}

- (void)ysc_scrollToTop {
    [self ysc_scrollToTopAnimated:YES];
}
- (void)ysc_scrollToBottom {
    [self ysc_scrollToBottomAnimated:YES];
}
- (void)ysc_scrollToLeft {
    [self ysc_scrollToLeftAnimated:YES];
}
- (void)ysc_scrollToRight {
    [self ysc_scrollToRightAnimated:YES];
}
- (void)ysc_scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}
- (void)ysc_scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}
- (void)ysc_scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}
- (void)ysc_scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}
@end
