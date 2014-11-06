//
//  UIView+Addition.m
//  TGO3
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


- (void)removeGestureRecognizers {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }    
}

#pragma mark - 图片选择器
+ (UIActionSheet *)showImagePickerActionSheetWithDelegate:(id<UINavigationControllerDelegate,
                                                           UIImagePickerControllerDelegate,
                                                           ZYQAssetPickerControllerDelegate>)delegate
                                            allowsEditing:(BOOL)allowsEditing
                                              singleImage:(BOOL)singleImage
                                        numberOfSelection:(NSInteger)numberOfSelection
                                         onViewController:(UIViewController *)viewController {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_addButtonWithTitle:@"拍摄照片"
                               handler:^{
                                   UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                                   if ( ! [UIImagePickerController isSourceTypeAvailable:sourceType]) {
                                       [UIView showResultThenHideOnWindow:@"您的设备无法通过此方式获取照片"];
                                       return;
                                   }
                                   else {
                                       UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                       imagePickerController.delegate = delegate;
                                       imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                       imagePickerController.allowsEditing = allowsEditing;
                                       imagePickerController.sourceType = sourceType;
                                       [viewController presentViewController:imagePickerController animated:YES completion:nil];
                                   }
                               }];
    
    [actionSheet bk_addButtonWithTitle:@"选取照片"
                               handler:^{
                                   UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                   if ( ! [UIImagePickerController isSourceTypeAvailable:sourceType]) {
                                       [UIView showResultThenHideOnWindow:@"您的设备无法通过此方式获取照片"];
                                       return;
                                   }
                                   else {
                                       if (singleImage) {//选择相册里单张图片
                                           UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                           imagePickerController.delegate = delegate;
                                           imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                           imagePickerController.allowsEditing = allowsEditing;
                                           imagePickerController.sourceType = sourceType;
                                           [viewController presentViewController:imagePickerController animated:YES completion:nil];
                                       }
                                       else {//多张图片
                                           ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
                                           picker.delegate = delegate;
                                           picker.maximumNumberOfSelection = numberOfSelection;
                                           picker.assetsFilter = [ALAssetsFilter allPhotos];
                                           picker.showEmptyGroups = NO;
                                           picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                               if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                                                   NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                                                   return duration >= 5;
                                               } else {
                                                   return YES;
                                               }
                                           }];
                                           [viewController presentViewController:picker animated:YES completion:NULL];
                                       }
                                   }
                               }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet showInView:viewController.view.window];
    return actionSheet;
}


#pragma mark - view边框调整
+ (void)makeCircleForView:(UIView *)view {
    ReturnWhenObjectIsEmpty(view);
    [view makeCircleView];
}
- (void)makeCircleView {
    [self makeRoundWithRadius:self.bounds.size.width / 2.0];
}

+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius {
    ReturnWhenObjectIsEmpty(view);
    [view makeRoundWithRadius:radius];
}
- (void)makeRoundWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}


#pragma mark - 添加手势
/**
 *	实现水平方向上左右滑动的动画效果
 *
 *	@param	view	需要做动画的view
 *	@param	subtype	方向 kCATransitionFromRight、kCATransitionFromLeft
 */
+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype {
    ReturnWhenObjectIsEmpty(view);
    [view animateHorizontalSwipeWithSubType:subtype];
}
- (void)animateHorizontalSwipeWithSubType:(NSString *)subtype {
    CATransition *animation = [CATransition animation];
    animation.duration = kDefaultAnimationDuration02;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = kCATransitionPush;
    animation.subtype = subtype;
    [self.layer addAnimation:animation forKey:@"animation"];
}
+ (void)add1fingerHorizontalSwipe:(UIView *)view
                     swipeToRight:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))toRightBlock
                      swipeToLeft:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))toLeftBlock {
    UISwipeGestureRecognizer *swipeRight = [UISwipeGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        NSLog(@"向右滑动，看前面一页");
        if (toRightBlock) {
            toRightBlock(sender, state, location);
        }
    }];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        NSLog(@"向左滑动，看后面一页");
        if (toLeftBlock) {
            toLeftBlock(sender, state, location);
        }
    }];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeLeft];
}


#pragma mark - 截图
//返回UIView全屏截图
+ (UIImage *)screenshotOfView:(UIView *) view {
    ReturnNilWhenObjectIsEmpty(view);
    return [view screenshotOfView];
}

- (UIImage *)screenshotOfView {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    __autoreleasing UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}




#pragma mark - 递归遍历所有子view
//设置调整布局相关的view背景颜色为空
+ (void)clearBackgroundColorOfAllSpaceLabels:(UIView *)view {
    if ( ! [view isMemberOfClass:[UIView class]]) {
        return;
    }
    
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]] &&
            subview.tag >= 1000) {
                subview.backgroundColor = [UIColor clearColor];
        }
        else if ([subview isKindOfClass:[UIView class]]) {
            [self clearBackgroundColorOfAllSpaceLabels:subview];
        }
    }
}


#pragma mark - 计算自动布局的size
- (void)autoLayoutSize {
    CGSize size = AUTOLAYOUT_SIZE(self.frame.size);
    self.width = size.width;
    self.height = size.height;
}


#pragma mark -  show & hide HUD
+ (MBProgressHUD *)showHUDLoadingOnWindow:(NSString *)hintString {
    UIView *view = [UIApplication sharedApplication].keyWindow;
	MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	if (hud) {
		[hud show:YES];
	}
	else {
		hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	}
	hud.labelText = hintString;
	hud.mode = MBProgressHUDModeIndeterminate;
	return hud;
}

+ (void)hideHUDLoadingOnWindow {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	[hud hide:YES];
}

+ (void)showResultThenHideOnWindow:(NSString *)resultString {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	if (!hud) {
		hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	}
	hud.labelText = resultString;
	hud.mode = MBProgressHUDModeText;
	[hud show:YES];
	[hud hide:YES afterDelay:1];
}

#pragma mark - alert view
+ (UIAlertView *)showAlertVieWithMessage:(NSString *)message {
    return [self showAlertViewWithTitle:@"提示" andMessage:message];
}

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
	[alertView bk_setCancelButtonWithTitle:@"确定" handler:nil];
	[alertView show];
	return alertView;
}

#pragma mark - current view controller
+ (UIViewController *)currentViewController {
    UIViewController *viewController = KeyWindow.rootViewController;
    return [UIView getVisibleViewControllerFrom:viewController];
    NSLog(@"current viewcontroller : %@", viewController);
    return viewController;
}

+ (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [UIView getVisibleViewControllerFrom:[((UINavigationController *) viewController) visibleViewController]];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [UIView getVisibleViewControllerFrom:[((UITabBarController *) viewController) selectedViewController]];
    } else {
        if (viewController.presentedViewController) {
            return [UIView getVisibleViewControllerFrom:viewController.presentedViewController];
        } else {
            return viewController;
        }
    }
}


@end
