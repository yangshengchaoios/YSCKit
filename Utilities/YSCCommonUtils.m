//
//  CommonUtils.m
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCCommonUtils.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation YSCCommonUtils

+ (void)checkNewVersionShowMessage:(BOOL)showMessage {
    [self checkNewVersionShowMessage:showMessage withParams:nil andType:[kCheckNewVersionType integerValue]];
}
+ (void)checkNewVersionShowMessage:(BOOL)showMessage withParams:(NSDictionary *)params andType:(NSInteger)type {
    if (0 == type) {
        return;
    }
    else if (1 == type) {
        if (showMessage) {
            [UIView showHUDLoadingOnWindow:@"正在检测新版本"];
        }
        [AFNManager getDataFromUrl:kResPathAppCommonUrl
                           withAPI:kResPathCheckNewVersion
                      andDictParam:params
                         modelName:[NewVersionModel class]
                  requestSuccessed:^(id responseObject) {
                      [YSCCommonUtils checkNewVersion:responseObject showMessage:showMessage];
                  }
                    requestFailure:^(ErrorType errorType, NSError *error) {
                        NSString *errMsg = [YSCCommonUtils ResolveErrorType:errorType andError:error];
                        if (showMessage) {
                            [UIView showResultThenHideOnWindow:errMsg];
                        }
                        [YSCCommonUtils checkNewVersionByAppleId:kAppStoreId];
                    }];
    }
    else if (2 == type) {//检测app store上通过审核的新版本
        [YSCCommonUtils checkNewVersionByAppleId:kAppStoreId];
    }
}

//具体检测新版本的业务逻辑
+ (void)checkNewVersion:(NewVersionModel *)versionModel showMessage:(BOOL)showMessage {
    if ([versionModel isKindOfClass:[NewVersionModel class]]) {
        BOOL isSkipTheVersion = [GetCacheObject(SkipVersion(Trim(versionModel.appVersion))) boolValue];
        if ( ! isSkipTheVersion) {
            if (NSOrderedAscending == [AppVersion compare:versionModel.appVersion options:NSNumericSearch]) {
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
                            SaveCacheObject(@(YES), SkipVersion(Trim(versionModel.appVersion)));
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
//常用的价格字符串格式化方法（默认：显示￥、显示小数点）
+ (NSString *)formatPrice:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:NO];
}
//常用的价格字符串格式化方法（默认：显示￥、显示小数点、显示元）
+ (NSString *)formatPriceWithUnit:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:YES];
}
//格式化价格字符串输出
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
        [resultSet close];
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
        [resultSet close];
    }
    [db close];
    return num;
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


#pragma mark - 解析错误信息并格式化输出
//解析错误信息
+ (NSString *)ResolveErrorType:(ErrorType)errorType andError:(NSError *)error {
    NSMutableString *errMsg = [NSMutableString stringWithFormat:@">>>>>>>>>>>>>>>>>>>>ErrorType[%ld]>>>>>>>>>>>>>>>>>>>>", (long)errorType];//错误标记开始
    NSString *messageTitle = @"提示";
    NSString *messageDetail = @"";
    messageDetail = [self ResolveErrorType:errorType];
    if (isEmpty(messageDetail)) {
        messageDetail = GetNSErrorMsg(error);
    }
    if (isEmpty(messageDetail)) {
        messageDetail = @"未知错误";
    }
    
    //继续组织错误日志
    [errMsg appendFormat:@"\r  messageTitle:%@\r  messageDetail:%@", messageTitle, messageDetail];//显示解析后的错误提示
    if (error) {
        [errMsg appendFormat:@"\r  errorCode(%ld)\r  errorMessage:%@", (long)error.code, error];//显示error的错误内容
    }
    [errMsg appendFormat:@"\r<<<<<<<<<<<<<<<<<<<<ErrorType[%ld]<<<<<<<<<<<<<<<<<<<<\r\n", (long)errorType];//错误标记结束
    NSLog(@"errMsg=\r\n%@", errMsg);
    [LogManager saveLog:errMsg];//FIXME:控制是否记录error日志
    return messageDetail;
}
//解析错误码
+ (NSString *)ResolveErrorType:(ErrorType)errorType {
    if (ErrorTypeDisconnected == errorType) {
        return @"网络未连接";
    }
    else if (ErrorTypeConnectionFailed == errorType) {
        return @"网络连接失败";
    }
    else if (ErrorTypeServerFailed == errorType) {
        return @"服务器连接失败";
    }
    else if (ErrorTypeInternalServer == errorType) {
        return @"";//NOTE:需要进一步解析dataModel.state 和 message
    }
    else if (ErrorTypeCopyFileFailed == errorType) {
        return @"拷贝文件失败";
    }
    else if (ErrorTypeURLInvalid == errorType) {
        return @"网络请求的URL不合法";
    }
    else if (ErrorTypeDataEmpty == errorType) {
        return @"返回数据为空";
    }
    else if (ErrorTypeDataMappingFailed == errorType) {
        return @"数据映射本地模型失败";
    }
    else if (ErrorTypeLoginExpired == errorType) {
        return @"登录过期";
    }
    
    return @"";
}
//单独保存error
+ (void)SaveNSError:(NSError *)error {
    NSMutableString *errMsg = [NSMutableString stringWithFormat:@">>>>>>>>>>>>>>>>>>>>errorCode(%ld)>>>>>>>>>>>>>>>>>>>>\r  errorMessage:%@\r<<<<<<<<<<<<<<<<<<<<errorCode(%ld)<<<<<<<<<<<<<<<<<<<<\r\n", (long)error.code, error, (long)error.code];
    NSLog(@"error=\r\n%@", errMsg);
    [LogManager saveLog:errMsg];//FIXME:控制是否记录error日志
}

#pragma mark - 删除多余的日志文件
+ (void)removeLogFilesByCount:(NSInteger)count {
    NSArray *fileNames = [YSCFileUtils allPathsInDirectoryPath:[STORAGEMANAGER directoryPathOfDocumentsLog]];
    NSArray *tempArray = [fileNames sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = [NSDate dateFromString:(NSString *)obj1 withFormat:DateFormat3];
        NSDate *date2 = [NSDate dateFromString:(NSString *)obj2 withFormat:DateFormat3];
        return [date1 isEarlierThanDate:date2];
    }];
    NSInteger index = 0;
    for (NSString *fileName in tempArray) {
        NSDate *tempDate = [NSDate dateFromString:fileName withFormat:DateFormat3];
        if (tempDate) {
            index++;
            if (index > count) {
                NSString *filePath = [[STORAGEMANAGER directoryPathOfDocumentsLog] stringByAppendingPathComponent:fileName];
                [YSCFileUtils deleteFileOrDirectory:filePath];
            }
        }
    }
}

@end
