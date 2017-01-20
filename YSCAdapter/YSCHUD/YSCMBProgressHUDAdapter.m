//
//  YSCMBProgressHUDAdapter.m
//  YSCKitDemo
//
//  Created by Builder on 16/10/19.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCMBProgressHUDAdapter.h"
#import "MBProgressHUD.h"

@implementation YSCMBProgressHUDAdapter

- (void)showHUDOnView:(UIView *)view
              message:(NSString *)message
           edgeInsets:(UIEdgeInsets)edgeInsets
      backgroundColor:(UIColor *)backgroundColor {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if ( ! hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.backgroundColor = (backgroundColor ? backgroundColor : [UIColor clearColor]);
    hud.label.text = message;
    hud.label.numberOfLines = 2;
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud showAnimated:YES];
    // 调整hud位置
    CGRect frame = view.bounds;
    frame.origin.x = edgeInsets.left;
    frame.origin.y = edgeInsets.top;
    frame.size.width = CGRectGetWidth(view.bounds) - (edgeInsets.left + edgeInsets.right);
    frame.size.height = CGRectGetHeight(view.bounds) - (edgeInsets.top + edgeInsets.bottom);
    hud.frame = frame;
}
- (void)hideHUDOnView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud) {
        [hud hideAnimated:YES];
    }
}
- (void)showHUDThenHideOnView:(UIView *)view message:(NSString *)message afterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if ( ! hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.backgroundColor = [UIColor clearColor];
    hud.label.text = message;
    hud.label.numberOfLines = 2;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:delay];
}
- (void)showHUDOnView:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message afterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if ( ! hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.backgroundColor = [UIColor clearColor];
    hud.label.text = message;
    hud.label.numberOfLines = 2;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:delay];
}

@end
