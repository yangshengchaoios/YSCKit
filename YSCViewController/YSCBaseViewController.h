//
//  YSCBaseViewController.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCTipsView.h"

/** 定义导航条样式 */
typedef NS_ENUM(NSInteger, YSCNaviType) {
    YSCNaviTypeDefault = 0,             //默认系统导航条
    YSCNaviTypeCustomize,               //自定义导航条
    YSCNaviTypeNone,                    //没有导航条
};

/** 定义系统导航条返回按钮的箭头样式 */
typedef NS_ENUM(NSInteger, YSCGoBackButtonType) {
    YSCGoBackButtonTypeDefault = 0,             //默认自定义箭头图片
    YSCGoBackButtonTypeSystemWithPreTitle,      //返回箭头后面带前一个页面的标题
    YSCGoBackButtonTypeSystemWithoutPreTitle,   //返回箭头后面不带前一个页面的标题
};


/**
 * 自定义导航条
 */
@interface YSCTitleView : UIView
@property (nonatomic, strong) UIView *statusBarView;       // 20
@property (nonatomic, strong) UIButton *goBackButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bottomLineLabel;

+ (instancetype)createTitleView;
@end


/**
 * @brief viewController基类
 * 
 * 功能：
 *      1. 统一设置系统导航条(返回箭头图片、背景图片)
 *      2. 可以自定义导航条titleView
 *      3. 全屏加载提示tipsView
 *      4. 监控APP进入/恢复自后台
 *      5. 管理网络请求(dealloc时取消所有未完成的网络请求)
 */
@interface YSCBaseViewController : UIViewController
@property (nonatomic, strong) YSCTitleView *yscTitleView;
/** 只有第一次加载失败才会显示tipsView */
@property (nonatomic, strong) YSCTipsView *yscTipsView;
@property (nonatomic, copy) YSCObjectBlock block;   //回调上一级的block


#pragma mark - #pragma mark - 自定导航条TitleView
/** 自定义titleView必须继承自YSCTitleView */
- (NSString *)titleViewName;
- (void)resetTitle:(NSString *)title;


#pragma mark - 系统导航条NavigationBar
/** 是否隐藏系统导航条 */
- (BOOL)isHideSystemNaviBar;
- (IBAction)backButtonClicked:(id)sender;


#pragma mark - TipsView
- (void)showTipsWithMessage:(NSString *)message buttonAction:(YSCBlock)buttonAction;
- (void)removeTipsView;


#pragma mark - 监控APP恢复运行、按下home键
/** APP恢复运行 */
- (void)didAppBecomeActive;
/** APP进入后台 */
- (void)didAppEnterBackground;


#pragma mark - 管理网络请求队列
/** 添加网络请求 */
- (void)addRequestId:(NSString *)requestId forKey:(NSString *)requestKey;
/** 移除网络请求 */
- (void)removeRequestIdByKey:(NSString *)requestKey;
/** 取消网络请求 */
- (void)cancelRequestIdByKey:(NSString *)requestKey;
@end
