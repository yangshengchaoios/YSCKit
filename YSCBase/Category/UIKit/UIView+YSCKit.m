//
//  UIView+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIView+YSCKit.h"
#import <objc/runtime.h>

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation UIView (YSCKit)
- (CGFloat)ysc_left {
    return self.frame.origin.x;
}
- (void)setPsk_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (CGFloat)ysc_top {
    return self.frame.origin.y;
}
- (void)setPsk_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (CGFloat)ysc_width {
    return self.frame.size.width;
}
- (void)setPsk_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (CGFloat)ysc_height {
    return self.frame.size.height;
}
- (void)setPsk_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (CGFloat)ysc_centerX {
    return self.center.x;
}
- (void)setPsk_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}
- (CGFloat)ysc_centerY {
    return self.center.y;
}
- (void)setPsk_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}
- (CGPoint)ysc_origin {
    return self.frame.origin;
}
- (void)setPsk_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)ysc_removeAllGestureRecognizers {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
}
- (void)ysc_removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}
- (void)ysc_removeAllConstraints {
    for (NSLayoutConstraint *constraint in self.constraints) {
#if __PureLayout_MinBaseSDK_iOS_8_0
        if ([self respondsToSelector:@selector(setActive:)]) {
            constraint.active = NO;
        }
#endif /* __PureLayout_MinBaseSDK_iOS_8_0 */
        
        if (constraint.firstItem) {
            [constraint.firstItem removeConstraint:constraint];
        }
        if (constraint.secondItem) {
            [constraint.secondItem removeConstraint:constraint];
        }
    }
    for (UIView *subView in self.subviews) {
        [subView ysc_removeAllConstraints];
    }
}
- (void)ysc_hideAllSubviews {
    for (UIView *subView in self.subviews) {
        subView.hidden = YES;
    }
}
- (UIViewController *)ysc_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - view边框调整
- (void)ysc_addCornerWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
- (void)ysc_makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

#pragma mark - 截图
- (UIImage *)ysc_snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    __autoreleasing UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}
- (UIImage *)ysc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self ysc_snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}
- (NSData *)ysc_snapshotPDF {
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}
- (void)ysc_addLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.masksToBounds = NO;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

/**
 *  坐标调整
 *  added by wlg
 */
- (void)ysc_topAdd:(CGFloat)add{
    CGRect frame = self.frame;
    frame.origin.y += add;
    self.frame = frame;
}
- (void)ysc_leftAdd:(CGFloat)add{
    CGRect frame = self.frame;
    frame.origin.x += add;
    self.frame = frame;
}
- (void)ysc_widthAdd:(CGFloat)add {
    CGRect frame = self.frame;
    frame.size.width += add;
    self.frame = frame;
}
- (void)ysc_heightAdd:(CGFloat)add {
    CGRect frame = self.frame;
    frame.size.height += add;
    self.frame = frame;
}
@end


//==============================================================================
//
//  手势处理
//  @Author: Builder
//
//==============================================================================
@implementation UIView (YSCKit_HandleGesture)
// 添加block属性
YSC_DYNAMIC_PROPERTY_OBJECT(tapBlock, setTapBlock, COPY_NONATOMIC, void (^)(void))

- (void)ysc_addSingleTapWithBlock:(void (^)(void))block {
    [self _ysc_addTapWithTouches:1 tapped:1 handler:block];
}
- (void)ysc_reAddSingleTapWithBlock:(void (^)(void))block {
    [self ysc_removeAllGestureRecognizers];
    [self ysc_addSingleTapWithBlock:block];
}
- (void)ysc_addDoubleTapWithBlock:(void (^)(void))block {
    [self _ysc_addTapWithTouches:1 tapped:2 handler:block];
}
- (void)ysc_reAddDoubleTapWithBlock:(void (^)(void))block {
    [self ysc_removeAllGestureRecognizers];
    [self ysc_addDoubleTapWithBlock:block];
}
- (void)ysc_removeAllTapGestures {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
    
}
- (void)_ysc_addTapWithTouches:(NSUInteger)numberOfTouches
                        tapped:(NSUInteger)numberOfTaps
                       handler:(void (^)(void))block {
    if ( ! block) {
        return;
    }
    self.tapBlock = block;
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_ysc_handleAction:)];
    gesture.numberOfTouchesRequired = numberOfTouches;
    gesture.numberOfTapsRequired = numberOfTaps;
    [self addGestureRecognizer:gesture];
}
- (void)_ysc_handleAction:(UIGestureRecognizer *)recognizer {
    if (UIGestureRecognizerStateRecognized == recognizer.state) {
        if (self.tapBlock) {
            self.tapBlock();
        }
    }
}

