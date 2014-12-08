//
//  CommonUtils.m
//  KQ
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

/**
 *  检查是否有新版本需要更新
 */
+ (void)checkNewVersion {
//    return;
    //TODO:远程开关
    
    [AFNManager getDataWithAPI:kResPathAppUpdateNewVersion
                  andDictParam:nil
                     modelName:Class(NewVersionModel)
              requestSuccessed: ^(id responseObject) {
                  NewVersionModel * versionModel = (NewVersionModel *)responseObject;
                  if ([NSObject isNotEmpty:versionModel]) {
                      BOOL isSkipTheVersion = [[NSUserDefaults standardUserDefaults] boolForKey:SkipVersion];
                      if ((! isSkipTheVersion)
                          && (VersionCompareResultAscending == [AppVersion compareWithVersion:versionModel.versionCode])
                          && ([NSString isNotEmpty:versionModel.downloadUrl])) {
                          NSString *title = [NSString stringWithFormat:@"有版本%@需要更新", versionModel.versionCode];
                          NSString *message = [NSString trimString:versionModel.description];
                          
                          UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
                          [alertView bk_addButtonWithTitle:@"立刻升级" handler:^{
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionModel.downloadUrl]];
                              exit(0);
                          }];
                          if ( ! versionModel.isForced ) {   //非强制更新的话才显示更多选项
                              [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SkipVersion];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                              }];
                              [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];//下次启动再次检测
                          }
                          [alertView show];
                      }
                  }
              }
                requestFailure: ^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"errorMessage = %@", errorMessage);
                }];
}

/**
 *  配置Umeng参数
 */
+ (void)configUmeng {
    
    //TODO:远程开关
    NSLog(@"DEBUGMODEL = %d, kUMAppKey = %@", DEBUGMODEL, kUMAppKey);
#pragma mark - 设置UMeng应用的key
    [MobClick setAppVersion:AppVersion];
    if (APPSTORE) {
        [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelAppStore];
    }
    else {
        if (DEBUGMODEL) {
            [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelDebug];
        }
        else {
            [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannelOfficialWebsite];
        }
    }
    
    //统计相关
    
#pragma mark - 分享相关
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:kUMAppKey];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:AppKeyWeiXin appSecret:AppSecretWeiXin url:AppRedirectUrlOfWeibo];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:AppRedirectUrlOfWeibo];
    
    //打开腾讯微博SSO开关，设置回调地址
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:AppRedirectUrlOfWeibo];
    
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:AppKeyQQ appKey:AppSecretQQ url:AppRedirectUrlOfWeibo];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    
#pragma mark - 反馈相关
    [UMFeedback setLogEnabled:YES];
    [UMFeedback checkWithAppkey:kUMAppKey];
}

/**
 *  初始化App默认样式
 */
+ (void)initAppDefaultUI:(NSString *)navibarImageName {
    //将状态栏字体改为白色（前提是要设置[View controller-based status bar appearance]为NO）
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //改变Navibar的颜色和背景图片
    //	[[UINavigationBar appearance] setBarTintColor:kDefaultNaviBarColor];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:navibarImageName]
                                       forBarMetrics:UIBarMetricsDefault];
    //设置字体为白色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //设置Title为白色,Title大小为18
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:18] }];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
}

/**
 *  创建搜索栏
 *
 *  @return
 */
+ (UIView *)createSearchBar:(NSInteger)textFieldTag {
    UIView *searchBoxContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AUTOLAYOUT_LENGTH(412), AUTOLAYOUT_LENGTH(56))];
    //1. 设置搜索框背景图片
    UIImageView *searchBoxImageView = [[UIImageView alloc] initWithFrame:searchBoxContainerView.bounds];
    searchBoxImageView.image = [UIImage imageNamed:@"bg_search"];
    searchBoxImageView.center = searchBoxContainerView.center;
    [searchBoxContainerView addSubview:searchBoxImageView];
    //2. 设置搜索图标icon
    UIImageView *searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    searchIconImageView.left = 10;
    searchIconImageView.centerY = searchBoxContainerView.height / 2;
    [searchBoxContainerView addSubview:searchIconImageView];
    //3. 设置关键词输入框
    UITextField *searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    searchTextField.placeholder = @"搜索商品与店铺";
    searchTextField.font = AUTOLAYOUT_FONT(18);
    searchTextField.textColor = [UIColor whiteColor];
    [searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    searchTextField.tag = textFieldTag;
    searchTextField.height = 24;
    searchTextField.centerY = searchIconImageView.centerY;
    searchTextField.left = CGRectGetMaxX(searchIconImageView.frame) + 10;
    searchTextField.width = searchBoxContainerView.width - searchTextField.left - 10;
    [searchBoxContainerView addSubview:searchTextField];
    
    return searchBoxContainerView;
}


#pragma mark 格式化金额

/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点）
 *
 *  @param price 价格参数
 *
 *  @return
 */
+ (NSString *)formatPrice:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:NO];
}

/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点、显示元）
 *
 *  @param price
 *
 *  @return
 */
+ (NSString *)formatPriceWithUnit:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:YES];
}

/**
 *  格式化价格字符串输出
 *
 *  @param price     价格
 *  @param useTag    是否显示￥
 *  @param isDecimal 是否显示小数点
 *
 *  @return 组装好的字符串
 */
+ (NSString *)formatPrice:(NSNumber *)price showMoneyTag:(BOOL)isTagUsed showDecimalPoint:(BOOL) isDecimal useUnit:(BOOL)isUnitUsed {
    NSString *formatedPrice = @"";
    //是否保留2位小数
    if (isDecimal) {
        formatedPrice = [NSString stringWithFormat:@"%0.2f", [price doubleValue]];
    }
    else {
        formatedPrice = [NSString stringWithFormat:@"%ld", [price integerValue]];
    }
    
    //是否添加前缀 ￥
    if (isTagUsed) {
        formatedPrice = [NSString stringWithFormat:@"￥%@", formatedPrice];
    }
    
    //是否添加后缀 元
    if(isUnitUsed) {
        formatedPrice = [NSString stringWithFormat:@"%@元", formatedPrice];
    }
    
    return formatedPrice;
}


#pragma mark 打电话

+ (void)makeCall:(NSString *)phoneNumber {
    if ([self isEmpty:phoneNumber]) {
        return;
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];//去掉-
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[NSString trimString:phoneNumber]]];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"确定要拨打电话：%@？", phoneNumber]];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        [[UIApplication sharedApplication] openURL:phoneURL];
    }];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView show];
}
@end
