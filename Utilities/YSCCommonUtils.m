//
//  CommonUtils.m
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCCommonUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+CommonCrypto.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation YSCCommonUtils

+ (void)checkNewVersionShowMessage:(BOOL)showMessage {
    [self checkNewVersionShowMessage:showMessage withParams:nil];
}
+ (void)checkNewVersionShowMessage:(BOOL)showMessage withParams:(NSDictionary *)params {
    if (0 == [kCheckNewVersionType integerValue]) {
        return;
    }
    else if (1 == [kCheckNewVersionType integerValue]) {
        if ([NSString isNotUrl:kCheckNewVersionUrl]) {
            return;
        }
        if (showMessage) {
            [UIView showHUDLoadingOnWindow:@"正在检测新版本"];
        }
        [AFNManager getDataFromUrl:kCheckNewVersionUrl
                           withAPI:@""
                      andDictParam:params
                         modelName:ClassOfObject(NewVersionModel)
                  requestSuccessed: ^(id responseObject) {
                      [YSCCommonUtils checkNewVersion:responseObject showMessage:showMessage];
                  }
                    requestFailure: ^(NSInteger errorCode, NSString *errorMessage) {
                        if (showMessage) {
                            [UIView showResultThenHideOnWindow:errorMessage];
                        }
                    }];
    }
    else if (2 == [kCheckNewVersionType integerValue]) {
        NSString *tempModel = kNewVersionModel;
        if ([NSString isNotEmpty:tempModel]) {
            NewVersionModel *versionModel = [[NewVersionModel alloc] initWithString:tempModel error:nil];
            if ([versionModel isKindOfClass:[NewVersionModel class]]) {
                [YSCCommonUtils checkNewVersion:versionModel showMessage:showMessage];
            }
        }
    }
}

//具体检测新版本的业务逻辑
+ (void)checkNewVersion:(NewVersionModel *)versionModel showMessage:(BOOL)showMessage {
    if ([versionModel isKindOfClass:[NewVersionModel class]]) {
        BOOL isSkipTheVersion = [[NSUserDefaults standardUserDefaults] boolForKey:SkipVersion];
        if ( ! isSkipTheVersion) {
            if (VersionCompareResultAscending == [AppVersion compareWithVersion:versionModel.versionCode]) {
                [UIView hideHUDLoadingOnWindow];
                if ([NSString isNotEmpty:versionModel.appUrl]) {//TODO:这里可以进一步判断是否是标准的ios更新地址
                    NSString *title = [NSString stringWithFormat:@"发现新版本 %@", versionModel.versionCode];
                    NSString *message = [NSString trimString:versionModel.appUpdateLog];
                    
                    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
                    [alertView bk_setCancelButtonWithTitle:@"立即更新" handler:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionModel.appUrl]];
                        exit(0);
                    }];
                    if (NO == versionModel.isForcedUpdate ) {   //非强制更新的话才显示更多选项
                        [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SkipVersion];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }];
                        [alertView bk_addButtonWithTitle:@"稍后再说" handler:nil];//下次启动再次检测
                    }
                    [alertView show];
                }
                else {
                    [UIView showAlertVieWithMessage:@"下载地址出错"];
                }
            }
            else {
                if (showMessage) {
                    [UIView showResultThenHideOnWindow:@"已经是最新版本"];
                }
            }
        }
        else {
            [UIView hideHUDLoadingOnWindow];
        }
    }
    else {
        if (showMessage) {
            [UIView showResultThenHideOnWindow:@"版本检测出错"];
        }
    }
}

//设置App样式
+ (void)configNavigationBar {
    //将状态栏字体改为白色（前提是要设置[View controller-based status bar appearance]为NO）
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //改变Navibar的颜色和背景图片
    if (DefaultNaviBarBackImage) {
        [[UINavigationBar appearance] setBackgroundImage:DefaultNaviBarBackImage forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [[UINavigationBar appearance] setBarTintColor:DefaultNaviBarBackColor];
    }
    
    //控制返回箭头按钮的颜色
    [[UINavigationBar appearance] setTintColor:DefaultNaviBarArrowBackColor];
    
    //设置Title为白色,Title大小为18
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : DefaultNaviBarTitleColor,
                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:22] }];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
}

