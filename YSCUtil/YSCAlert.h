//
//  YSCAlert.h
//  YSCKit
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN
/** 定义按钮类型 */
typedef NS_ENUM(NSInteger, YSCAlertActionStyle) {
    YSCAlertActionStyleDefault = 0,
    YSCAlertActionStyleCancel,              // 取消功能，始终在最后的位置
    YSCAlertActionStyleDestructive          // 删除功能，红色字体
};

/** 定义alert显示类型 */
typedef NS_ENUM(NSInteger, YSCAlertControllerStyle) {
    YSCAlertControllerStyleActionSheet = 0, // actionSheet外观
    YSCAlertControllerStyleAlert            // alert外观
};


//=============================================================
//
// 封装Alert和ActionSheet功能
//  iOS7 - UIAlertView和UIActionSheet
//  iOS8及以后 - UIAlertControl
//
//=============================================================
@interface YSCAlert : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign, readonly) YSCAlertControllerStyle preferredStyle;
@property (nonatomic, strong, readonly) id alertResponder;
@property (nullable, nonatomic, readonly) NSArray *textFields;

/** 创建对象 */
+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
/** 根据类型style创建对象 */
+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message style:(YSCAlertControllerStyle) style;

/** 添加普通按钮 */
- (void)addActionWithTitle:(nullable NSString *)title handler:(nullable void (^)(void))block;
/** 添加取消功能，始终在最后的位置 */
- (void)addCancelActionWithTitle:(nullable NSString *)title handler:(nullable void (^)(void))block;
/** 添加删除功能，红色字体 */
- (void)addDestructiveActionWithTitle:(nullable NSString *)title handler:(nullable void (^)(void))block;
/** 根据按钮类型添加功能 */
- (void)addActionWithTitle:(nullable NSString *)title style:(YSCAlertActionStyle)style enable:(BOOL)enable handler:(nullable void (^)(void))block;

/** 
 *  添加textField
 *  针对<=iOS7的情况最多只能添加两个UITextField
 */
- (void)addTextFieldWithHandler:(nullable void (^)(UITextField *textField))block;

/** 显示alert */
+ (void)showAlertViewWithMessage:(NSString *)message;
- (void)showOnViewController:(UIViewController *)viewController;
- (void)showOnViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(nullable void (^)(void))completion;
@end


//=============================================================
//
//  @desc
//      可以自定义显示内容的alertView
//  @notice
//      1. 如果显示alertView，点击内容view之外默认不关闭
//      2. 如果显示actionSheet，点击内容view之外默认关闭
//  @useage
//      self.customAlertView = [YSCCustomAlertView showCustomView:CUSTOM_VIEW onView:self.view];
//      ......
//      [self.customAlertView dismiss];
//
//=============================================================
@interface YSCCustomAlertView : UIView
@property (nonatomic, assign) CGFloat animateDuration;
/** 点击范围之外是否dismiss */
@property (nonatomic, assign) BOOL isDismissByClickingOutOfArea;
@property (nonatomic, assign, readonly) YSCAlertControllerStyle preferredStyle;
@property (nonatomic, copy) dispatch_block_t didDismissBlock;

+ (instancetype)showCustomView:(nonnull UIView *)customView style:(YSCAlertControllerStyle)style;
+ (instancetype)showCustomView:(nonnull UIView *)customView onView:(nonnull UIView *)superView;
+ (instancetype)showCustomView:(nonnull UIView *)customView onView:(nonnull UIView *)superView style:(YSCAlertControllerStyle)style;
- (void)dismiss;
@end
NS_ASSUME_NONNULL_END
