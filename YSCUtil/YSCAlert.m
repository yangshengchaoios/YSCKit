//
//  YSCAlert.m
//  YSCKit
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCAlert.h"
#import <objc/runtime.h>

#define kIsUseAlertController   IOS8_OR_LATER       // 是否启用UIAlertController，默认从iOS8开始启用

#if ! kIsUseAlertController
// 扩展UIAlertView
@implementation UIAlertView (YSCKit_iOS7)
YSC_DYNAMIC_PROPERTY_LAZYLOAD(actionHandlerDictionary, NSMutableDictionary *, [NSMutableDictionary dictionary])
YSC_DYNAMIC_PROPERTY_LAZYLOAD(textFields, NSMutableArray *, [NSMutableArray array])
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    id key = @(buttonIndex);
    void (^block)(void) = [self actionHandlerDictionary][key];
    if (block) {
        block();
    }
}
@end

// 扩展UIActionSheet
@implementation UIActionSheet (YSCKit_iOS7)
YSC_DYNAMIC_PROPERTY_LAZYLOAD(actionHandlerDictionary, NSMutableDictionary *, [NSMutableDictionary dictionary])
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    id key = @(buttonIndex);
    void (^block)(void) = [self actionHandlerDictionary][key];
    if (block) {
        block();
    }
}
@end
#endif



//=============================================================
//
// 封装Alert和ActionSheet功能
//  iOS7 - UIAlertView和UIActionSheet
//  iOS8及以后 - UIAlertControl
//
//=============================================================
@interface YSCAlert ()
@property (nonatomic, assign) YSCAlertControllerStyle preferredStyle;
@property (nonatomic, strong) id alertResponder;
@end

@implementation YSCAlert
- (void)dealloc {
    PRINT_DEALLOCING
}
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message {
    return [self alertWithTitle:title message:message style:YSCAlertControllerStyleAlert];
}
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message style:(YSCAlertControllerStyle) style {
    YSCAlert *alertUtil = [YSCAlert new];
    alertUtil.title = title;
    alertUtil.message = message;
    alertUtil.preferredStyle = style;
#if kIsUseAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyle)style];
    alertUtil.alertResponder = alertController;
#else
    if (YSCAlertControllerStyleActionSheet == style) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.delegate = actionSheet;
        alertUtil.alertResponder = actionSheet;
    }
    else if (YSCAlertControllerStyleAlert == style) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        alertView.delegate = alertView;
        alertUtil.alertResponder = alertView;
    }
#endif
    return alertUtil;
}

- (NSArray *)textFields {
#if kIsUseAlertController
    UIAlertController *alertController = self.alertResponder;
    return alertController.textFields;
#else
    UIAlertView *alertView = self.alertResponder;
    return alertView.textFields;
#endif
}

/** 添加普通按钮 */
- (void)addActionWithTitle:(NSString *)title handler:(nullable void (^)(void))block {
    [self addActionWithTitle:title style:YSCAlertActionStyleDefault enable:YES handler:block];
}
/** 添加取消功能，始终在最后的位置 */
- (void)addCancelActionWithTitle:(NSString *)title handler:(nullable void (^)(void))block {
    [self addActionWithTitle:title style:YSCAlertActionStyleCancel enable:YES handler:block];
}
/** 添加删除功能，红色字体 */
- (void)addDestructiveActionWithTitle:(NSString *)title handler:(nullable void (^)(void))block {
    [self addActionWithTitle:title style:YSCAlertActionStyleDestructive enable:YES handler:block];
}
/** 根据按钮类型添加功能 */
- (void)addActionWithTitle:(NSString *)title style:(YSCAlertActionStyle)style enable:(BOOL)enable handler:(nullable void (^)(void))block {
#if kIsUseAlertController
    UIAlertController *alertController = self.alertResponder;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyle)style handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block();
        }
    }];
    alertAction.enabled = enable;
    [alertController addAction:alertAction];
#else
    // 定位button的位置
    NSInteger buttonIndex = -1;
    if (YSCAlertControllerStyleActionSheet == self.preferredStyle) {
        UIActionSheet *actionSheet = self.alertResponder;
        buttonIndex = [actionSheet addButtonWithTitle:title];
        if (YSCAlertActionStyleCancel == style) {
            actionSheet.cancelButtonIndex = buttonIndex;
        }
        else if (YSCAlertActionStyleDestructive == style) {
            actionSheet.destructiveButtonIndex = buttonIndex;
        }
        if (block) {
            actionSheet.actionHandlerDictionary[@(buttonIndex)] = block;
        }
        else {
            [actionSheet.actionHandlerDictionary removeObjectForKey:@(buttonIndex)];
        }
    }
    else if (YSCAlertControllerStyleAlert == self.preferredStyle) {
        UIAlertView *alertView = self.alertResponder;
        buttonIndex = [alertView addButtonWithTitle:title];
        if (YSCAlertActionStyleCancel == style) {
            alertView.cancelButtonIndex = buttonIndex;
        }
        if (block) {
            alertView.actionHandlerDictionary[@(buttonIndex)] = block;
        }
        else {
            [alertView.actionHandlerDictionary removeObjectForKey:@(buttonIndex)];
        }
    }
