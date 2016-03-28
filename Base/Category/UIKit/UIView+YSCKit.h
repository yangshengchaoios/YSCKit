//
//  UIView+YSCKit.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YSCKit)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;

- (void)removeAllGestureRecognizers;
- (void)removeAllSubviews;
- (void)removeAllConstraints;       //移除view(包括subviews)上所有constraints
- (void)hideAllSubviews;


/** view边框调整 */
+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius;
- (void)makeRoundWithRadius:(CGFloat)radius;
+ (void)makeBorderForView:(UIView *)view;
- (void)makeBorderLine;
+ (void)makeBorderForView:(UIView *)view withColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width;


/** view截图 */
+ (UIImage *)screenshotOfView:(UIView *) view;
- (UIImage *)screenshotOfView;


/** 递归遍历所有子view */
+ (void)resetSizeOfView:(UIView *)view;     //包括了Font和Constraint
+ (void)resetFontSizeOfView:(UIView *)view;
- (void)resetFontSizeOfView;
+ (void)resetConstraintOfView:(UIView *)view;
- (void)resetConstraintOfView;
@end


@interface UIView (Gesture)
/**
 *	实现水平方向上左右滑动的动画效果
 *
 *	@param	view	需要做动画的view
 *	@param	subtype	方向 kCATransitionFromRight、kCATransitionFromLeft
 */
+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype;
- (void)animateHorizontalSwipeWithSubType:(NSString *)subtype;
+ (void)flipView:(UIView *)view withTransition:(UIViewAnimationTransition)transition duration:(CGFloat)duration;

@end
