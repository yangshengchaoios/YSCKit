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
                         modelName:[NewVersionModel class]
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
    else if (3 == [kCheckNewVersionType integerValue]) {//检测app store上通过审核的新版本
        [YSCCommonUtils checkNewVersionByAppleId:kAppStoreId];
    }
}

//具体检测新版本的业务逻辑
+ (void)checkNewVersion:(NewVersionModel *)versionModel showMessage:(BOOL)showMessage {
    if ([versionModel isKindOfClass:[NewVersionModel class]]) {
        BOOL isSkipTheVersion = [GetCacheObject(Trim(versionModel.appVersion)) boolValue];
        if ( ! isSkipTheVersion) {
            if (NSOrderedAscending == [AppVersion compare:versionModel.appVersion options:NSNumericSearch]) {
//            if (VersionCompareResultAscending == [AppVersion compareWithVersion:versionModel.appVersion]) {
                [UIView hideHUDLoadingOnWindow];
                if ([NSString isNotEmpty:versionModel.appDownloadUrl]) {//TODO:这里可以进一步判断是否是标准的ios更新地址
                    NSString *title = [NSString stringWithFormat:@"发现新版本 %@", versionModel.appVersion];
                    NSString *message = [NSString trimString:versionModel.appUpdateLog];
                    
                    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:message];
                    [alertView bk_setCancelButtonWithTitle:@"立即更新" handler:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionModel.appDownloadUrl]];
                        exit(0);
                    }];
                    if (NO == versionModel.isForcedUpdate ) {   //非强制更新的话才显示更多选项
                        [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                            SaveCacheObject(@(YES), Trim(versionModel.appVersion));
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
+ (void)checkNewVersionByAppleId:(NSString *)appleId {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", appleId]]];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
    NSDictionary *dic = (NSDictionary *)[NSString jsonObjectOfString:results];
    NSArray *infoArray = [dic objectForKey:@"results"];
    if ([infoArray count]) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *onlineVersion = [releaseInfo objectForKey:@"version"];
        NSString *currentVersion = AppVersion;
        if (VersionCompareResultAscending == [currentVersion compareWithVersion:onlineVersion]) {
            NSString *showMsg = [NSString stringWithFormat:@"发现新版本%@，是否前往更新？", onlineVersion];
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"提示" message:showMsg];
            [alertView bk_addButtonWithTitle:@"更新" handler:^{
                NSString *openUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appleId];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
            }];
            [alertView bk_setCancelButtonWithTitle:@"关闭" handler:nil];
            [alertView show];
        }
    }
}
+ (void)configNavigationBar {    
    //改变Navibar的颜色和背景图片
    if (DefaultNaviBarBackImage) {
        [[UINavigationBar appearance] setBackgroundImage:DefaultNaviBarBackImage forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [[UINavigationBar appearance] setBarTintColor:kDefaultNaviTintColor];
    }
    
    //影响范围：icon颜色、left、right文字颜色
    [[UINavigationBar appearance] setTintColor:kDefaultNaviBarTintColor];
    
    //设置Title字体大小和颜色(如果不设置将按默认显示whiteColor)
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : kDefaultNaviBarTitleColor,
                                                           NSFontAttributeName : kDefaultNaviBarTitleFont}];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];//默认样式，带下横线的
    
    //设置BarButtonItem字体大小和颜色(如果不设置将按默认的tintColor显示)
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : kDefaultNaviBarItemColor,
                                                           NSFontAttributeName : kDefaultNaviBarItemFont}
                                                forState:UIControlStateNormal];
}
+ (void)configUmeng {
#pragma mark - 设置UMeng应用的key
//    [MobClick setAppVersion:AppVersion];
//    [UMSocialData openLog:NO];//是否打开调试日志输出
//    [UMFeedback setLogEnabled:NO];
//    [MobClick startWithAppkey:kUMAppKey reportPolicy:REALTIME channelId:kAppChannel];//配置统计
//    [UMSocialData setAppKey:kUMAppKey];//设置友盟社会化组件
//    [UMFeedback checkWithAppkey:kUMAppKey];//配置用户反馈
    
#pragma mark - 分享相关设置
    
    //设置支持没有客户端情况下是否支持单独授权
//    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
//    [UMSocialWechatHandler setWXAppId:AppKeyWeiXin appSecret:AppSecretWeiXin url:AppRedirectUrlOfWeibo];
    
    //打开新浪微博的SSO开关
//    [UMSocialSinaHandler openSSOWithRedirectURL:AppRedirectUrlOfWeibo];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
//    [UMSocialQQHandler setQQWithAppId:AppKeyQQ appKey:AppSecretQQ url:AppRedirectUrlOfWeibo];
    
    //NOTE:打开腾讯微博SSO开关，设置回调地址 只支持32位
//    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:AppRedirectUrlOfWeibo];
}
+ (void)configUmengPushWithOptions:(NSDictionary *)launchOptions {
//    [UMessage startWithAppkey:kUMAppKey launchOptions:launchOptions];
//    [UMessage setLogEnabled:NO];
//    
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
//    if(IOS8_OR_LATER) { //register remoteNotification types
//        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
//        action1.identifier = @"identifier_accept";
//        action1.title = @"打开";
//        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
//        
//        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
//        action2.identifier = @"identifier_reject";
//        action2.title = @"拒绝";
//        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
//        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//        action2.destructive = YES;
//        
//        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
//        categorys.identifier = @"category1";//这组动作的唯一标示
//        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
//        
//        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
//                                                                                     categories:[NSSet setWithObject:categorys]];
//        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
//    }
//    else { //register remoteNotification types
//        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
//         |UIRemoteNotificationTypeSound
//         |UIRemoteNotificationTypeAlert];
//    }
//#else
//    //register remoteNotification types
//    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
//     |UIRemoteNotificationTypeSound
//     |UIRemoteNotificationTypeAlert];
//    
//#endif
}
+ (void)registerForRemoteNotification {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
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
//规范化floatValue：如果有小数点才显示两位，否则就不显示小数点
+ (NSString *)formatFloatValue:(CGFloat)value {
    if (value == floorf(value)) {
        return [NSString stringWithFormat:@"%.0f", value];
    }
    else {
        return [NSString stringWithFormat:@"%.2f", value];
    }
}
+ (NSString *)formatNumberValue:(NSNumber *)value {
    return [self formatFloatValue:value.floatValue];
}
//规范化mac地址
+ (NSString *)formatMacAddress:(NSString *)macAddress {
    NSMutableString *newMacAddress = [NSMutableString string];
    NSArray *array = [NSString splitString:macAddress byRegex:@":"];
    for (NSString *str in array) {
        NSScanner *scanner = [NSScanner scannerWithString:str];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [newMacAddress appendFormat:@"%02x:", intValue];
    }
    if ([newMacAddress length] > 0) {
        return [newMacAddress removeLastChar];
    }
    else {
        return macAddress;
    }
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

#pragma mark - 打开APP的设置并进入隐私界面

+ (void)OpenPrivacyOfSetting {
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"位置服务不可用"
                                                        message:@"请在设置页面打开位置服务，否则在本应用中与定位相关的功能将不可用。"];
    [alertView bk_addButtonWithTitle:@"设置" handler:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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

+ (int)SqliteGetRows:(NSString *)sql {
    return [self SqliteGetRows:sql dbPath:DBRealPath];
}
+ (int)SqliteGetRows:(NSString *)sql dbPath:(NSString *)dbPath {
    int num = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next]) {
            num = [resultSet intForColumnIndex:0];
        }
    }
    [db close];
    return num;
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
//    [button bk_addEventHandler:^(id sender) {
//        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
//        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
//    } forControlEvents:UIControlEventTouchDown];
//    [button bk_addEventHandler:^(id sender) {
//        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
//        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
//        scaleAnimation.springBounciness = 20.0f;
//        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
//    } forControlEvents:UIControlEventTouchUpInside];
//    [button bk_addEventHandler:^(id sender) {
//        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//        scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
//        [button.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
//    } forControlEvents:UIControlEventTouchDragExit];
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
    if ([UIDevice isRunningOnSimulator]) {
        return @"";
    }
    NSString *bssid = nil;
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@", info);
        if (info[@"BSSID"]) {
            bssid = [NSString stringWithFormat:@"%@", info[@"BSSID"]];
            bssid = bssid.lowercaseString;
        }
    }
    return [self formatMacAddress:bssid];
}
//打印出的信息为：（路由器／ 也就是wifi的mac 地址 ）
//{
//c8:3a:35:57:30:a0
//}


