//
//  CommonUtils.m
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCCommonUtils.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ServerTimeSynchronizer.h"
#import "MLBlackTransition.h"

@implementation YSCCommonUtils

#pragma mark - 检测新版本
+ (void)checkNewVersion {
    [self checkNewVersionWithParams:nil type:[kCheckNewVersionType integerValue]];
}
+ (void)checkNewVersionWithParams:(NSDictionary *)params type:(CheckNewVersionType)type {
    if (CheckNewVersionTypeServer == type) {
        [AFNManager getDataFromUrl:kResPathAppCommonUrl
                           withAPI:kResPathCheckNewVersion
                      andDictParam:params
                         dataModel:[NewVersionModel class]
                  requestSuccessed:^(id responseObject) {
                      NewVersionModel *versionModel = (NewVersionModel *)responseObject;
                      if (isNotEmpty(versionModel.appVersion)) {
                          [YSCCommonUtils checkNewVersionWithModel:versionModel isCheckOnAppStore:NO];
                      }
                      else {
                          [YSCCommonUtils checkNewVersionOnAppStore];
                      }
                  }
                    requestFailure:^(ErrorType errorType, NSError *error) {
                        [YSCCommonUtils checkNewVersionOnAppStore];
                    }];
    }
    else if (CheckNewVersionTypeAppStore == type) {
        [YSCCommonUtils checkNewVersionOnAppStore];
    }
}
//检测本APP在AppStore上是否有新版本上线
+ (void)checkNewVersionOnAppStore {
    NSURL *checkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kAppStoreId]];
    [[[NSURLSession sharedSession] dataTaskWithURL:checkUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSDictionary *resultsDict = (NSDictionary *)[NSString jsonObjectOfString:dataString];
        NSArray *results = resultsDict[@"results"];
        if ([results count] > 0) {
            NSDictionary *releaseItem = results[0];
            NSString *onlineVersion = releaseItem[@"version"];//最新版本号
            NSString *releaseNotes = releaseItem[@"releaseNotes"];//最新版本的修改内容
            if (NSOrderedAscending == [AppVersion compare:onlineVersion options:NSNumericSearch]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NewVersionModel *versionModel = [NewVersionModel new];
                    versionModel.appVersion = onlineVersion;
                    versionModel.appUpdateLog = releaseNotes;
                    versionModel.isForcedUpdate = NO;
                    [YSCCommonUtils checkNewVersionWithModel:versionModel isCheckOnAppStore:YES];
                });
            }
        }
    }] resume];
}
//具体检测新版本的业务逻辑
+ (void)checkNewVersionWithModel:(NewVersionModel *)versionModel isCheckOnAppStore:(BOOL)isCheckOnAppStore {
    //1. 取出模型中的参数
    NSString *appVersion = Trim(versionModel.appVersion);
    BOOL isSkipTheVersion = [GetCacheObject(SkipVersion(appVersion)) boolValue];
    BOOL isForcedUpdate = versionModel.isForcedUpdate;
    NSString *appUpdateLog = Trim(versionModel.appUpdateLog);
    NSString *appDownloadUrl = Trim(versionModel.appDownloadUrl);
    if (NO == [appDownloadUrl isUrl]) {
        appDownloadUrl = AppUpdateUrl;
    }
    
    //2. 判断是否需要更新
    if (NO == isSkipTheVersion) {
        if (NSOrderedAscending == [AppVersion compare:appVersion options:NSNumericSearch]) {
            //0. 判断是否重复调用(APP第一次运行时如果有alertView需要处理，则applicationDidBecomeActive在处理完后会再次被调用，从而导致版本检测调用多次而出问题)
            static BOOL isAlertShow = NO;
            if (isAlertShow) {
                return;
            }
            isAlertShow = YES;
            
            //1. 显示新版本提示
            NSString *title = [NSString stringWithFormat:@"发现新版本 %@", appVersion];
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:title message:appUpdateLog];
            [alertView bk_setCancelButtonWithTitle:@"立即更新" handler:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDownloadUrl]];
                exit(0);
            }];
            if (NO == isForcedUpdate ) {   //非强制更新的话才显示更多选项
                [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                    SaveCacheObject(@(YES), SkipVersion(appVersion));
                    isAlertShow = NO;
                }];
                [alertView bk_addButtonWithTitle:@"稍后再说" handler:^{
                    isAlertShow = NO;
                }];//下次启动再次检测
            }
            [alertView show];
        }
        else {
            if (NO == isCheckOnAppStore) {//如果接口未来得及更新升级信息，就自动检测AppStore上的新版本
                [YSCCommonUtils checkNewVersionOnAppStore];
            }
        }
    }
    else {
        if (NO == isCheckOnAppStore) {//如果接口未来得及更新升级信息，就自动检测AppStore上的新版本
            [YSCCommonUtils checkNewVersionOnAppStore];
        }
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
//格式化输出json到console(格式化失败返回empty)
+ (NSString *)FormatPrintJsonStringOnConsole:(NSString *)jsonString {
    if (isNotEmpty(jsonString)) {
        NSError *error = nil;
        id data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:0
                                                    error:&error];
        if (nil == error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (nil == error) {
                return (jsonData) ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : @"";
            }
            else {
                return @"";
            }
        }
        else {
            return @"";
        }
    }
    else {
        return @"";
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
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
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
    NSMutableString *errMsg = [NSMutableString stringWithFormat:@"\r>>>>>>>>>>>>>>>>>>>>ErrorType[%ld]>>>>>>>>>>>>>>>>>>>>\r", (long)errorType];//错误标记开始
    NSString *messageTitle = @"提示";
    NSString *messageDetail = [self ResolveErrorType:errorType];
    if (isEmpty(messageDetail)) {
        messageDetail = GetNSErrorMsg(error);
    }
    if (isEmpty(messageDetail)) {
        messageDetail = @"未知错误";
    }
    
    //继续组织错误日志
    [errMsg appendFormat:@"  messageTitle:%@\r  messageDetail:%@\r", messageTitle, messageDetail];//显示解析后的错误提示
    if (error) {
        [errMsg appendFormat:@"  errorCode:%ld\r  errorMessage:%@\r", (long)error.code, error];//显示error的错误内容
    }
    [errMsg appendFormat:@"<<<<<<<<<<<<<<<<<<<<ErrorType[%ld]<<<<<<<<<<<<<<<<<<<<\r\n", (long)errorType];//错误标记结束
    NSLog(@"errMsg=%@", errMsg);
    [LogManager saveLog:errMsg];
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
    NSMutableString *errMsg = [NSMutableString stringWithFormat:@"\r>>>>>>>>>>>>>>>>>>>>errorCode(%ld)>>>>>>>>>>>>>>>>>>>>\r", (long)error.code];
    [errMsg appendFormat:@"errorMessage:%@\r", error];
    [errMsg appendFormat:@"<<<<<<<<<<<<<<<<<<<<errorCode(%ld)<<<<<<<<<<<<<<<<<<<<\r\n", (long)error.code];
    NSLog(@"error=%@", errMsg);
    [LogManager saveLog:errMsg];
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

#pragma mark - Label上显示HTML
//只能显示HTML内容，但不能点击链接
//view包括:UILabel UITextField UITextView
+ (void)LayoutHtmlString:(NSString *)htmlString onView:(UIView *)view {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                                                   options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                        documentAttributes:nil
                                                                     error:nil];
    if ([view respondsToSelector:@selector(setAttributedText:)]) {
        [view performSelector:@selector(setAttributedText:) withObject:attrStr];
    }
}
//根据正则表达式设置attributedString的各项参数
//regular: 正则表达式
//attributes: 每个满足ragular的attri
+ (void)FillMutableAttributedString:(NSMutableAttributedString *)attributedString byRegular:(NSRegularExpression *)regular attributes:(NSDictionary *)attributes {
    ReturnWhenObjectIsEmpty(attributedString);
    ReturnWhenObjectIsEmpty(regular);
    ReturnWhenObjectIsEmpty(attributedString.string);
    
    NSRange stringRange = NSMakeRange(0, [attributedString.string length]);
    [regular enumerateMatchesInString:attributedString.string
                                 options:0
                                   range:stringRange
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  //0. 获取到匹配的范围
                                  NSRange matchRange = [result range];
                                  //1. 设置通用的attribute
                                  if (attributes) {
                                      [attributedString addAttributes:attributes range:matchRange];
                                  }
                                  //2. 分别设置匹配项目的attribute
                                  if ([result resultType] == NSTextCheckingTypeLink) {
                                      NSURL *url = [result URL];
                                      [attributedString addAttribute:NSLinkAttributeName value:url range:matchRange];
                                  }
                                  else if ([result resultType] == NSTextCheckingTypePhoneNumber) {
                                      NSString *phoneNumber = [result phoneNumber];
                                      [attributedString addAttribute:NSLinkAttributeName value:phoneNumber range:matchRange];
                                  }
                                  else {
                                      //其它特殊内容
                                  }
                              }];
}

#pragma mark - 获取当前(服务器端)时间
+ (NSDate *)currentDate {
    return [NSDate dateFromTimeStamp:[ServerTimeSynchronizer sharedInstance].currentTimeInterval];
}
+ (NSTimeInterval)currentTimeInterval {
    return [[ServerTimeSynchronizer sharedInstance].currentTimeInterval doubleValue];
}


#pragma mark - Global Configuration
+ (void)ConfigNavigationBar {
    //设置BarButtonItem字体大小和颜色(如果不设置将按默认的tintColor显示)
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : kDefaultNaviBarItemColor,
                                                           NSFontAttributeName : kDefaultNaviBarItemFont}
                                                forState:UIControlStateNormal];
    //其它大部分的设置都放在创建navigationController([UIResponder createNavi])中了
}
+ (void)ConfigPullToBack {
    [MLBlackTransition validatePanPackWithMLBlackTransitionGestureRecognizerType:MLBlackTransitionGestureRecognizerTypeScreenEdgePan];
}
+ (void)RegisterForRemoteNotification {
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

@end
