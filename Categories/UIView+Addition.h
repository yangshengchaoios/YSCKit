//
//  UIView+Addition.h
//  TGO3
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>
#import "ZYQAssetPickerController.h"

@interface UIView (Addition)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

/**
 *  移除view上所有的手势操作
 */
- (void)removeGestureRecognizers;

#pragma mark - 图片选择器
+ (UIActionSheet *)showImagePickerActionSheetWithDelegate:(id<UINavigationControllerDelegate,
                                                           UIImagePickerControllerDelegate,
                                                           ZYQAssetPickerControllerDelegate>)delegate
                                            allowsEditing:(BOOL)allowsEditing
                                              singleImage:(BOOL)singleImage
                                        numberOfSelection:(NSInteger)numberOfSelection
                                         onViewController:(UIViewController *)viewController;



#pragma mark - view边框调整
+ (void)makeCircleForView:(UIView *)view;
- (void)makeCircleView;
+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius;
- (void)makeRoundWithRadius:(CGFloat)radius;

#pragma mark - 添加手势
/**
 *	实现水平方向上左右滑动的动画效果
 *
 *	@param	view	需要做动画的view
 *	@param	subtype	方向 kCATransitionFromRight、kCATransitionFromLeft
 */
+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype;
- (void)animateHorizontalSwipeWithSubType:(NSString *)subtype;
+ (void)add1fingerHorizontalSwipe:(UIView *)view
                     swipeToRight:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))toRightBlock
                      swipeToLeft:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))toLeftBlock;


#pragma mark - 截图
+ (UIImage *)screenshotOfView:(UIView *) view;
- (UIImage *)screenshotOfView;


#pragma mark - 递归遍历所有子view
+ (void)clearBackgroundColorOfView:(UIView *)view;
- (void)clearBackgroundColorOfView;

+ (void)resetFontSizeOfView:(UIView *)view;
- (void)resetFontSizeOfView;


#pragma mark - 计算自动布局的size
- (void)autoLayoutSize;

/**
 *  这里的HUD和AlertView主要用于非BaseViewController的情况下调用
 *
 */
#pragma mark -  show & hide HUD
+ (MBProgressHUD *)showHUDLoadingOnWindow:(NSString *)hintString;
+ (void)hideHUDLoadingOnWindow;
+ (void)showResultThenHideOnWindow:(NSString *)resultString;

#pragma mark - alert view
+ (UIAlertView *)showAlertVieWithMessage:(NSString *)message;
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;

#pragma mark - current view controller
+ (UIViewController *)currentViewController;
+ (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)viewController;

@end