/**
 *  配置Umeng参数
 */
+ (void)configUmeng {
#pragma mark - 设置UMeng应用的key
    [MobClick setAppVersion:AppVersion];
    [UMSocialData openLog:NO];//是否打开调试日志输出
    [UMFeedback setLogEnabled:NO];
    [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannel];//配置统计
    [UMSocialData setAppKey:kUMAppKey];//设置友盟社会化组件
    [UMFeedback checkWithAppkey:kUMAppKey];//配置用户反馈
    
#pragma mark - 分享相关设置
    
    //设置支持没有客户端情况下是否支持单独授权
//    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:AppKeyWeiXin appSecret:AppSecretWeiXin url:AppRedirectUrlOfWeibo];
    
    //打开新浪微博的SSO开关
//    [UMSocialSinaHandler openSSOWithRedirectURL:AppRedirectUrlOfWeibo];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
//    [UMSocialQQHandler setQQWithAppId:AppKeyQQ appKey:AppSecretQQ url:AppRedirectUrlOfWeibo];
    
    //NOTE:打开腾讯微博SSO开关，设置回调地址 只支持32位
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:AppRedirectUrlOfWeibo];
}
/**
 *  配置Umeng的推送功能
 */
+ (void)configUmengPushWithOptions:(NSDictionary *)launchOptions {
    [UMessage startWithAppkey:kUMAppKey launchOptions:launchOptions];
    [UMessage setLogEnabled:NO];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(IOS8_OR_LATER) { //register remoteNotification types
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"identifier_accept";
        action1.title = @"打开";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"identifier_reject";
        action2.title = @"拒绝";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
    }
    else { //register remoteNotification types
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    //register remoteNotification types
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
}

/**
 *  创建搜索框
 *
 *  @param width     宽度
 *  @param textField 输入框
 *
 *  @return
 */
+ (UIView *)createSearchViewWithWidth:(NSInteger)width withTextField:(UITextField *)textField {
    if (width <= 0) {
        width = NSIntegerMax;
    }
    UIView *searchBoxContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AUTOLAYOUT_LENGTH(width), AUTOLAYOUT_LENGTH(60))];
    searchBoxContainerView.backgroundColor = RGBA(10, 10, 10, 0.3);
    [UIView makeRoundForView:searchBoxContainerView withRadius:AUTOLAYOUT_LENGTH(60) / 2];
    
    //1. 设置搜索框背景图片
//    UIImageView *searchBoxImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    searchBoxImageView.image = [UIImage imageNamed:@"bg_searchBlack"];
//    [searchBoxContainerView addSubview:searchBoxImageView];
//    [searchBoxImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
//    [searchBoxImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
//    [searchBoxImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
//    [searchBoxImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    
    //2. 设置搜索图标icon
    UIImageView *searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    [searchBoxContainerView addSubview:searchIconImageView];
    [searchIconImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:AUTOLAYOUT_LENGTH(15)];
    [searchIconImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    //3. 设置关键词输入框
    textField.font = AUTOLAYOUT_FONT(28);
    textField.textColor = [UIColor whiteColor];
    [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [searchBoxContainerView addSubview:textField];
    [textField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:AUTOLAYOUT_LENGTH(60)];
    [textField autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [textField autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [textField autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:AUTOLAYOUT_LENGTH(10)];
    
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
        formatedPrice = [NSString stringWithFormat:@"%ld", (long)[price integerValue]];
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

+ (void)MakeCall:(NSString *)phoneNumber {
    [self MakeCall:phoneNumber success:nil];
}

+ (void)MakeCall:(NSString *)phoneNumber success:(void (^)(void))block {
    if ([self isEmpty:phoneNumber]) {
        return;
    }
    if (NO == [UIDevice isCanMakeCall]) {
        [UIView showResultThenHideOnWindow:@"无法拨打电话"];
        return;
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];//去掉-
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[NSString trimString:phoneNumber]]];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示"
                                                        message:[NSString stringWithFormat:@"确定要拨打电话：%@？", phoneNumber]];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        if (block) {
            block();
        }
        [[UIApplication sharedApplication] openURL:phoneURL];
    }];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView show];
}

