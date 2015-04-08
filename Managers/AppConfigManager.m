//
//  AppConfigManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-6-9.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "AppConfigManager.h"

#define ConfigPlistPath             [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]
#define ConfigDebugPlistPath        [[NSBundle mainBundle] pathForResource:@"AppConfigDebug" ofType:@"plist"]

@interface AppConfigManager ()

@property (nonatomic, strong) NSMutableDictionary *appParams;//缓存app运行过程中永远不变的参数集 TODO:应该保存在document目录下

@end

@implementation AppConfigManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (id)init {
    self  = [super init];
    if (self) {
        self.appParams = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - AppConfig.plist管理

//UMeng参数值优先级 > 本地参数值
- (NSString *)valueOfAppConfig:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(key);
    //0. 获取UMeng的在线参数
    NSString *tempOnlineValue = [self valueOfUMengConfig:key];
    
    //1. 先判断缓存
    if (self.appParams[key]) {
        if ([NSString isNotEmpty:tempOnlineValue] &&
            ( ! [tempOnlineValue isEqualToString:self.appParams[key]])) {
            [self.appParams setValue:tempOnlineValue forKey:key];
        }
        return self.appParams[key];
    }
    NSString *tempValue = @"";//最终需要返回的参数值
    
    //2. 获取本地配置的参数
    NSString *tempLocalValue = [self valueOfLocalConfig:key];
    
    //3. 参数优先级判断(在线参数 > 本地参数)
    if ([NSString isNotEmpty:tempOnlineValue]) {
        tempValue = tempOnlineValue;
    }
    else {
        if ([NSString isNotEmpty:tempLocalValue]) {
            tempValue = tempLocalValue;
        }
    }
    
    //4. 将参数值加入缓存
    if ([NSString isNotEmpty:tempValue]) {
        [self.appParams setValue:tempValue forKey:key];
    }
    return tempValue;
}

//本地配置文件参数值
//TODO:临时缓存
- (NSString *)valueOfLocalConfig:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(key);
    NSString *tempLocalValue = @"";
    if (DEBUGMODEL) {//访问测试环境的配置文件
        if ([FileDefaultManager fileExistsAtPath:ConfigDebugPlistPath]) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigDebugPlistPath];
            tempLocalValue = dict[key];
        }
    }
    else {
        if ([FileDefaultManager fileExistsAtPath:ConfigPlistPath]) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigPlistPath];
            tempLocalValue = dict[key];
        }
    }
    return tempLocalValue;
}

//UMeng在线参数值
//TODO:判断下载完成
- (NSString *)valueOfUMengConfig:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(key);
    NSString *tempOnlineValue = UMengParamValueWithProductVersion(key);//s_1_0_0_kParam
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValueWithAPPVersion(key);//s_1_0_kParam
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValueWithMainVersion(key);//s_1_kParam
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(key);//s_kParam
    }
    return tempOnlineValue;
}

@end
