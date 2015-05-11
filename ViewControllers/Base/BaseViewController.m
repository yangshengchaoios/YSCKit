//
//  BaseViewController.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "BaseViewController.h"

#define kHudIntervalShort 0.5f
#define kHudIntervalNormal 1.0f
#define kHudIntervalLong 2.0f

@interface BaseViewController ()

@property (nonatomic, strong) UIStoryboard *storyBoard;
@property (nonatomic, strong) NSString *reachabilityManagerIdentifier;

@end

@implementation BaseViewController

#pragma mark - 重写基类方法

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

	// TODO:这里需要释放dataModel
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([self showCustomTitleBarView]) {
		if (self.navigationController) {
			[self.navigationController setNavigationBarHidden:YES animated:animated];
			[self.navigationController setToolbarHidden:YES animated:animated];
		}
		[self.view bringSubviewToFront:self.titleBarView];
	}
    else {
        if ( ! self.isAppeared) {//这里默认是要显示navibar的!
            [self.navigationController setNavigationBarHidden:NO animated:animated];//IMPORTANT!
        }
        //NOTE:只有当前VC需要隐藏navibar的时候才这样写
        /*- (void)viewWillAppear:(BOOL)animated {
            self.isAppeared = YES;
            [super viewWillAppear:animated];
            [self.navigationController setNavigationBarHidden:YES animated:animated];
         }*/
    }
    self.isAppeared = YES;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
    
    //控制只执行一次的方法
    if (!self.isRunViewDidLoadExtension) {
        [self viewDidiLoadExtension];
        self.isRunViewDidLoadExtension = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:NSStringFromClass([self class])];
    if ([self scrollableView]) {
        [self showNavBarAnimated:NO];
    }
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
	self.isAppeared = NO;
    [super viewDidDisappear:animated];
}
- (void)dealloc {
	NSLog(@"[%@] dealloc......", NSStringFromClass(self.class));
    if ([NSString isNotEmpty:self.reachabilityManagerIdentifier]) {
        [[ReachabilityManager sharedInstance] bk_removeObserversWithIdentifier:self.reachabilityManagerIdentifier];
    }
//	[[Login sharedInstance] unregisterLoginObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self]; //等同于宏定义  removeAllObservers(self);
}
- (void)updateViewConstraints {
    // Check a flag didSetupConstraints before creating constraints, because this method may be called multiple times, and we
    // only want to create these constraints once. Without this check, the same constraints could be added multiple times,
    // which can hurt performance and cause other issues. See Demo 7 (Animation) for an example of code that runs every time.
    if (!self.isSetupConstraints) {
        [self setupConstraints];
        self.isSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

/**
 *  初始化
 */
- (void)viewDidLoad {
	[super viewDidLoad];
    WeakSelfType blockSelf = self;
    
    //view基本参数设置
    if ([NSString isEmpty:self.navigationItem.title] && [NSString isNotEmpty:self.params[kParamTitle]]) {//已经有标题的就不再设置了
        self.navigationItem.title = self.params[kParamTitle];
    }
    self.view.clipsToBounds = YES;
	self.view.layer.masksToBounds = YES;//解决自定义导航条在移出时的延迟问题
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {//ios6不支持该属性
        [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    }
    self.view.backgroundColor = kDefaultViewColor; //设置默认背景颜色
    
    //单击隐藏键盘(这里会和tableviewcell的单击事件相冲突)
//    [self.view bk_whenTapped:^{
//        [blockSelf performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1f];
//    }];
    
    //在输入框聚焦的情况下按键盘的return键要隐藏键盘
    [self setDelegateOfAllTextFields:self.view];
    
    //设置键盘显示和隐藏时，需要调整的内容
	if ([self willCareKeyboard]) {
        addNObserver(@selector(keyboardWillShow:), UIKeyboardWillShowNotification);
        addNObserver(@selector(keyboardWillHide:), UIKeyboardWillHideNotification);
	}
    
    //添加网络状态监控功能
    self.reachabilityManagerIdentifier = [[ReachabilityManager sharedInstance] bk_addObserverForKeyPath:@"reachable" task:^(id target) {
        dispatch_async(dispatch_get_main_queue(), ^{//更新主线程的UI
		    BOOL reachable = [ReachabilityManager sharedInstance].reachable;
		    [blockSelf networkReachablityChanged:reachable];
		});
    }];
    
    //设置导航栏
	if ([self showCustomTitleBarView]) {
		if (!self.titleBarView) {
			self.titleBarView = [TitleBarView new];
			[self.view addSubview:self.titleBarView];
		}
		self.titleBarView.hidden = NO;
	}
	else {
		if (self.titleBarView) {
			self.titleBarView.hidden = YES;
		}
	}
 
    //设置返回按钮类型
    [self configBackButton];
    
    //设置NavBar跟随的scrollview
    if ([self scrollableView]) {
        [self followScrollView:[self scrollableView]];
    }
    
    //相对布局——自动调整约束值和font大小
    [self.view resetFontSizeOfView];
    [self.view resetConstraintOfView];
}


#pragma mark - 私有方法

/**
 *  设置返回按钮（左上角）
 */
- (void)configBackButton {
    if ([NSObject isNotEmpty:self.params[kParamBackType]]) {
		self.backType = [self.params[kParamBackType] integerValue];
	}
	else {
		self.backType = BackTypeDefault;
	}
    
    if (BackTypeDefault == self.backType) { //设置返回按钮(默认)
		if ([self showCustomTitleBarView]) {//显示自定义TitleBarView
			if (!self.backButton) {
				self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 22, 44, 40)];
				self.backButton.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 12);
				self.backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
				self.backButton.backgroundColor = [UIColor clearColor];
				[self.backButton setTitle:nil forState:UIControlStateNormal];
				[self.backButton setImage:DefaultNaviBarArrowBackImage forState:UIControlStateNormal];
			}
			[self.backButton addTarget:self action:@selector(popButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self.titleBarView addSubview:self.backButton];
		}
		else {//显示系统默认返回按钮(向左的箭头带)
            //------去掉返回按钮的文字------
            UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
            temporaryBarButtonItem.title = @"";
            self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
            //-------------END-----------
		}
	}
    else if (BackTypeImage == self.backType) {//自定义返回按钮的图片(包括push和present的)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:DefaultNaviBarArrowBackImage
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonClicked:)];
    }
    else if (BackTypeSliding == self.backType) { //设置侧边栏按钮
        if ([self showCustomTitleBarView]) {
            if (!self.backButton) {
                self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 50, 44)];
                self.backButton.contentEdgeInsets = UIEdgeInsetsMake(10, 13, 11, 14);
                self.backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                self.backButton.backgroundColor = [UIColor clearColor];
                [self.backButton setTitle:nil forState:UIControlStateNormal];
                [self.backButton setImage:[UIImage imageNamed:@"button_leftslide"] forState:UIControlStateNormal];
            }
            [self.backButton addTarget:self action:@selector(leftSlideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.titleBarView addSubview:self.backButton];
        }
        else {
            UIButton *slideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40)];
            [slideButton addTarget:self action:@selector(leftSlideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [slideButton setImageEdgeInsets:UIEdgeInsetsMake(4, -4, 4, 16)];
            [slideButton setImage:[UIImage imageNamed:@"button_leftslide"] forState:UIControlStateNormal];
            slideButton.tintColor = [UIColor blackColor];
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.leftBarButtonItems = [self customBarButtonOnNavigationBar:slideButton withFixedSpaceWidth:-10];
        }
    }
	else {
		NSAssert(YES, @"self.backType = [%lu] 不支持该类型！", self.backType);
	}
}
- (void)addTapToHideKeyboardGesture {
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
	gestureRecognizer.cancelsTouchesInView = NO;
//	gestureRecognizer.delegate = self;
	[self.view addGestureRecognizer:gestureRecognizer];
}
- (void)singleTapped:(UIGestureRecognizer *)gestureRecognizer {
	[self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1f];
}
- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [aValue CGRectValue];
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];

	[self willLayoutForKeyboardHeight:keyboardRect.size.height];
	WeakSelfType blockSelf = self;
	[UIView animateWithDuration:animationDuration
	                 animations: ^{
                         [blockSelf layoutForKeyboardHeight:keyboardRect.size.height];
                     }
	                 completion: ^(BOOL finished) {
                         [blockSelf didLayoutForKeyboardHeight:keyboardRect.size.height];
                     }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];

	[self willLayoutForKeyboardHeight:0];
	WeakSelfType blockSelf = self;
	[UIView animateWithDuration:animationDuration
	                 animations: ^{
                         [blockSelf layoutForKeyboardHeight:0];
                     }
	                 completion: ^(BOOL finished) {
                         [blockSelf didLayoutForKeyboardHeight:0];
                     }];
}
//递归遍历所有子view中的textfield
- (void)setDelegateOfAllTextFields:(UIView *)view {
	for (UIView *subview in view.subviews) {
		if ([subview isKindOfClass:[UITextField class]]) {
			((UITextField *)subview).delegate = self;
            addNObserverWithObj(@selector(textFieldChanged:), UITextFieldTextDidChangeNotification, (UITextField *)subview);
		}
		else if ([subview isKindOfClass:[UIView class]]) {
                [self setDelegateOfAllTextFields:subview];
		}
	}
}