#pragma mark - 缓存数据
//------------------------------------
//Document/YSCKit_Storage
//该目录下的数据与业务逻辑相关，删除会影响逻辑
//overwrite = NO
//------------------------------------
+ (BOOL)SaveObject:(NSObject *)object forKey:(NSString *)key {
    return [self SaveObject:object forKey:key fileName:nil subFolder:nil];
}
+ (BOOL)SaveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName {
    return [self SaveObject:object forKey:key fileName:fileName subFolder:nil];
}
+ (BOOL)SaveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self SaveObject:object forKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfDocumentsCommon]];
}

//------------------------------------
//Library/Caches/YSCKit_Storage
//该目录下的数据随时都可以被清除，与用户无关
//overwrite = NO
//------------------------------------
+ (BOOL)SaveCacheObject:(NSObject *)object forKey:(NSString *)key {
    return [self SaveCacheObject:object forKey:key fileName:nil subFolder:nil];
}
+ (BOOL)SaveCacheObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self SaveObject:object forKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfLibraryCachesCommon]];
}


//------------------------------------
//
// Document/YSCKit_Storage
//
//------------------------------------
+ (id)GetObjectForKey:(NSString *)key {
    return [self GetObjectForKey:key fileName:nil subFolder:nil];
}
+ (id)GetObjectForKey:(NSString *)key fileName:(NSString *)fileName {
    return [self GetObjectForKey:key fileName:fileName subFolder:nil];
}
+ (id)GetObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self GetObjectForKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfDocumentsCommon]];
}

