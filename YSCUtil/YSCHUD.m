//
//  YSCHUD.m
//  YSCKit
//
//  Created by Builder on 16/7/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCHUD.h"
#import "YSCHUDAdapterManager.h"

@implementation YSCHUD
#pragma mark - 显示HUD
+ (void)showHUDOnView:(UIView *)view
              message:(NSString *)message
           edgeInsets:(UIEdgeInsets)edgeInsets
      backgroundColor:(UIColor *)backgroundColor {
    [[YSCHUDAdapterManager adapter] showHUDOnView:view message:message edgeInsets:edgeInsets backgroundColor:backgroundColor];
}

+ (void)showHUDOnView:(UIView *)view message:(NSString *)message {
    [self showHUDOnView:view
                message:message
             edgeInsets:UIEdgeInsetsZero
        backgroundColor:nil];
}
+ (void)showHUDOnView:(UIView *)view {
    [self showHUDOnView:view
                message:nil
             edgeInsets:UIEdgeInsetsZero
        backgroundColor:nil];
}

+ (void)showHUDOnView:(UIView *)view message:(NSString *)message edgeInsets:(UIEdgeInsets)edgeInsets {
    [self showHUDOnView:view
                message:message
             edgeInsets:edgeInsets
        backgroundColor:nil];
}
+ (void)showHUDOnView:(UIView *)view edgeInsets:(UIEdgeInsets)edgeInsets {
    [self showHUDOnView:view
                message:nil
             edgeInsets:edgeInsets
        backgroundColor:nil];
}

+ (void)showHUDOnKeyWindowWithMesage:(NSString *)message {
    [self showHUDOnView:KEY_WINDOW
                message:message
             edgeInsets:UIEdgeInsetsZero
        backgroundColor:nil];
}
+ (void)showHUDOnKeyWindow {
    [self showHUDOnView:KEY_WINDOW
                message:nil
             edgeInsets:UIEdgeInsetsZero
        backgroundColor:nil];
}

#pragma mark - 关闭HUD
+ (void)hideHUDOnView:(UIView *)view {
    [[YSCHUDAdapterManager adapter] hideHUDOnView:view];
}
+ (void)hideHUDOnKeyWindow {
    [self hideHUDOnView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - 显示N秒后自动关闭HUD
+ (void)showHUDThenHideOnView:(UIView *)view message:(NSString *)message afterDelay:(NSTimeInterval)delay {
    [[YSCHUDAdapterManager adapter] showHUDThenHideOnView:view message:message afterDelay:delay];
}
+ (void)showHUDThenHideOnView:(UIView *)view message:(NSString *)message {
    [self showHUDThenHideOnView:view message:message afterDelay:1];
}
+ (void)showHUDThenHideOnKeyWindowWithMessage:(NSString *)message {
    [self showHUDThenHideOnView:[UIApplication sharedApplication].keyWindow message:message];
}

#pragma mark - 显示带icon的信息
+ (void)showHUDOnView:(UIView *)view imageName:(NSString *)imageName {
    [self showHUDOnView:view imageName:imageName message:nil afterDelay:1];
}
+ (void)showHUDOnView:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message {
[self showHUDOnView:view imageName:imageName message:message afterDelay:1];
}
+ (void)showHUDOnView:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message afterDelay:(NSTimeInterval)delay {
    [[YSCHUDAdapterManager adapter] showHUDOnView:view imageName:imageName message:message afterDelay:delay];
}
@end