#pragma mark - 这里可以获取相对布局的view大小
- (void)viewDidiLoadExtension {

}

#pragma mark - constraints
- (void)setupConstraints {
    
}

#pragma mark - push & pop & dismiss view controller
- (UIViewController *)pushViewController:(NSString *)className {
	return [self pushViewController:className withParams:nil animated:YES];
}
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict {
    return [self pushViewController:className withParams:paramDict animated:YES];
}
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict animated:(BOOL)animated {
    return [self pushViewController:className withParams:paramDict transition:nil animated:animated];
}

#pragma mark - push with transition
- (UIViewController *)pushViewController:(NSString *)className transition:(ADTransition *)transition {
    return [self pushViewController:className withParams:nil transition:transition];
}
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict transition:(ADTransition *)transition {
    return [self pushViewController:className withParams:paramDict transition:transition animated:YES];
}
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict transition:(ADTransition *)transition animated:(BOOL)animated {
    [self hideKeyboard];
    UIViewController *pushedViewController = [UIResponder createBaseViewController:className];
    if ([NSObject isNotEmpty:transition]) {
        pushedViewController.customTransitioningDelegate = [[ADTransitioningDelegate alloc] initWithTransition:transition];
    }
    NSMutableDictionary *mutableParamDict = [NSMutableDictionary dictionaryWithDictionary:paramDict];
    if ( ! mutableParamDict[kParamBackType]) {
        [mutableParamDict setValue:@(BackTypeImage) forKey:kParamBackType];   //这里设置的返回按钮由即将push出来的viewController负责处理
    }
    if ([pushedViewController isKindOfClass:[BaseViewController class]]) {
        [(BaseViewController *)pushedViewController setParams:mutableParamDict];
    }
    
    //NOTE:这里设置backBarButtonItem没有用！
    [self.navigationController pushViewController:pushedViewController animated:animated];
    return pushedViewController;
}

