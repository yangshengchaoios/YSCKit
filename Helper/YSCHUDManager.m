//
//  YSCHUDManager.m
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import "YSCHUDManager.h"
#import "MBProgressHUD.h"

@implementation YSCHUDManager

#pragma mark - 显示HUD
+ (void)showHUDOnView:(UIView *)view
              message:(NSString *)message
           edgeInsets:(UIEdgeInsets)edgeInsets
      backgroundColor:(UIColor *)backgroundColor {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (backgroundColor) {
        hud.backgroundColor = backgroundColor;
    }
    [hud mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(edgeInsets);
    }];
    hud.label.text = message;
    hud.mode = MBProgressHUDModeIndeterminate;
}
+ (void)showHUDOnView:(UIView *)view backgroundColor:(UIColor *)backgroundColor edgeInsets:(UIEdgeInsets)edgeInsets {
    [self showHUDOnView:view message:nil edgeInsets:edgeInsets backgroundColor:backgroundColor];
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
+ (void)showHUDOnView:(UIView *)view showsMask:(BOOL)showsMask {
    [self showHUDOnView:view
                message:nil
             edgeInsets:UIEdgeInsetsZero
        backgroundColor:showsMask ? kDefaultViewColor : nil];
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
+ (void)showHUDOnView:(UIView *)view edgeInsets:(UIEdgeInsets)edgeInsets showsMask:(BOOL)showsMask {
    [self showHUDOnView:view
                message:nil
             edgeInsets:edgeInsets
        backgroundColor:showsMask ? kDefaultViewColor : nil];
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
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    [hud hideAnimated:YES];
}
+ (void)hideHUDOnWindow {
    [self hideHUDOnView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - 显示N秒后自动关闭HUD
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (nil == hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.label.text = text;
    hud.mode = MBProgressHUDModeText;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:delay];
}
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view {
    [self showHUDThenHide:text onView:view afterDelay:1];
}
+ (void)showHUDThenHideOnKeyWindow:(NSString *)text {
    [self showHUDThenHide:text onView:[UIApplication sharedApplication].keyWindow];
}

@end
