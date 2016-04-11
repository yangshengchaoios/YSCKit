//
//  YSCBaseViewController.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "YSCBaseViewController.h"

@implementation YSCBaseViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (self.customTitleView) {
        [self.view bringSubviewToFront:self.customTitleView];
    }
    if (self.tipsView) {
        [self.view bringSubviewToFront:self.tipsView];
    }
    [self.navigationController setNavigationBarHidden:[self.params[kParamIsHideNavBar] boolValue] animated:animated];
    self.isAppeared = YES;
    YSCDataInstance.currentViewController = self;
    NSLog(@"%@ will appear", NSStringFromClass(self.class));
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
	self.isAppeared = NO;
    [super viewDidDisappear:animated];
}
- (void)dealloc {
	NSLog(@"[%@] is dealloc......", NSStringFromClass(self.class));
    if (self.customTitleView) {
        [self.customTitleView removeFromSuperview];
        self.customTitleView = nil;
    }
    if (self.tipsView) {
        [self.tipsView removeFromSuperview];
        self.tipsView = nil;
    }
	[[NSNotificationCenter defaultCenter] removeObserver:self]; //等同于宏定义  removeAllObservers(self);
}
// 初始化
- (void)viewDidLoad {
	[super viewDidLoad];
    if (nil == self.params) {
        self.params = [NSMutableDictionary dictionary];
    }
    NSLog(@"self.params = %@", self.params);
    self.block = self.params[kParamBlock];
    //相对布局——自动调整约束值和font大小
    if (1 != AUTOLAYOUT_SCALE &&
        NO == [self respondsToSelector:@selector(setCloseResetFontAndConstraint:)]) {
        [self.view resetSize];
    }
    //设置title
    [self _configTitleView];
    self.view.backgroundColor = kDefaultViewColor; //设置默认背景颜色
    self.hidesBottomBarWhenPushed = YES;
    self.view.clipsToBounds = YES;
	self.view.layer.masksToBounds = YES;//解决自定义导航条在移出时的延迟问题
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {//ios6不支持该属性
        [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    }
    //设置tipsview
    self.tipsView = [YSCTipsView createYSCTipsViewOnView:self.view];
    if (self.customTitleView) {
        [self.tipsView resetFrameWithEdgeInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    self.tipsView.hidden = YES;
    
    //设置返回按钮类型
    if (NO == [self.params[kParamIsHideNavBar] boolValue]) {
        [self _configBackButton];
    }
    
    //监控APP运行状态(恢复运行、按下home键进入后台)
    ADD_OBSERVER(@selector(didAppBecomeActive), UIApplicationDidBecomeActiveNotification);
    ADD_OBSERVER(@selector(didAppEnterBackground), UIApplicationDidEnterBackgroundNotification);
}
//设置title
- (void)_configTitleView {
    if (OBJECT_ISNOT_EMPTY(self.customTitleViewName)) {
        if ([NSClassFromString(self.customTitleViewName) respondsToSelector:@selector(createTitleView)]) {
            self.customTitleView = [NSClassFromString(self.customTitleViewName) performSelector:@selector(createTitleView) withObject:nil];
        }
        if (self.customTitleView) {
            //添加自定义title view
            [self.view addSubview:self.customTitleView];
            //强制隐藏系统navi bar
            self.params[kParamIsHideNavBar] = @YES;
            //设置自定义title view的title
            if ([self.customTitleView respondsToSelector:@selector(setTitle:)]) {
                [self.customTitleView performSelector:@selector(setTitle:)
                                           withObject:TRIM_STRING(self.params[kParamTitle])];
            }
            //设置返回事件
            if ([self.customTitleView respondsToSelector:@selector(setGoBackBlock:)]) {
                @weakiy(self);
                YSCBlock block = ^{
                    [weak_self backViewController];
                };
                [self.customTitleView performSelector:@selector(setGoBackBlock:)
                                           withObject:block];
            }
        }
    }
    else {
        if (OBJECT_IS_EMPTY(self.navigationItem.title) &&
            OBJECT_ISNOT_EMPTY(self.params[kParamTitle])) {
            self.navigationItem.title = TRIM_STRING(self.params[kParamTitle]);
        }
    }
}
// 配置返回按钮
- (void)_configBackButton {
    if (self.params[kParamBackType]) {
		self.backArrowType = [self.params[kParamBackType] integerValue];
	}
	else {
		self.backArrowType = BackArrowTypeDefault;
	}
    
    if (BackArrowTypeDefault == self.backArrowType) {//自定义返回按钮的图片(包括push和present的)
        UIImage *backArrowImage = [UIImage imageNamed:kDefaultBackArrowImageName];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:backArrowImage
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(backButtonClicked:)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
        
	}
    else if (BackArrowTypeSystemWithNoText == self.backArrowType) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";//去掉返回按钮的文字
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
}

// 配置自定义titleview的名称
- (NSString *)customTitleViewName {
    return @"";
}
// 重新设置title
- (void)resetTitle:(NSString *)title {
    if ([self.params[kParamIsHideNavBar] boolValue]) {
        if ([self.customTitleView respondsToSelector:@selector(setTitle:)]) {
            [self.customTitleView performSelector:@selector(setTitle:)
                                       withObject:TRIM_STRING(title)];
        }
    }
    else if (OBJECT_ISNOT_EMPTY(self.customTitleViewName)) {
        self.navigationItem.title = TRIM_STRING(title);
    }
}

- (void)showTipsWithMessage:(NSString *)message buttonAction:(YSCBlock)buttonAction {
    if (nil == self.tipsView) {
        [YSCAlertManager showAlertVieWithMessage:message];
    }
    else {
        self.tipsView.hidden = NO;
        self.tipsView.messageLabel.text = message;
        if (OBJECT_IS_EMPTY(message)) {
            self.tipsView.iconImageView.image = [UIImage imageNamed:@""];//TODO:
            self.tipsView.actionButton.hidden = YES;
        }
        else {
            self.tipsView.iconImageView.image = [UIImage imageNamed:@""];//TODO:
            [self.tipsView resetActionWithButtonTitle:@"重新加载" buttonAction:buttonAction];
        }
    }
}
- (void)hideTipsViewByRemoving:(BOOL)remove {
    RETURN_WHEN_OBJECT_IS_EMPTY(self.tipsView)
    self.tipsView.hidden = YES;
    if (remove) {
        [self.tipsView removeFromSuperview];
        self.tipsView = nil;
    }
}
// 自动判断hud的背景是否透明，以及HUD的edgeInsets
- (void)showHUDOnSelfView:(BOOL)showsMask {
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (self.customTitleView) {
        edgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    [YSCHUDManager showHUDOnView:self.view
                      edgeInsets:edgeInsets
                       showsMask:showsMask];
}
- (void)showHUDOnSelfView {
    [self showHUDOnSelfView:(nil != self.tipsView)];
}
- (void)hideHUDOnSelfView {
    [YSCHUDManager hideHUDOnView:self.view];
}

// APP恢复运行
- (void)didAppBecomeActive {
}
// 用户按下Home键APP进入后台
- (void)didAppEnterBackground {
}
// 点击返回箭头按钮
- (IBAction)backButtonClicked:(id)sender {
	[self backViewController];
}
@end