- (void)ysc_animateHorizontalSwipeWithSubType:(NSString *)subtype {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.2;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = kCATransitionPush;
    animation.subtype = subtype;
    [self.layer addAnimation:animation forKey:@"animation"];
}
- (void)ysc_flipWithTransition:(UIViewAnimationTransition)transition duration:(CGFloat)duration {
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:transition forView:self cache:YES];
    [UIView commitAnimations];
}
@end


//==============================================================================
//
//  自动布局动态计算
//  @Author: Builder
//
//==============================================================================
@implementation UIView (YSCKit_AutoLayout)
- (void)ysc_resetFontSize {
    [self ysc_resetFontSizeByXibWidth:YSCConfigManagerInstance.xibWidth];
}
- (void)ysc_resetFontSizeByXibWidth:(CGFloat)xibWidth {
    for (UIView *subview in self.subviews) {
        if ([subview respondsToSelector:NSSelectorFromString(@"setDoNotResetFont:")]) {
            continue;
        }
        if ([subview isMemberOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.font = AUTOLAYOUT_FONT_W(label.font.pointSize, xibWidth);
        }
        else if ([subview isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.font = AUTOLAYOUT_FONT_W(button.titleLabel.font.pointSize, xibWidth);
            button.contentEdgeInsets = UIEdgeInsetsMake(AUTOLAYOUT_LENGTH_W(button.contentEdgeInsets.top, xibWidth),
                                                        AUTOLAYOUT_LENGTH_W(button.contentEdgeInsets.left, xibWidth),
                                                        AUTOLAYOUT_LENGTH_W(button.contentEdgeInsets.bottom, xibWidth),
                                                        AUTOLAYOUT_LENGTH_W(button.contentEdgeInsets.right, xibWidth));
            
            button.titleEdgeInsets = UIEdgeInsetsMake(AUTOLAYOUT_LENGTH_W(button.titleEdgeInsets.top, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.titleEdgeInsets.left, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.titleEdgeInsets.bottom, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.titleEdgeInsets.right, xibWidth));
            
            button.imageEdgeInsets = UIEdgeInsetsMake(AUTOLAYOUT_LENGTH_W(button.imageEdgeInsets.top, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.imageEdgeInsets.left, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.imageEdgeInsets.bottom, xibWidth),
                                                      AUTOLAYOUT_LENGTH_W(button.imageEdgeInsets.right, xibWidth));
        }
        else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.font = AUTOLAYOUT_FONT_W(textField.font.pointSize, xibWidth);
        }
        else if ([subview isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)subview;
            textView.font = AUTOLAYOUT_FONT_W(textView.font.pointSize, xibWidth);
        }
        [subview ysc_resetFontSizeByXibWidth:xibWidth];
    }
}
- (void)ysc_resetConstraint {
    [self ysc_resetConstraintByXibWidth:YSCConfigManagerInstance.xibWidth];
}
- (void)ysc_resetConstraintByXibWidth:(CGFloat)xibWidth {
    if ([self respondsToSelector:NSSelectorFromString(@"setDoNotResetConstraint:")]) {
        return;
    }
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.constant > 0) {
            constraint.constant = AUTOLAYOUT_LENGTH_W((constraint.constant), xibWidth);
        }
    }
    if ([self.subviews count] > 0) {
        for (UIView *subView in self.subviews) {
            [subView ysc_resetConstraintByXibWidth:xibWidth];
        }
    }
}
@end


//==============================================================================
//
//  从xib加载新的view
//  @Author: Builder
//
//==============================================================================
@implementation UIView (YSCKit_LoadFromNib)
+ (instancetype)ysc_loadFromNib {
    NSString *nibName = NSStringFromClass(self.class);
    if ([@"UIView" isEqualToString:nibName]) {
        return nil;
    }
    return [self ysc_loadFromNibName:nibName];
}
+ (instancetype)ysc_loadFromNibName:(NSString *)nibName {
    return [self ysc_loadFromNibName:nibName index:0];
}
+ (instancetype)ysc_loadFromNibName:(NSString *)nibName index:(NSInteger)index {
    if ( ! nibName || ! IS_NIB_EXISTS(nibName) || index < 0) {
        return nil;
    }
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    if (index >= [viewArray count]) {
        return nil;
    }
    return viewArray[index];
}
@end


