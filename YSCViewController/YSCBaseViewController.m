//
//  YSCBaseViewController.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCBaseViewController.h"
#import <objc/message.h>

@implementation YSCTitleView
+ (instancetype)createTitleView {
    YSCTitleView *titleView = [YSCTitleView new];
    titleView.ysc_width = SCREEN_WIDTH;
    titleView.backgroundColor = YSCConfigManagerInstance.defaultNaviBackgroundColor;
    titleView.ysc_height = 64;
    
    titleView.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    titleView.statusBarView.backgroundColor = YSCConfigManagerInstance.defaultStatusBackgroundColor;
    [titleView addSubview:titleView.statusBarView];
    
    titleView.goBackButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 20, 40, 40)];
    titleView.goBackButton.backgroundColor = [UIColor clearColor];
    titleView.goBackButton.ysc_centerY = 20 + 22;
    UIImage *goBackImage = [UIImage imageNamed:YSCConfigManagerInstance.defaultNaviGoBackImageName];
    [titleView.goBackButton setImage:goBackImage forState:UIControlStateNormal];
    [titleView addSubview:titleView.goBackButton];
    
    titleView.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleView.ysc_width * 0.6, 40)];
    titleView.titleLabel.textColor = YSCConfigManagerInstance.defaultNaviTitleColor;
    titleView.titleLabel.font = YSCConfigManagerInstance.defaultNaviTitleFont;
    titleView.titleLabel.textAlignment = NSTextAlignmentCenter;
    titleView.titleLabel.center = CGPointMake(titleView.ysc_width / 2, 20 + 22);
    [titleView addSubview:titleView.titleLabel];
    
    titleView.bottomLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    titleView.bottomLineLabel.backgroundColor = YSCConfigManagerInstance.defaultBorderColor;
    [titleView addSubview:titleView.bottomLineLabel];
    
    [titleView _setupCustomValues];
    
    return titleView;
}
- (void)_setupCustomValues {

}
@end


@interface YSCBaseViewController ()
@property (nonatomic, strong) NSMutableDictionary *requestIdDictionary;
@end
@implementation YSCBaseViewController

- (void)dealloc {
    // 移除titleView
    if (self.yscTitleView) {
        [self.yscTitleView removeFromSuperview];
        self.yscTitleView = nil;
    }
    
    // 移除tipsView
    if (self.yscTipsView) {
        [self.yscTipsView removeFromSuperview];
        self.yscTipsView = nil;
    }
    
    // 取消未结束的网络请求
    NSArray *requestIds = [self.requestIdDictionary.allValues copy];
    for (NSString *requestId in requestIds) {
        [YSCRequestManagerInstance cancelRequestById:requestId];
    }
    [self.requestIdDictionary removeAllObjects];
    self.requestIdDictionary = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    PRINT_DEALLOCING
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isHideSystemNaviBar] != self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:[self isHideSystemNaviBar]
                                                 animated:animated];
    }
    if (self.yscTitleView) {
        [self.view bringSubviewToFront:self.yscTitleView];
    }
    if (self.yscTipsView) {
        [self.view bringSubviewToFront:self.yscTipsView];
    }
    
    YSCManagerInstance.currentViewController = self;
    NSLog(@"[%@] will appear", NSStringFromClass(self.class));
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestIdDictionary = [NSMutableDictionary dictionary];
    self.block = self.ysc_params[kParamBlock];
    NSLog(@"self.params = %@", self.ysc_params);
    
    self.title = TRIM_STRING(self.ysc_params[kParamTitle]);
    self.view.backgroundColor = YSCConfigManagerInstance.defaultViewColor;
    self.hidesBottomBarWhenPushed = YES;
    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = YES;
    // self.view自动让出navigationBar的位置
    [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    
    // 统一设置titleView、tipsView、goBackButton
    YSCNaviType naviType = [self.ysc_params[kParamNaviType] integerValue];
    if (YSCNaviTypeNone != naviType) {
        [self _configTitleView];
        if (self.yscTitleView && YSCNaviTypeCustomize != naviType) {
            // 如果指定了自定义titleView，则强制隐藏系统navibar
            self.ysc_params[kParamNaviType] = @(YSCNaviTypeCustomize);
        }
        
        if ( ! [self isHideSystemNaviBar]) {
            [YSCConfigManager configNavigationBar:self.navigationController.navigationBar];
            [self _configGoBackButton];
        }
    }
    [self _configTipsView];
    [self resetTitle:self.ysc_params[kParamTitle]];
    
    // 监控APP运行状态(恢复运行、按下home键进入后台)
    ADD_OBSERVER(@selector(didAppBecomeActive), UIApplicationDidBecomeActiveNotification);
    ADD_OBSERVER(@selector(didAppEnterBackground), UIApplicationDidEnterBackgroundNotification);
}

