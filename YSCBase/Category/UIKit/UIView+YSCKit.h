//
//  UIView+YSCKit.h
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
@interface UIView (YSCKit)
@property (nonatomic) CGFloat ysc_left;
@property (nonatomic) CGFloat ysc_top;
@property (nonatomic) CGFloat ysc_width;
@property (nonatomic) CGFloat ysc_height;
@property (nonatomic) CGFloat ysc_centerX;
@property (nonatomic) CGFloat ysc_centerY;
@property (nonatomic) CGPoint ysc_origin;

- (void)ysc_removeAllGestureRecognizers;
- (void)ysc_removeAllSubviews;
- (void)ysc_removeAllConstraints;       //移除view(包括subviews)上所有constraints
- (void)ysc_hideAllSubviews;
- (UIViewController *)ysc_viewController;

/** view边框 */
- (void)ysc_addCornerWithRadius:(CGFloat)radius;
- (void)ysc_makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width;

/** view截图 */
- (UIImage *)ysc_snapshotImage;
- (UIImage *)ysc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
- (NSData *)ysc_snapshotPDF;
- (void)ysc_addLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/** 
 *  坐标调整
 *  added by wlg
 */
- (void)ysc_topAdd:(CGFloat)add;
- (void)ysc_leftAdd:(CGFloat)add;
- (void)ysc_widthAdd:(CGFloat)add;
- (void)ysc_heightAdd:(CGFloat)add;
@end


//==============================================================================
//
//  手势处理
//  @Author: Builder
//
//==============================================================================
@interface UIView (YSCKit_HandleGesture)
- (void)ysc_addSingleTapWithBlock:(void (^)(void))block;
- (void)ysc_reAddSingleTapWithBlock:(void (^)(void))block;
- (void)ysc_addDoubleTapWithBlock:(void (^)(void))block;
- (void)ysc_reAddDoubleTapWithBlock:(void (^)(void))block;
- (void)ysc_removeAllTapGestures;

/**
 *	实现水平方向上左右滑动的动画效果
 *
 *	@param	subtype	方向 kCATransitionFromRight、kCATransitionFromLeft
 */
- (void)ysc_animateHorizontalSwipeWithSubType:(NSString *)subtype;
- (void)ysc_flipWithTransition:(UIViewAnimationTransition)transition duration:(CGFloat)duration;
@end


//==============================================================================
//
//  自动布局动态计算
//  @Author: Builder
//
//==============================================================================
@interface UIView (YSCKit_AutoLayout)
/**
 *  如果存在自定义属性doNotResetFont，则该view不重置字体大小
 */
- (void)ysc_resetFontSize;
- (void)ysc_resetFontSizeByXibWidth:(CGFloat)xibWidth;
/**
 *  如果存在自定义属性doNotResetConstraint，则该view不重置约束
 */
- (void)ysc_resetConstraint;
- (void)ysc_resetConstraintByXibWidth:(CGFloat)xibWidth;
@end


//==============================================================================
//
//  从xib加载新的view
//  @Author: Builder
//
//==============================================================================
@interface UIView (YSCKit_LoadFromNib)
+ (instancetype)ysc_loadFromNib;
+ (instancetype)ysc_loadFromNibName:(NSString *)nibName;
+ (instancetype)ysc_loadFromNibName:(NSString *)nibName index:(NSInteger)index;
@end


