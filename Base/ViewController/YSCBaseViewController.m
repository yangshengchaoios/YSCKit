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
    [self.navigationController setNavigationBarHidden:[self.params[kParamIsHideNavBar] boolValue] animated:animated];
    self.isAppeared = YES;
    YSCDataInstance.currentViewController = self;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
	self.isAppeared = NO;
    [super viewDidDisappear:animated];
}
- (void)dealloc {
	NSLog(@"[%@] dealloc......", NSStringFromClass(self.class));
	[[NSNotificationCenter defaultCenter] removeObserver:self]; //等同于宏定义  removeAllObservers(self);
}
// 初始化
- (void)viewDidLoad {
	[super viewDidLoad];
    self.block = self.params[kParamBlock];
    
    //view基本参数设置
    if (OBJECT_IS_EMPTY(self.navigationItem.title) &&
        OBJECT_ISNOT_EMPTY(self.params[kParamTitle])) {
        self.navigationItem.title = TRIM_STRING(self.params[kParamTitle]);
    }
    self.view.backgroundColor = kDefaultViewColor; //设置默认背景颜色
    self.hidesBottomBarWhenPushed = YES;
    self.view.clipsToBounds = YES;
	self.view.layer.masksToBounds = YES;//解决自定义导航条在移出时的延迟问题
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {//ios6不支持该属性
        [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    }
    
    //设置返回按钮类型
    if (NO == [self.params[kParamIsHideNavBar] boolValue]) {
        [self _configBackButton];
    }
    
    //相对布局——自动调整约束值和font大小
    if (1 != AUTOLAYOUT_SCALE &&
        NO == [self respondsToSelector:@selector(setCloseResetFontAndConstraint:)]) {
        [UIView resetSizeOfView:self.view];
    }
    
    //监控APP运行状态(恢复运行、按下home键进入后台)
    ADD_OBSERVER(@selector(didAppBecomeActive), UIApplicationDidBecomeActiveNotification);
    ADD_OBSERVER(@selector(didAppEnterBackground), UIApplicationDidEnterBackgroundNotification);
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
