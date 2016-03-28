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

// 显示HUD
+ (void)showHUDLoading:(NSString *)hintString onView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = hintString;
    hud.mode = MBProgressHUDModeIndeterminate;
}
+ (void)showHUDLoadingOnKeyWindow:(NSString *)hintString {
    [self showHUDLoading:hintString onView:[UIApplication sharedApplication].keyWindow];
}

// 关闭HUD
+ (void)hideHUDLoadingOnView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    [hud hideAnimated:YES];
}
+ (void)hideHUDLoadingOnWindow {
    [self hideHUDLoadingOnView:[UIApplication sharedApplication].keyWindow];
}

// 显示N秒后自动关闭HUD
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
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