#pragma mark - 自定导航条TitleView
- (void)_configTitleView {
    YSCNaviType naviType = [self.ysc_params[kParamNaviType] integerValue];
    NSString *tempName = self.titleViewName;
    if (YSCNaviTypeCustomize == naviType && OBJECT_IS_EMPTY(tempName)) {
        // 在没有指定自定义导航条类名的情况下又想用自定义导航条，就使用默认类名：YSCTitleView
        tempName = @"YSCTitleView";
    }
    
    if (OBJECT_ISNOT_EMPTY(tempName)) {
        @weakiy(self);
        Class class = NSClassFromString(tempName);
        SEL createSelector = NSSelectorFromString(@"createTitleView");
        if ([class methodForSelector:createSelector]) {
            PERFORM_SELECTOR_WITHOUT_LEAKWARNING(^{
                weak_self.yscTitleView = [class performSelector:createSelector withObject:nil];
            });
        }
        if (self.yscTitleView) {
            [self.view addSubview:self.yscTitleView];
            [self.yscTitleView.goBackButton ysc_addTouchUpInsideEventBlock:^(id sender) {
                [weak_self backButtonClicked:nil];
            }];
        }
    }
}
- (NSString *)titleViewName {
    return @"";
}
- (void)resetTitle:(NSString *)title {
    if (self.yscTitleView) {
        self.yscTitleView.titleLabel.text = TRIM_STRING(title);
    }
    else {
        if ( ! [self isHideSystemNaviBar]) {
            self.navigationItem.title = TRIM_STRING(title);
        }
    }
}


#pragma mark - 系统导航条NavigationBar
- (void)_configGoBackButton {
    YSCGoBackButtonType type = [self.ysc_params[kParamBackType] integerValue];
    if (YSCGoBackButtonTypeDefault == type) {//自定义返回按钮的图片(包括push和present的)
        UIImage *backArrowImage = [UIImage imageNamed:YSCConfigManagerInstance.defaultNaviGoBackImageName];
        if (backArrowImage) {
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backArrowImage
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(backButtonClicked:)];
        }
        else {
            UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
            temporaryBarButtonItem.title = @"";//去掉返回按钮的文字
            self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        }
    }
    else if (YSCGoBackButtonTypeSystemWithPreTitle == type) {
        if (self.ysc_params[kParamPreTitle]) {
            UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
            temporaryBarButtonItem.title = TRIM_STRING(self.ysc_params[kParamPreTitle]);
            self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        }
    }
    else if (YSCGoBackButtonTypeSystemWithoutPreTitle == type) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";//去掉返回按钮的文字
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
}
- (BOOL)isHideSystemNaviBar {
    return YSCNaviTypeDefault != [self.ysc_params[kParamNaviType] integerValue];
}
- (IBAction)backButtonClicked:(id)sender {
    [self ysc_backViewController];
}


#pragma mark - TipsView
- (void)_configTipsView {
    self.yscTipsView = [YSCTipsView createYSCTipsViewOnView:self.view];
    self.yscTipsView.backgroundColor = YSCConfigManagerInstance.defaultViewColor;
    self.yscTipsView.hidden = YES;
}
- (void)showTipsWithMessage:(NSString *)message buttonAction:(YSCBlock)buttonAction {
    if (self.yscTipsView) {
        if (self.yscTitleView) {
            UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetMaxY(self.yscTitleView.frame), 0, 0, 0);
            [self.yscTipsView resetFrameWithEdgeInsets:insets];
        }
        self.yscTipsView.messageLabel.text = message;
        if (OBJECT_IS_EMPTY(message)) {// 没有错误信息就显示空数据提示
            [self.yscTipsView resetImageName:YSCConfigManagerInstance.defaultEmptyImageName];
            self.yscTipsView.actionButton.hidden = YES;
        }
        else {
            if ([YSCConfigManagerInstance.networkErrorTimeout isEqualToString:message]) {
                [self.yscTipsView resetImageName:YSCConfigManagerInstance.defaultTimeoutImageName];
            }
            else {
                [self.yscTipsView resetImageName:YSCConfigManagerInstance.defaultErrorImageName];
            }
            [self.yscTipsView resetActionWithButtonTitle:@"重新加载" buttonAction:buttonAction];
        }
        self.yscTipsView.hidden = NO;
    }
    else {
        [YSCHUD showHUDThenHideOnKeyWindowWithMessage:message];
    }
}
- (void)removeTipsView {
    RETURN_WHEN_OBJECT_IS_EMPTY(self.yscTipsView)
    self.yscTipsView.hidden = YES;
    [self.yscTipsView removeFromSuperview];
    self.yscTipsView = nil;
}


#pragma mark - 监控APP恢复运行、按下home键
- (void)didAppBecomeActive { }
- (void)didAppEnterBackground { }


#pragma mark - 管理网络请求队列
- (void)addRequestId:(NSString *)requestId forKey:(NSString *)requestKey {
    RETURN_WHEN_OBJECT_IS_EMPTY(requestId);
    RETURN_WHEN_OBJECT_IS_EMPTY(requestKey);
    self.requestIdDictionary[requestKey] = requestId;
}
- (void)removeRequestIdByKey:(NSString *)requestKey {
    RETURN_WHEN_OBJECT_IS_EMPTY(requestKey);
    NSString *requestId = self.requestIdDictionary[requestKey];
    if (requestId && ! YSCRequestManagerInstance.requestQueue[requestId]) {
        // 只有当网络请求队列里移除了requestId才移除对应的requestKey
        [self.requestIdDictionary removeObjectForKey:requestKey];
    }
}
- (void)cancelRequestIdByKey:(NSString *)requestKey {
    NSString *requestId = self.requestIdDictionary[requestKey];
    if (requestId) {
        [YSCRequestManagerInstance cancelRequestById:requestId];
        [self.requestIdDictionary removeObjectForKey:requestKey];
    }
}

@end
