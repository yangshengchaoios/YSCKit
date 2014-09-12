//
//  BaseViewController.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "BaseViewController.h"

#define kHudIntervalShort 0.5f
#define kHudIntervalNormal 1.0f
#define kHudIntervalLong 2.0f

#pragma mark - BaseViewController

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
	self.isAppeared = YES;

	if ([self showCustomTitleBarView]) {
		if (self.navigationController) {
			[self.navigationController setNavigationBarHidden:YES];
			[self.navigationController setToolbarHidden:YES];
		}
		[self.view bringSubviewToFront:self.titleBarView];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
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
	[[Login sharedInstance] unregisterLoginObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self]; //等同于宏定义  removeAllObservers(self);
}

/**
 *  初始化
 */
- (void)viewDidLoad {
	[super viewDidLoad];
    WeakSelfType blockSelf = self;
    
    //view基本参数设置
    self.view.clipsToBounds = YES;
	self.view.layer.masksToBounds = YES;//解决自定义导航条在移出时的延迟问题
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {//ios6不支持该属性
        [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    }
    self.view.backgroundColor = kDefaultViewColor; //设置默认背景颜色
    
    //单击隐藏键盘
    [self.view bk_whenTapped:^{
        [blockSelf performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1f];
    }];
    
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
		self.backType = BackTypeBack;
	}
    
    if (self.backType == BackTypeBack) { //设置返回按钮(默认)
		if ([self showCustomTitleBarView]) {//显示自定义TitleBarView
			if (!self.backButton) {
				self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 22, 44, 40)];
				self.backButton.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 12);
				self.backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
				self.backButton.backgroundColor = [UIColor clearColor];
				[self.backButton setTitle:nil forState:UIControlStateNormal];
				[self.backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
			}
			[self.backButton addTarget:self action:@selector(popButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self.titleBarView addSubview:self.backButton];
		}
		else {
			UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
			temporaryBarButtonItem.title = @"";
			self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
		}
	}
    else if (self.backType == BackTypeSliding) { //设置侧边栏按钮
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
    else if (self.backType == BackTypeDismiss) {//设置dismiss按钮
        UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40)];
        [dismissButton addTarget:self action:@selector(dismissOnPresentingViewController) forControlEvents:UIControlEventTouchUpInside];
        [dismissButton setImageEdgeInsets:UIEdgeInsetsMake(4, -4, 4, 16)];
        [dismissButton setImage:[UIImage imageNamed:@"button_dismiss"] forState:UIControlStateNormal];
        dismissButton.tintColor = [UIColor blackColor];
        self.navigationItem.leftBarButtonItems = [self customBarButtonOnNavigationBar:dismissButton withFixedSpaceWidth:-10];
    }
	else {
		NSAssert(YES, @"self.backType = [%d] 不支持该类型！", self.backType);
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
	                 animations: ^{ [blockSelf layoutForKeyboardHeight:0]; }
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
		else {
			[self setDelegateOfAllTextFields:subview];
		}
	}
}

- (UIViewController *)createBaseViewController:(NSString *)className {
    UIViewController *pushedViewController = nil;
    
	//第一步：检测是否在storyboard里有布局
	if (!pushedViewController) {
		@try {
			pushedViewController = [self.storyBoard instantiateViewControllerWithIdentifier:className];
		}
		@catch (NSException *exception) {
			NSLog(@"class[%@] is not found in storyboard!", className);
		}
		@finally {
		}
	}
    
	//第二步：检测是否有class文件 同时兼容xib布局的情况
	if (!pushedViewController) {
		pushedViewController = [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
	}
	NSAssert(pushedViewController, @"class[%@] is not exists in this project!", className);
    pushedViewController.hidesBottomBarWhenPushed = YES;
    NSLog(@"进入页面:%@", className);
    return pushedViewController;
}

#pragma mark - push & pop & dismiss view controller

- (UIViewController *)pushViewController:(NSString *)className {
	return [self pushViewController:className withParams:nil];
}

- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict {
    [self hideKeyboard];
	UIViewController *pushedViewController = [self createBaseViewController:className];
    NSMutableDictionary *mutableParamDict = [paramDict mutableCopy];
	if ([pushedViewController isKindOfClass:[BaseViewController class]]) {
		[(BaseViewController *)pushedViewController setParams:mutableParamDict];
	}
	[self.navigationController pushViewController:pushedViewController animated:YES];
	return pushedViewController;
}

/*
 * 返回上一层(最多到根)
 * 如果没有NavigationController就直接dismiss
 */
- (UIViewController *)popViewController {
    [self hideKeyboard];
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
    UIViewController *viewController = [self createBaseViewController:className];
    NSMutableDictionary *mutableParamDict = [paramDict mutableCopy];
    [mutableParamDict setValue:@(BackTypeDismiss) forKey:kParamBackType];   //这里设置的返回按钮由即将presented出来的viewController负责创建
	if ([viewController isKindOfClass:[BaseViewController class]]) {
		[(BaseViewController *)viewController setParams:[NSDictionary dictionaryWithDictionary:mutableParamDict]];
	}
    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.navigationBar.tintColor = [UIColor blackColor];
	[self presentViewController:navigationController animated:YES completion:nil];
	return navigationController;
}

//在self上一级viewController调用dismiss（通常情况下使用该方法）
- (void)dismissOnPresentingViewController {
	if (self.presentingViewController) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict withAnimation:(ADTransition *)transition {
    if (!self.transitionController) {
        return nil;
    }
    [self hideKeyboard];
	UIViewController *pushedViewController = [self createBaseViewController:className];
    NSMutableDictionary *mutableParamDict = [paramDict mutableCopy];
	if ([pushedViewController isKindOfClass:[BaseViewController class]]) {
		[(BaseViewController *)pushedViewController setParams:mutableParamDict];
	}
	[self.transitionController pushViewController:pushedViewController withTransition:transition];
	return pushedViewController;
}

- (UIViewController *)popViewControllerWithAnimation {
    if (!self.transitionController) {
        return nil;
    }
    NSInteger index = [self.transitionController.viewControllers indexOfObject:self];
    UIViewController *previousViewController = [self.transitionController.viewControllers objectAtIndex:MAX(index - 1, 0)];
    [self.transitionController popViewController]; //这里会自动采用与push对应的pop动画！
    return previousViewController;
}


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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self hideKeyboard];
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