#endif
}

/** 添加textField */
- (void)addTextFieldWithHandler:(nullable void (^)(UITextField *textField))block {
    if (YSCAlertControllerStyleAlert == self.preferredStyle) {
#if kIsUseAlertController
        UIAlertController *alertController = self.alertResponder;
        [alertController addTextFieldWithConfigurationHandler:block];
#else
        UIAlertView *alertView = (UIAlertView *)self.alertResponder;
        UITextField *textField = nil;
        if (0 == [alertView.textFields count]) {
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            textField = [alertView textFieldAtIndex:0];
        }
        else if (1 == [alertView.textFields count]) {
            alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            textField = [alertView textFieldAtIndex:1];
        }
        if (textField) {
            [alertView.textFields addObject:textField];
        }
        if (block) {
            block(textField);
        }
#endif
    }
}

/** 显示alert */
+ (void)showAlertViewWithMessage:(NSString *)message {
    YSCAlert *alert = [YSCAlert alertWithTitle:@"" message:message style:YSCAlertControllerStyleAlert];
    [alert addCancelActionWithTitle:@"确定" handler:nil];
    [alert showOnViewController:YSCManagerInstance.currentViewController];
}
- (void)showOnViewController:(UIViewController *)viewController {
    [self showOnViewController:viewController animated:YES completion:nil];
}
- (void)showOnViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
#if kIsUseAlertController
    [viewController presentViewController:self.alertResponder animated:animated completion:completion];
#else
    if (YSCAlertControllerStyleActionSheet == self.preferredStyle) {
        [((UIActionSheet *)self.alertResponder) showInView:viewController.view];
    }
    else if (YSCAlertControllerStyleAlert == self.preferredStyle) {
        [((UIAlertView *)self.alertResponder) show];
    }
#endif
}
@end



//=============================================================
//
//  可以自定义显示内容的alertView
//
//=============================================================
@interface YSCCustomAlertView ()
@property (nonatomic, assign) YSCAlertControllerStyle preferredStyle;
@end
@implementation YSCCustomAlertView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isDismissByClickingOutOfArea = YES;
        self.animateDuration = 0.25;
    }
    return self;
}
+ (instancetype)showCustomView:(nonnull UIView *)customView style:(YSCAlertControllerStyle)style {
    return [self showCustomView:customView onView:KEY_WINDOW style:style];
}
+ (instancetype)showCustomView:(nonnull UIView *)customView onView:(nonnull UIView *)superView {
    return [self showCustomView:customView onView:superView style:YSCAlertControllerStyleAlert];
}
+ (instancetype)showCustomView:(nonnull UIView *)customView onView:(nonnull UIView *)superView style:(YSCAlertControllerStyle)style {
    if ( ! customView || ! superView) {
        return nil;
    }
    customView.tag = 92378;
    customView.hidden = NO;
    
    // 1. 创建背景view
    YSCCustomAlertView *customAlertView = [[YSCCustomAlertView alloc] initWithFrame:superView.bounds];
    customAlertView.preferredStyle = style;
    customAlertView.backgroundColor = RGBA(0, 0, 0, 0.3);
    [customAlertView addSubview:customView];
    [superView addSubview:customAlertView];
    
    // 2. 添加点击空白处关闭手势
    __weak YSCCustomAlertView *tempAlertView = customAlertView;// 这里必须是弱引用！否则无法dealloc
    UITapGestureRecognizer *tap = [UITapGestureRecognizer ysc_recognizerWithBlock:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if ( ! CGRectContainsPoint(customView.frame, location) &&
            tempAlertView.isDismissByClickingOutOfArea) {
            [tempAlertView dismiss];
        }
    }];
    tap.cancelsTouchesInView = NO;// 底层接收到点击手势后仍然需要继续往子view传递！
    [customAlertView addGestureRecognizer:tap];
    
    // 3. 初始化customView坐标
    if (YSCAlertControllerStyleAlert == style) {
        customAlertView.isDismissByClickingOutOfArea = NO;// 如果是alert形式，则默认点击空白处不消失
        customView.center = customAlertView.center;
        customView.alpha = 0;
    }
    else {
        customAlertView.isDismissByClickingOutOfArea = YES;
        customView.ysc_top = customAlertView.ysc_height;
        customView.ysc_centerX = customAlertView.ysc_centerX;
    }
    
    // 4. show
    [UIView animateWithDuration:customAlertView.animateDuration animations:^{
        if (YSCAlertControllerStyleActionSheet == style) {
            customView.ysc_top = customAlertView.ysc_height - customView.ysc_height;
            if (customView.alpha != 1) {
                customView.alpha = 1;
            }
        }
        else {
            customView.alpha = 1;
        }
    }];
    
    return customAlertView;
}
- (void)dismiss {
    UIView *customView = [self viewWithTag:92378];
    [UIView animateWithDuration:self.animateDuration animations:^{
        if (YSCAlertControllerStyleActionSheet == self.preferredStyle) {
            customView.ysc_top = self.ysc_height;
        }
        else {
            customView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.didDismissBlock) {
            self.didDismissBlock();
        }
        [customView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
- (void)dealloc {
    PRINT_DEALLOCING
}
@end