#pragma makr - Sqlite操作

+ (BOOL)SqliteUpdate:(NSString *)sql {
    return [self SqliteUpdate:sql dbPath:DBRealPath];
}

+ (BOOL)SqliteUpdate:(NSString *)sql dbPath:(NSString *)dbPath {
    BOOL isSuccess = NO;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        isSuccess = [db executeUpdate:sql];
    }
    [db close];
    return isSuccess;
}

+ (BOOL)SqliteCheckIfExists:(NSString *)sql {
    return [self SqliteCheckIfExists:sql dbPath:DBRealPath];
}
+ (BOOL)SqliteCheckIfExists:(NSString *)sql dbPath:(NSString *)dbPath {
    BOOL isExists = NO;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet) {
            isExists = [resultSet next];
        }
    }
    [db close];
    return isExists;
}

#pragma mark - 过去了多长时间
/**
 *  1. 如果是1分钟以内  返回 'xx秒之前'
 *  2. 如果是60分钟以内 返回 'xx分钟之前'
 *  3. 如果是大于1小时且在当天  返回 'x小时之前'
 *  4. 如果是昨天      返回  '昨天hh:mm:ss'
 *  5. 如果是前天      返回  '前天hh:mm:ss'
 *  6. 今年以内        返回  'MM-dd'
 *  7. 其它           返回  'yyyy-MM-dd'
 *
 *  @param startTimeStamp 开始的时间戳
 *
 *  @return
 */
+ (NSString *)TimePassed:(NSString *)timeStamp {
    NSDate *startDateTime = [NSDate dateFromTimeStamp:timeStamp];
    NSDate *nowDateTime = [NSDate date];
    //其它
    if ([startDateTime isLastYear] || [startDateTime isLaterThanDate:nowDateTime]) {
        return [startDateTime stringWithFormat:DateFormat3];
    }
    
    //当年以内
    if ([startDateTime isEarlierThanDate:[[NSDate dateBeforeYesterday] dateAtStartOfDay]]) {
        return [startDateTime stringWithFormat:@"MM-dd"];
    }
    
    //判断前天
    if ([startDateTime isBeforeYesterday]) {
        return [NSString stringWithFormat:@"前天%@",[startDateTime stringWithFormat:@"hh:mm:ss"]];
    }
    
    //判断昨天
    if ([startDateTime isYesterday]) {
        return [NSString stringWithFormat:@"昨天%@",[startDateTime stringWithFormat:@"hh:mm:ss"]];
    }
    
    NSInteger hoursPassed = [startDateTime hoursBeforeDate:nowDateTime];
    NSInteger minutesPassed = [startDateTime minutesBeforeDate:nowDateTime];
    NSInteger secondsPassed = (NSInteger)[nowDateTime timeIntervalSinceDate:startDateTime];
    if (hoursPassed > 0) {
        return [NSString stringWithFormat:@"%ld小时之前", (long)hoursPassed];
    }
    if (minutesPassed > 0) {
        return [NSString stringWithFormat:@"%ld分钟之前", (long)minutesPassed];
    }
    return [NSString stringWithFormat:@"%ld秒之前", (long)secondsPassed];
}
+ (NSString *)TimeRemain:(NSString *)timeStamp {
    return [self TimeRemain:timeStamp currentTime:[[NSDate date] timeStamp]];
}
+ (NSString *)TimeRemain:(NSString *)timeStamp currentTime:(NSString *)currentTime {
    NSDate *nowDateTime = [NSDate dateFromTimeStamp:currentTime];
    NSDate *endDateTime = [NSDate dateFromTimeStamp:timeStamp];
    //其它
    if ([endDateTime isNextYear] || [endDateTime isEarlierThanDate:nowDateTime]) {
        return [endDateTime stringWithFormat:DateFormat3];
    }
    
    //当年以内，7天以后
    if ([endDateTime isLaterThanDate:[NSDate dateWithDaysFromNow:7]]) {
        return [endDateTime stringWithFormat:@"MM-dd"];
    }
    
    //7天以内
    if ( ! [endDateTime isToday]) {
        NSInteger days = [endDateTime daysAfterDate:nowDateTime];
        NSInteger hours = [endDateTime hoursAfterDate:[nowDateTime dateByAddingDays:days]];
        return [NSString stringWithFormat:@"%ld天 %ld小时", (long)days, (long)hours];
    }
    
    //xx:xx:xx
    return [[NSDate dateFromTimeInterval:[endDateTime timeIntervalSinceDate:nowDateTime]] stringWithFormat:@"HH:mm:ss"];
}