//------------------------------------
//
// Library/Caches/YSCKit_Storage
//
//------------------------------------
+ (id)GetCacheObjectForKey:(NSString *)key {
    return [self GetCacheObjectForKey:key fileName:nil subFolder:nil];
}
+ (id)GetCacheObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler {
    return [self GetObjectForKey:key fileName:fileName subFolder:subFoler folder:[STORAGEMANAGER directoryPathOfLibraryCachesCommon]];
}

//------------------------------------
//
// 两个通用方法：存储数据、获取数据
//
//------------------------------------
//存数据的通用方法
+ (BOOL)SaveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFolerName folder:(NSString *)folderPath {
    ReturnNOWhenObjectIsEmpty(key)
    ReturnNOWhenObjectIsEmpty(folderPath)
    if (nil == object) {
        object = [NSNull null];
    }
    
    if (isNotEmpty(subFolerName)) {
        folderPath = [folderPath stringByAppendingPathComponent:subFolerName];
    }
    if (isEmpty(fileName)) {
        fileName = @"CommonSettings";
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL isSuccess = NO;
    @try {
        isSuccess = [STORAGEMANAGER archiveDictionary:@{ key : object }
                                           toFilePath:filePath
                                            overwrite:NO];
    }
    @catch (NSException *exception){
        NSLog(@"将数组保存至本地缓存时出错！%@", exception); //可能是没有在对象里做序列号和反序列化！
        isSuccess = NO;
    }
    return isSuccess;
}
//获取缓存数据通用方法
+ (id)GetObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFolerName folder:(NSString *)folderPath {
    ReturnNilWhenObjectIsEmpty(key)
    ReturnNilWhenObjectIsEmpty(folderPath)
    
    if (isNotEmpty(subFolerName)) {
        folderPath = [folderPath stringByAppendingPathComponent:subFolerName];
    }
    if (isEmpty(fileName)) {
        fileName = @"CommonSettings";
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    NSDictionary *cacheInfo = [STORAGEMANAGER unarchiveDictionaryFromFilePath:filePath];
    NSObject *value = cacheInfo[key];
    if (nil != value && NO == [value isKindOfClass:[NSNull class]]) {
        return value;
    }
    else {
        return nil;
    }
}

@end