/*
 * 返回上一层(最多到根)
 * 如果没有NavigationController就直接dismiss
 */
- (UIViewController *)popViewController {
    [self hideKeyboard];
    [MobClick event:UMEventKeyPopViewController];
	if (self.navigationController) {     //如果有navigationBar
		NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
		UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:MAX(index - 1, 0)];
		[self.navigationController popViewControllerAnimated:YES];
		return previousViewController;
	}
	else {
        [self dismissOnPresentingViewController];
        return self.presentingViewController;
	}
}

/**
 * 返回上一层(会自动dismiss根)
 * 如果没有NavigationController就直接dismiss
 */
- (UIViewController *)backViewController {
    [self hideKeyboard];
    [MobClick event:UMEventKeyBackViewController];
	if (self.navigationController) {            //如果有navigationBar
		NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
		if (index > 0) {                        //不是root，就返回上一级
			UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:MAX(index - 1, 0)];
			[self.navigationController popViewControllerAnimated:YES];
			return previousViewController;
		}
		else {
			[self dismissOnPresentingViewController];
            return self.presentingViewController;
		}
	}
	else {
		[self dismissOnPresentingViewController];
        return self.presentingViewController;
	}
}

/**
 *  返回到顶层
 *
 *  @return 最顶层的viewController
 */
