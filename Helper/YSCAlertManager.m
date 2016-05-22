//
//  YSCAlertManager.m
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import "YSCAlertManager.h"

@interface YSCAlertManager () <UIAlertViewDelegate>
@property (nonatomic, copy) YSCBlock block;
@end

@implementation YSCAlertManager
- (void)dealloc {
    NSLog(@"YSCAlertManager is deallocing...");
}
+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message {
    return [self showAlertViewWithMessage:message block:nil];
}
+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message block:(YSCBlock)block {
    return [self showAlertViewWithTitle:@"提示" message:message cancelButtonTitle:@"确定" cancelButtonBlock:block];
}
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    return [self showAlertViewWithTitle:title message:message cancelButtonTitle:@"确定" cancelButtonBlock:nil];
}
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      cancelButtonBlock:(YSCBlock)block {
    YSCAlertManager *alertManager = [YSCAlertManager new];
    if (block) {
        alertManager.block = [block copy];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:alertManager
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil, nil];
    [alertView show];
    return alertView;
}

#pragma mark - UIAlertViewDelegate
// 点击取消按钮
- (void)alertViewCancel:(UIAlertView *)alertView {
    if (self.block) {
        self.block();
    }
}
@end
