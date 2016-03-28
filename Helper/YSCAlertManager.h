//
//  YSCAlertManager.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSCAlertManager : NSObject
+ (UIAlertView *)showAlertVieWithMessage:(NSString *)message;
+ (UIAlertView *)showAlertViewWithMessage:(NSString *)message block:(YSCBlock)block;
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      cancelButtonBlock:(YSCBlock)block;
@end