- (UIViewController *)popToRootViewController {
    if (self.navigationController) {
        UIViewController *topViewController = [self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return topViewController;
    }
	else {
        return nil;
    }
}

#pragma mark - present & dismiss viewcontroller [presentingViewController -> self -> presentedViewController]

- (UIViewController *)presentViewController:(NSString *)className {
	return [self presentViewController:className withParams:nil];
}
- (UIViewController *)presentViewController:(NSString *)className withParams:(NSDictionary *)paramDict {
    [self hideKeyboard];
    UIViewController *viewController = [UIResponder createBaseViewController:className];
    NSMutableDictionary *mutableParamDict = [NSMutableDictionary dictionaryWithDictionary:paramDict];
    if ( ! mutableParamDict[kParamBackType]) {
        [mutableParamDict setValue:@(BackTypeImage) forKey:kParamBackType];//这里设置的返回按钮由即将presented出来的viewController负责处理
    }
	if ([viewController isKindOfClass:[BaseViewController class]]) {
		[(BaseViewController *)viewController setParams:mutableParamDict];
	}
    
    return [self presentNormalViewController:viewController];
}
- (UIViewController *)presentNormalViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.customNavigationDelegate = [[ADNavigationControllerDelegate alloc] init];
    navigationController.navigationController.navigationBar.translucent = NO;
//    navigationController.interactivePopGestureRecognizer.enabled = YES;//NOTE:关闭系统自带的侧边滑动功能，会与MLTransition冲突！
//    navigationController.interactivePopGestureRecognizer.delegate = self;
    //--------自定义present出来的navigationbar背景图片--------
#if IsStatusBarChanged
    [[UIApplication sharedApplication] setStatusBarStyle:![UIApplication sharedApplication].statusBarStyle];
#endif
    [navigationController.navigationBar setTintColor:PresentNaviBackColor];//这个控制返回箭头按钮的颜色
    //设置Title为白色,Title大小为18
    [navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : PresentNaviTitleColor,
                                                                  NSFontAttributeName : [UIFont boldSystemFontOfSize:18] }];
    [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [navigationController.navigationBar setBackgroundImage:PresentNaviBarImage
                                             forBarMetrics:UIBarMetricsDefault];
    //---------------------------END-----------------------
    [self presentViewController:navigationController animated:YES completion:nil];
    return navigationController;
}
//在self上一级viewController调用dismiss（通常情况下使用该方法）
- (void)dismissOnPresentingViewController {
	if (self.presentingViewController) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        #if IsStatusBarChanged
        if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {//恢复statusbar字体颜色
            [[UIApplication sharedApplication] setStatusBarStyle:![UIApplication sharedApplication].statusBarStyle];
        }
        #endif
	}
}
//在self下一级viewController调用dismiss
- (void)dismissOnPresentedViewController {
	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
	}
}


#pragma mark - ScrollingNavbar

- (UIView *)scrollableView {
    return nil;
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	// This enables the user to scroll down the navbar by tapping the status bar.
	[self performSelector:@selector(showNavbar) withObject:nil afterDelay:0.1];
	return YES;
}


#pragma mark - push & pop with animation




#pragma mark -  show & hide HUD

//在self.view上显示hud
- (MBProgressHUD *)showHUDLoading:(NSString *)hintString {
	return [self showHUDLoading:hintString onView:self.view];
}

//在window上显示hud
- (MBProgressHUD *)showHUDLoadingOnWindow:(NSString *)hintString {
	return [self showHUDLoading:hintString onView:KeyWindow];
}

//显示hud的通用方法
- (MBProgressHUD *)showHUDLoading:(NSString *)hintString onView:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	if (hud) {
		[hud show:YES];
	}
	else {
		hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	}
	hud.labelText = hintString;
	hud.mode = MBProgressHUDModeIndeterminate;
	return hud;
}

//隐藏self.view上的hud
- (void)hideHUDLoading {
	[self hideHUDLoadingOnView:self.view];
}

//隐藏window上的hud
- (void)hideHUDLoadingOnWindow {
	[self hideHUDLoadingOnView:KeyWindow];
}

