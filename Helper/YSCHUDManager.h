//
//  YSCHUDManager.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSCHUDManager : NSObject

// 显示HUD
+ (void)showHUDOnView:(UIView *)view
              message:(NSString *)message
           edgeInsets:(UIEdgeInsets)edgeInsets
      backgroundColor:(UIColor *)backgroundColor;

+ (void)showHUDOnView:(UIView *)view message:(NSString *)message;
+ (void)showHUDOnView:(UIView *)view;
+ (void)showHUDOnView:(UIView *)view showsMask:(BOOL)showsMask;

+ (void)showHUDOnView:(UIView *)view message:(NSString *)message edgeInsets:(UIEdgeInsets)edgeInsets;
+ (void)showHUDOnView:(UIView *)view edgeInsets:(UIEdgeInsets)edgeInsets;
+ (void)showHUDOnView:(UIView *)view edgeInsets:(UIEdgeInsets)edgeInsets showsMask:(BOOL)showsMask;

+ (void)showHUDOnKeyWindowWithMesage:(NSString *)hintString;
+ (void)showHUDOnKeyWindow;

// 关闭HUD
+ (void)hideHUDOnView:(UIView *)view;
+ (void)hideHUDOnWindow;

// 显示N秒后自动关闭HUD
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view afterDelay:(NSTimeInterval)delay;
+ (void)showHUDThenHide:(NSString *)text onView:(UIView *)view;
+ (void)showHUDThenHideOnKeyWindow:(NSString *)text;

@end