#pragma mark - NSURL获取参数

+ (NSDictionary *)GetParamsInNSURL:(NSURL *)url {
    ReturnNilWhenObjectIsEmpty(url)
    return [self GetParamsInQueryString:url.query];
}

+ (NSDictionary *)GetParamsInQueryString:(NSString *)queryString {
    ReturnNilWhenObjectIsEmpty(queryString)
    NSScanner *scanner = [NSScanner scannerWithString:queryString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    if ([queryString isContains:@"?"]) {
        [scanner scanUpToString:@"?" intoString:nil];//skip to ?
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *tmpValue;
    while ([scanner scanUpToString:@"&" intoString:&tmpValue]) {
        NSArray *components = [tmpValue componentsSeparatedByString:@"="];
        if (components.count >= 2) {
            NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *value = [components[1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            parameters[key] = value;
        }
    }
    return parameters;
}

#pragma mark - UIButton添加pop动画

+ (void)addPopAnimationToButton:(UIButton *)button {
    [button bk_addEventHandler:^(id sender) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
    } forControlEvents:UIControlEventTouchDown];
    [button bk_addEventHandler:^(id sender) {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        scaleAnimation.springBounciness = 20.0f;
        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
    } forControlEvents:UIControlEventTouchUpInside];
    [button bk_addEventHandler:^(id sender) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
    } forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark - AES加密解密(与java调通)

+ (NSString *)AESEncryptString:(NSString *)string byKey:(NSString *)key {
    CCCryptorStatus status = kCCSuccess;
    NSData* result = [[string dataUsingEncoding:NSUTF8StringEncoding]
                      dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                      key:key
                      initializationVector:nil   // ECB加密不会用到iv
                      options:(kCCOptionPKCS7Padding|kCCOptionECBMode)
                      error:&status];
    if (status != kCCSuccess) {
        NSLog(@"加密失败:%d", status);
        return nil;
    }
    return [NSString EncodeBase64Data:result];
}

+ (NSString *)AESDecryptString:(NSString *)string byKey:(NSString *)key {
    CCCryptorStatus status = kCCSuccess;
    NSData *decryptData = [[NSData alloc] initWithBase64EncodedData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData* result = [decryptData
                      decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                      key:key
                      initializationVector:nil   // ECB解密不会用到iv
                      options:(kCCOptionPKCS7Padding|kCCOptionECBMode)
                      error:&status];
    if (status != kCCSuccess) {
        NSLog(@"解密失败:%d", status);
        return nil;
    }
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

//-----------------------------------
//
// 获取当前wifi的网关mac地址
//
//-----------------------------------
//1。全部获取
+ (id)FetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}
//打印出的信息为：
//{
//    BSSID = "c8:3a:35:57:30:a0";
//    SSID = ZLDNRJB;
//    SSIDDATA = ;
//}

//2。按需求获取
+ (NSString *)CurrentWifiBSSID {
    //NOTE: Does not work on the simulator.    
//    if ([UIDevice isRunningOnSimulator]) {
//        return @"";
//    }
    NSString *bssid = nil;
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@", info);
        if (info[@"BSSID"]) {
            bssid = [NSString stringWithFormat:@"%@", info[@"BSSID"]];
            bssid = bssid.uppercaseString;
        }
    }
    return bssid;
}
//打印出的信息为：（路由器／ 也就是wifi的mac 地址 ）
//{
//c8:3a:35:57:30:a0
//}

@end
