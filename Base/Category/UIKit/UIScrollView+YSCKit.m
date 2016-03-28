//
//  UIScrollView+YSCKit.m
//  YSCKit
//
//  Created by yangshengchao on 15/3/6.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "UIScrollView+YSCKit.h"

@implementation UIScrollView (YSCKit)

- (BOOL)isAtTop {
    return (self.contentOffset.y <= [self _verticalOffsetForTop]);
}

- (BOOL)isAtBottom {
    return (self.contentOffset.y >= [self _verticalOffsetForBottom]);
}

- (CGFloat)_verticalOffsetForTop {
    CGFloat topInset = self.contentInset.top;
    return -topInset;
}

- (CGFloat)_verticalOffsetForBottom {
    CGFloat scrollViewHeight = self.bounds.size.height;
    CGFloat scrollContentSizeHeight = self.contentSize.height;
    CGFloat bottomInset = self.contentInset.bottom;
    CGFloat scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight;
    return scrollViewBottomOffset;
}

//指的是手指往右滚，看右面的内容
- (BOOL)isSwipingRight {
    CGPoint translation = [self.panGestureRecognizer translationInView:self.superview];
//    translation = [self.panGestureRecognizer velocityInView:self.superview];
    return translation.x > 0;
}

- (BOOL)isSwipingLeft {
    return ! [self isSwipingRight];
}
//指的是手指往下滚，看下面的内容
- (BOOL)isSwipingDown {
    CGPoint translation = [self.panGestureRecognizer translationInView:self.superview];
//    translation = [self.panGestureRecognizer velocityInView:self.superview];
    return translation.y > 0;
}

- (BOOL)isSwipingUp {
    return ! [self isSwipingDown];
}

@end
