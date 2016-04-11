//
//  YSCManager.m
//  YSCKit
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "BlocksKit+UIKit.h" //TODO:需要解耦

//检测新版本的几种方法
typedef NS_ENUM(NSInteger, CheckNewVersionType) {
    CheckNewVersionTypeNone         = 0,//关闭更新功能
    CheckNewVersionTypeServer       = 1,//后台接口
    CheckNewVersionTypeAppStore     = 2,//直接检测AppStore是否有新版本上线
};
//新版本描述模型
@interface NewVersionModel : YSCDataModel
@property (nonatomic, strong) NSString *appVersion;         //1.4.17
@property (nonatomic, strong) NSString *appUpdateLog;       //新版本描述
@property (nonatomic, assign) BOOL isForcedUpdate;          //是否强制升级
@property (nonatomic, strong) NSString *appDownloadUrl;     //plist文件的url地址 or appstore's url
@end
@implementation NewVersionModel @end

//--------------------------------------
//  常用操作
//--------------------------------------
@implementation YSCManager
// 检测新版本
+ (void)checkNewVersion {
    if (CheckNewVersionTypeServer == kCheckNewVersionType) {
        [YSCRequestInstance requestFromUrl:kPathAppCommonUrl
                                   withApi:kPathCheckNewVersion
                                    params:nil
                                 dataModel:[NewVersionModel class]
                                      type:YSCRequestTypeGET
                                   success:^(id responseObject) {
                                       NewVersionModel *versionModel = (NewVersionModel *)responseObject;
                                       if (OBJECT_ISNOT_EMPTY(versionModel.appVersion)) {
                                           [self _checkNewVersionWithModel:versionModel isCheckOnAppStore:NO];
                                       }
                                       else {
                                           [self checkNewVersionOnAppStore];
                                       }
                                   }
                                    failed:^(NSString *YSCErrorType, NSError *error) {
                                        [self checkNewVersionOnAppStore];
                                    }];
    }
    else if (CheckNewVersionTypeAppStore == kCheckNewVersionType) {
        [self checkNewVersionOnAppStore];
    }
}
+ (void)checkNewVersionOnAppStore {
    NSURL *checkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kDefaultAppStoreId]];
    [[[NSURLSession sharedSession] dataTaskWithURL:checkUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSDictionary *resultsDict = (NSDictionary *)[NSString jsonObjectOfString:dataString];
        NSArray *results = resultsDict[@"results"];
        if ([results count] > 0) {
            NSDictionary *releaseItem = results[0];
            NSString *onlineVersion = releaseItem[@"version"];//最新版本号
            NSString *releaseNotes = releaseItem[@"releaseNotes"];//最新版本的修改内容
            if (NSOrderedAscending == COMPARE_CURRENT_VERSION(onlineVersion)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NewVersionModel *versionModel = [NewVersionModel new];
                    versionModel.appVersion = onlineVersion;
                    versionModel.appUpdateLog = releaseNotes;
                    versionModel.isForcedUpdate = NO;
                    [self _checkNewVersionWithModel:versionModel isCheckOnAppStore:YES];
                });
            }
        }
    }] resume];
}
+ (void)_checkNewVersionWithModel:(NewVersionModel *)versionModel isCheckOnAppStore:(BOOL)isCheckOnAppStore {
    //1. 取出模型中的参数
    NSString *appVersion = TRIM_STRING(versionModel.appVersion);
    BOOL isSkipTheVersion = [YSCGetCacheObject(APP_SKIP_VERSION(appVersion)) boolValue];
    BOOL isForcedUpdate = versionModel.isForcedUpdate;
    NSString *appUpdateLog = TRIM_STRING(versionModel.appUpdateLog);
    NSString *appDownloadUrl = TRIM_STRING(versionModel.appDownloadUrl);
    if (NO == [appDownloadUrl isUrl]) {
        appDownloadUrl = kDefaultAppUpdateUrl;
    }
    
    //2. 判断是否需要更新
    if (NO == isSkipTheVersion) {
        if (NSOrderedAscending == COMPARE_CURRENT_VERSION(appVersion)) {
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
                    YSCSaveCacheObject(@(YES), APP_SKIP_VERSION(appVersion));
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
                [self checkNewVersionOnAppStore];
            }
        }
    }
    else {
        if (NO == isCheckOnAppStore) {//如果接口未来得及更新升级信息，就自动检测AppStore上的新版本
            [self checkNewVersionOnAppStore];
        }
    }
}

// 打电话
+ (void)makeCall:(NSString *)phoneNumber {
    [self makeCall:phoneNumber success:nil];
}
+ (void)makeCall:(NSString *)phoneNumber success:(YSCBlock)block {
    RETURN_WHEN_OBJECT_IS_EMPTY(phoneNumber)
    if (NO == [UIDevice isCanMakeCall]) {
        [YSCHUDManager showHUDThenHideOnKeyWindow:@"无法拨打电话"];
        return;
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];//去掉-
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[NSString trimString:phoneNumber]]];
    NSString *message = [NSString stringWithFormat:@"确定要拨打电话：%@？", phoneNumber];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:message];
    [alertView bk_addButtonWithTitle:@"确定" handler:^{
        if (block) {
            block();
        }
        [[UIApplication sharedApplication] openURL:phoneURL];
    }];
    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alertView show];
}

// NSURL获取参数
+ (NSDictionary *)getParamsInNSURL:(NSURL *)url {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(url)
    return [self getParamsInQueryString:url.query];
}
+ (NSDictionary *)getParamsInQueryString:(NSString *)queryString {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(queryString)
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

// 获取wifi的mac地址
//1. 全部获取
//{
//    BSSID = "c8:3a:35:57:30:a0";
//    SSID = ZLDNRJB;
//    SSIDDATA = ;
//}
+ (id)fetchSSIDInfo {
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
//2. 只获取BSSID
//{
//    c8:3a:35:57:30:a0
//}
+ (NSString *)currentWifiBSSID {
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
    return [YSCFormatManager formatMacAddress:bssid];
}


// 添加cell
+ (void)insertTableViewCell:(UITableView *)tableView oldCount:(NSInteger)oldCount addCount:(NSInteger)addCount {
    NSMutableArray *insertedIndexPaths = [NSMutableArray array];
    for (int i = 0; i < addCount; i++) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:oldCount + i inSection:0]];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}
+ (void)insertCollectionViewCell:(UICollectionView *)collectionView oldCount:(NSInteger)oldCount addCount:(NSInteger)addCount {
    [UIView setAnimationsEnabled:NO];//默认的动画效果有点乱，这里先把所有动画关掉
    [collectionView performBatchUpdates:^{
        NSMutableArray *insertedIndexPaths = [NSMutableArray array];
        for (int i = 0; i < addCount; i++) {
            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:oldCount + i inSection:0]];
        }
        [collectionView insertItemsAtIndexPaths:insertedIndexPaths];
    }
                             completion:nil];
    [UIView setAnimationsEnabled:YES];
}

// 保存错误日志
+ (void)saveNSError:(NSError *)error {
    NSMutableString *errMsg = [NSMutableString stringWithFormat:@"\r>>>>>>>>>>>>>>>>>>>>errorCode(%ld)>>>>>>>>>>>>>>>>>>>>\r", (long)error.code];
    [errMsg appendFormat:@"errorMessage:%@\r", error];
    [errMsg appendFormat:@"<<<<<<<<<<<<<<<<<<<<errorCode(%ld)<<<<<<<<<<<<<<<<<<<<\r\n", (long)error.code];
    NSLog(@"error=%@", errMsg);
}
@end