//隐藏hud的通用方法
- (void)hideHUDLoadingOnView:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	[hud hide:YES];
}

//直接隐藏self.view上的hud
- (void)showResultThenHide:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:self.view];
}

//直接隐藏window上的hud
- (void)showResultThenHideOnWindow:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:KeyWindow];
}

//延迟隐藏self.view上的hud,返回上一级
- (void)showResultThenPop:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:self.view];
	[self performSelector:@selector(popViewController) withObject:nil afterDelay:kHudIntervalNormal];
}

//延迟隐藏window上的hud后，返回上一级
- (void)showResultThenPopOnWindow:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:KeyWindow];
	[self performSelector:@selector(popViewController) withObject:nil afterDelay:kHudIntervalNormal];
}

//延迟隐藏self.view上的hud后，并返回上一级或dismiss
- (void)showResultThenBack:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:self.view];
	[self performSelector:@selector(backViewController) withObject:nil afterDelay:kHudIntervalNormal];
}

//延迟隐藏window上的hud后，并返回上一级或dismiss
- (void)showResultThenBackOnWindow:(NSString *)resultString {
	[self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:KeyWindow];
	[self performSelector:@selector(backViewController) withObject:nil afterDelay:kHudIntervalNormal];
}

//延迟隐藏self.view上的hud后，并dismiss
- (void)showResultThenDismiss:(NSString *)resultString {
    [self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:self.view];
	
    if (self.presentingViewController) {
        [self performSelector:@selector(dismissOnPresentingViewController) withObject:nil afterDelay:kHudIntervalNormal];
	}
    else {
        [self performSelector:@selector(dismissOnPresentedViewController) withObject:nil afterDelay:kHudIntervalNormal];
    }
}

//延迟隐藏window上的hud后，并dismiss
- (void)showResultThenDismissOnWindow:(NSString *)resultString {
    [self showResultThenHide:resultString afterDelay:kHudIntervalNormal onView:KeyWindow];
    
    if (self.presentingViewController) {
        [self performSelector:@selector(dismissOnPresentingViewController) withObject:nil afterDelay:kHudIntervalNormal];
	}
    else {
        [self performSelector:@selector(dismissOnPresentedViewController) withObject:nil afterDelay:kHudIntervalNormal];
    }
}

//延迟隐藏view上hud的通用方法
- (void)showResultThenHide:(NSString *)resultString afterDelay:(NSTimeInterval)delay onView:(UIView *)view {
	MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
	if (!hud) {
		hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	}
	hud.labelText = resultString;
	hud.mode = MBProgressHUDModeText;
	[hud show:YES];
	[hud hide:YES afterDelay:delay];
}

#pragma mark - alert view

- (UIAlertView *)showAlertVieWithMessage:(NSString *)message {
	return [self showAlertViewWithTitle:@"提示" andMessage:message];
}

- (UIAlertView *)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message {
	UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
	[alertView bk_setCancelButtonWithTitle:@"确定" handler:nil];
	[alertView show];
	return alertView;
}

#pragma mark - Overridden methods 缓存相关

- (NSString *)cacheFilePath {
	return [self cacheFilePath:nil];
}
- (NSString *)cacheFilePath:(NSString *)suffix {
	NSString *fileName = [NSString stringWithFormat:@"%@%@.dat",
                          NSStringFromClass(self.class),
                          [NSString isEmpty:suffix] ? @"" :[NSString stringWithFormat:@"_%@",suffix]]; //缓存文件名称
	return [[[StorageManager sharedInstance] directoryPathOfLibraryCachesCommon] stringByAppendingPathComponent:fileName];
}
- (id)cachedObjectForKey:(NSString *)cachedKey {
	return [self cachedObjectForKey:cachedKey withSuffix:nil];
}
- (id)cachedObjectForKey:(NSString *)cachedKey withSuffix:(NSString *)suffix {
	NSDictionary *cacheInfo = [[StorageManager sharedInstance] unarchiveDictionaryFromFilePath:[self cacheFilePath:suffix]];
	if ([cacheInfo objectForKey:cachedKey]) {
		return cacheInfo[cachedKey];
	}
	else {
		return nil;
	}
}
- (void)saveObject:(id)object forKey:(NSString *)cachedKey {
	[self saveObject:object forKey:cachedKey withSuffix:nil];
}
- (void)saveObject:(id)object forKey:(NSString *)cachedKey withSuffix:(NSString *)suffix {
	if ([NSString isEmpty:cachedKey]) {
		return;
	}
    
	@try {
		BOOL isSuccess = [[StorageManager sharedInstance] archiveDictionary:@{ cachedKey : object }
                                                                 toFilePath:[self cacheFilePath:suffix]
                                                                  overwrite:NO];
		if (isSuccess) {
			NSLog(@"缓存成功！");
		}
		else {
			NSLog(@"缓存失败！");
		}
	}
	@catch (NSException *exception)
	{
		NSLog(@"将数组保存至本地缓存时出错！%@",
		      exception); //可能是没有在对象里做序列号和反序列化！
	}
	@finally
	{
	}
}

