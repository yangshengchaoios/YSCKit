//
//  UIView+YSCKit.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "UIView+YSCKit.h"

@implementation UIView (YSCKit)
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
- (CGPoint)origin {
    return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)removeAllGestureRecognizers {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }    
}
- (void)removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}
- (void)removeAllConstraints {
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
        [subView removeAllConstraints];
    }
}
- (void)hideAllSubviews {
    for (UIView *subView in self.subviews) {
        subView.hidden = YES;
    }
}

#pragma mark - view边框调整
+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius {
    RETURN_WHEN_OBJECT_IS_EMPTY(view);
    [view makeRoundWithRadius:radius];
}
- (void)makeRoundWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
+ (void)makeBorderForView:(UIView *)view {
    [self makeBorderForView:view withColor:kDefaultBorderColor borderWidth:1];
}
- (void)makeBorderLine {
    [self makeBorderWithColor:kDefaultBorderColor borderWidth:1];
}
+ (void)makeBorderForView:(UIView *)view withColor:(UIColor *)color borderWidth:(CGFloat)width {
    RETURN_WHEN_OBJECT_IS_EMPTY(view);
    [view makeBorderWithColor:color borderWidth:width];
}
- (void)makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = AUTOLAYOUT_LENGTH(width);
}

#pragma mark - 截图
+ (UIImage *)screenshotOfView:(UIView *) view {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(view)
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
+ (void)resetSizeOfView:(UIView *)view {
    [self resetFontSizeOfView:view];
    [self resetConstraintOfView:view];
}
+ (void)resetFontSizeOfView:(UIView *)view {
    RETURN_WHEN_OBJECT_IS_EMPTY(view);
    [view resetFontSizeOfView];
}
- (void)resetFontSizeOfView {
    for (UIView *subview in self.subviews) {
        if ([subview respondsToSelector:@selector(setCloseResetFontAndConstraint:)]) {
            continue;
        }
        if ([subview isMemberOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.font = AUTOLAYOUT_FONT(label.font.pointSize);
        }
        else if ([subview isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.font = AUTOLAYOUT_FONT(button.titleLabel.font.pointSize);
        }
        else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.font = AUTOLAYOUT_FONT(textField.font.pointSize);
        }
        else if ([subview isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)subview;
            textView.font = AUTOLAYOUT_FONT(textView.font.pointSize);
        }
        [subview resetFontSizeOfView];
    }
}
+ (void)resetConstraintOfView:(UIView *)view {
    RETURN_WHEN_OBJECT_IS_EMPTY(view);
    [view resetConstraintOfView];
}
- (void)resetConstraintOfView {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.constant > 0) {
            constraint.constant = AUTOLAYOUT_LENGTH(constraint.constant);
        }
    }
    if ([self respondsToSelector:@selector(setCloseResetFontAndConstraint:)]) {
        return;
    }
    
    if ([self.subviews count] > 0) {
        for (UIView *subView in self.subviews) {
            [subView resetConstraintOfView];
        }
    }
}
@end



@implementation UIView (Gesture)
+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype {
    RETURN_WHEN_OBJECT_IS_EMPTY(view);
    [view animateHorizontalSwipeWithSubType:subtype];
}
- (void)animateHorizontalSwipeWithSubType:(NSString *)subtype {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.2;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = kCATransitionPush;
    animation.subtype = subtype;
    [self.layer addAnimation:animation forKey:@"animation"];
}
+ (void)flipView:(UIView *)view withTransition:(UIViewAnimationTransition)transition duration:(CGFloat)duration {
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:transition forView:view cache:YES];
    [UIView commitAnimations];
}
@end
