//
//  PSOverwriteComponent.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCOverwriteComponent.h"
#import <objc/runtime.h>
#import "YSCPullToRefreshHelper.h"
#import "YSCAFNetworkingAdapter.h"
#import "AFNetworkReachabilityManager.h"

//------------------------------------------------------------
//  重写YSCBaseModel
//------------------------------------------------------------
@interface YSCModel (Demo)
@property (nonatomic, strong) NSString *detailError;
@property (nonatomic, assign) BOOL isError;
@end
@implementation YSCModel (Demo)
YSC_DYNAMIC_PROPERTY_OBJECT(detailError, setDetailError, RETAIN_NONATOMIC, NSString *)
YSC_DYNAMIC_PROPERTY_BOOL(isError, setIsError)
+ (NSDictionary *)propertyNameToJsonKey {
    return @{@"state" : @"ErrCode",
             @"message" : @"Message",
             @"data" : @"Data",
             @"detailError" : @"DetailError",
             @"isError" : @"IsError",
             };
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)checkRequestIsSuccess {
    return ! self.isError;
}
#pragma clang diagnostic pop
@end

//------------------------------------------------------------
//  重写模型基类的网络请求方法
//------------------------------------------------------------
@implementation YSCDataBaseModel (Demo)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
// json NickName -> model nickName
+ (NSString *)jsonKeyFromPropertyName:(NSString *)propertyName {
    return [propertyName ysc_firstCharUpper];
}
#pragma clang diagnostic pop
@end


//------------------------------------------------------------
//  重写网络请求参数封装的方法
//------------------------------------------------------------
@implementation YSCManager (Demo)
- (void)_setupCustomValues {
    @weakiy(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (AFNetworkReachabilityStatusReachableViaWWAN == status) {
            weak_self.reachabilityStatus = YSCReachabilityStatusViaWWAN;
        } else if (AFNetworkReachabilityStatusReachableViaWiFi == status) {
            weak_self.reachabilityStatus = YSCReachabilityStatusViaWiFi;
        } else {
            weak_self.reachabilityStatus = YSCReachabilityStatusNotReachable;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
@end


//------------------------------------------------------------
//  重写网络请求参数封装的方法
//------------------------------------------------------------
@implementation YSCAFNetworkingAdapter (Demo)
- (NSString *)_formatRequestUrl:(NSString *)url withApi:(NSString *)apiName {
    if ([url hasPrefix:kPathVitamio]) {
        NSString *tempApiName = [@"/" stringByAppendingPathComponent:apiName];//组装完整的url地址
        url = [url stringByAppendingString:tempApiName];
    }
    return url;
}
- (NSDictionary *)_formatRequestParams:(NSDictionary *)params
                               withApi:(NSString *)apiName
                                andUrl:(NSString *)url {
    if ([url hasPrefix:kPathVitamio] || [url ysc_isContains:@"api.leancloud.cn"]) {
        NSLog(@"request params:\r%@", params);
        return params;
    }
    else if ([url hasPrefix:kPathDomain]) {// 请求参数头字母必须大写！坑！
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        for (NSString *key in params.allKeys) {
            NSString *firstLetterUpperKey = [key ysc_firstCharUpper];
            tempDict[firstLetterUpperKey] = params[key];
        }
        params = tempDict;
    }
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    mutableDict[@"AppKey"] = kKanPianAppKey;
    mutableDict[@"Body"] = [NSString ysc_jsonStringWithObject:params];
    mutableDict[@"Format"] = @"JSON";
    mutableDict[@"Method"] = TRIM_STRING(apiName);
    mutableDict[@"Sign"] = [self _signatureParams:mutableDict];
    NSLog(@"request params:\r%@", mutableDict);
    return mutableDict;
}
// 计算请求参数的签名
- (NSString *)_signatureParams:(NSDictionary *)params {
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    //0. 按照字典顺序拼接url字符串
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *key in keys) {
        if (OBJECT_IS_EMPTY(params[key])) {
            continue;
        }
        NSString *tempString = [NSString stringWithFormat:@"%@=%@", TRIM_STRING(key), TRIM_STRING(params[key])];
        [tempArray addObject:tempString];
    }
    NSString *joinedString = [tempArray componentsJoinedByString:@"&"];
    
    //1. 计算sing参数
    NSString *sign = [self _hmacsha1:joinedString key:kKanPianAppSecret];
    return sign;
}
- (NSString *)_hmacsha1:(NSString *)sourceString key:(NSString *)key {
    NSData *sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [sourceData ysc_HMACWithAlgorithm:kCCHmacAlgSHA1 key:key];
    return [NSString ysc_EncodeBase64Data:encryptData];
}
@end

//------------------------------------------------------------
//  重写YSCKit框架默认参数
//------------------------------------------------------------
@implementation YSCConfigManager (Demo)
- (void)_setupCustomValues {
    self.appStoreId = @"";
    self.appConfigPlistName = @"KanPian_AppConfig";
    self.appConfigDebugPlistName = @"KanPian_AppConfigDebug";
    self.defaultEmptyMessage = @"暂无记录";
    
    self.defaultViewColor = [UIColor whiteColor];
    self.defaultBorderColor = RGB(230, 230, 230);
    
    self.networkErrorDisconnected = @"网络好像有点问题，请检查后再试";
}
@end
