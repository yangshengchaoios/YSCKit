//
//  UIScrollView+YSCKit.h
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
@interface UIScrollView (YSCKit)
- (BOOL)ysc_isAtTop;
- (BOOL)ysc_isAtBottom;
- (BOOL)ysc_isSwipingRight;
- (BOOL)ysc_isSwipingLeft;
- (BOOL)ysc_isSwipingDown;
- (BOOL)ysc_isSwipingUp;

- (void)ysc_scrollToTop;
- (void)ysc_scrollToBottom;
- (void)ysc_scrollToLeft;
- (void)ysc_scrollToRight;
- (void)ysc_scrollToTopAnimated:(BOOL)animated;
- (void)ysc_scrollToBottomAnimated:(BOOL)animated;
- (void)ysc_scrollToLeftAnimated:(BOOL)animated;
- (void)ysc_scrollToRightAnimated:(BOOL)animated;
@end
