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

@property (nonatomic, strong) NSMutableDictionary *appParams;//缓存app运行过程中永远不变的参数集

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
//TODO:应该保存在document目录下
- (NSString *)valueOfAppConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //0. 获取UMeng的在线参数
    NSString *tempOnlineValue = [self valueOfUMengConfig:name];
    
    //1. 先判断缓存
    if (self.appParams[name]) {
        if ([NSString isNotEmpty:tempOnlineValue] &&
            ( ! [tempOnlineValue isEqualToString:self.appParams[name]])) {
            [self.appParams setValue:tempOnlineValue forKey:name];
        }
        return self.appParams[name];
    }
    NSString *tempValue = @"";//最终需要返回的参数值
    
    //2. 获取本地配置的参数
    NSString *tempLocalValue = [self valueOfLocalConfig:name];
    
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
        [self.appParams setValue:tempValue forKey:name];
    }
    return tempValue;
}

//本地配置文件参数值
//TODO:临时缓存
- (NSString *)valueOfLocalConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    NSString *tempLocalValue = @"";
    if (DEBUGMODEL) {//访问测试环境的配置文件
        if ([FileDefaultManager fileExistsAtPath:ConfigDebugPlistPath]) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigDebugPlistPath];
            tempLocalValue = dict[name];
        }
    }
    else {
        if ([FileDefaultManager fileExistsAtPath:ConfigPlistPath]) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigPlistPath];
            tempLocalValue = dict[name];
        }
    }
    return tempLocalValue;
}

//UMeng在线参数值
//TODO:判断下载完成
- (NSString *)valueOfUMengConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //1. 检测待渠道名称的参数
    NSString *tempOnlineValue = @"";//TODO:临时缓存
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,kAppChannel,ProductVersion);//s_AppStore_1_0_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,kAppChannel,AppVersion);//s_AppStore_1_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,kAppChannel,MainVersion);//s_AppStore_1_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,kAppChannel,@"");//s_AppStore_param
    }
    
    //检测不带渠道名称的参数
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,@"",ProductVersion);//s_1_0_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,@"",AppVersion);//s_1_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,@"",MainVersion);//s_1_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name,@"",@"");//s_param
    }
    
    NSLog(@"UMeng param[%@] value:%@", name, tempOnlineValue);
    return tempOnlineValue;
}

//组装UMeng在线参数名称
- (NSString *)UMengParamName:(NSString *)name withChannel:(NSString *)channel andVersion:(NSString *)version {
    ReturnEmptyWhenObjectIsEmpty(name)
    NSMutableString *tempString = [NSMutableString stringWithString:@"s_"];
    if ([NSString isNotEmpty:channel]) {
        [tempString appendFormat:@"%@_", channel];
    }
    if ([NSString isNotEmpty:version]) {
        [tempString appendFormat:@"%@_", [NSString replaceString:version byRegex:@"\\." to:@"_"]];
    }
    [tempString appendString:name];
    NSLog(@"UMeng param:%@", tempString);
    return tempString;
}

@end