/**
 *  加载本地缓存数据
 *  同时初始化为NSMutableArray
 */
- (NSMutableArray *)commonLoadCaches:(NSString *)cacheKey {
    NSMutableArray *cacheArray = [NSMutableArray array];
    NSArray *tempArray = [self cachedObjectForKey:cacheKey];
    if ([tempArray isKindOfClass:[NSArray class]] && [NSArray isNotEmpty:tempArray]) {
        [cacheArray addObjectsFromArray:tempArray];
    }
    return cacheArray;
}

#pragma mark - Overridden methods 业务相关

/**
 *  返回自定义的在navigationBar上的按钮
 *
 *  @param customButton
 *  @param width        -10
 *
 *  @return
 */
- (NSArray *)customBarButtonOnNavigationBar:(UIView *)customButton withFixedSpaceWidth:(NSInteger)width {
	UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
	UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:self
                                                                                action:nil];
	flexSpacer.width = width;
	return [NSArray arrayWithObjects:flexSpacer, leftButtonItem, nil];
}

/**
 *  在自定义navigationBar上的返回按钮点击事件，
 *  返回上一级（如果有导航条最多只返回到根，如果没有导航条就dismiss）
 *
 *  @param sender
 */
- (IBAction)backButtonClicked:(id)sender {
	[self backViewController];
}

/**
 *  返回上一级按钮
 *  如果是rootViewController了，就dismiss
 *
 *  @param sender
 */
- (IBAction)popButtonClicked:(id)sender {
	[self popViewController];
}

/**
 *  点击侧边栏
 *
 *  @param sender
 */
- (IBAction)leftSlideButtonClicked:(id)sender {
	[self hideKeyboard];
	//    if (self.drawerController) {
	//        [self.drawerController toggleDrawerSide:XHDrawerSideLeft
	//        animated:YES completion:nil];
	//    }
}

/**
 *  设置是否显示自定义titleBar
 *  默认不显示
 */
- (BOOL)showCustomTitleBarView {
	return NO;
}
- (void)hideKeyboard {
	[self.view endEditing:YES];
}
- (BOOL)willCareKeyboard {
	return NO;
}
- (void)willLayoutForKeyboardHeight:(CGFloat)keyboardHeight {
}
- (void)layoutForKeyboardHeight:(CGFloat)keyboardHeight {
}
- (void)didLayoutForKeyboardHeight:(CGFloat)keyboardHeight {
}
- (void)networkReachablityChanged:(BOOL)reachable {
	if (!reachable) {
		[self showResultThenHideOnWindow:@"网络断开了"];
	}
}
//专门针对tableview的seperator左右间隔进行设置
- (UIEdgeInsets)edgeInsetsOfCellSeperator {
    return UIEdgeInsetsZero;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self hideKeyboard];//TODO:在ios8中失效！
	return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.maxLength > 0) {
		NSMutableString *newText = [textField.text mutableCopy];
		[newText replaceCharactersInRange:range withString:string]; //兼容从中间插入内容的情况！
		return [newText length] <= textField.maxLength;
	}
	return YES;
}
- (void)textFieldChanged:(NSNotification *)note {
	UITextField *textField = (UITextField *)note.object;
	if (![textField isKindOfClass:[UITextField class]]) {
		return;
	}
}

#pragma mark - Observe KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

}

@end

