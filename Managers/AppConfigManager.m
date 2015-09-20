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

@property (nonatomic, strong) NSMutableDictionary *localTempParams;//优先级最低

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
        self.appTempParams = [NSMutableDictionary dictionary];
        self.umengTempParams = [NSMutableDictionary dictionary];
        self.localTempParams = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)udid {
    if (nil == _udid) {
        NSString *tempUdid = GetObject(@"OpenUDID");
        if ([NSString isEmpty:tempUdid]) {
            tempUdid = [UIDevice openUdid];//保证只获取一次udid就保存在内存中！
            if (isNotEmpty(tempUdid)) {
                SaveObject(tempUdid, @"OpenUDID");
            }
        }
        _udid = tempUdid;
    }
    return _udid;
}
- (NSString *)deviceToken {
    if (nil == _deviceToken) {
        _deviceToken = GetObject(@"DeviceToken");
    }
    return Trim(_deviceToken);
}

#pragma mark - AppConfig.plist管理

//UMeng参数值优先级 > 本地参数值
- (NSString *)valueOfAppConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    NSString *tempValue = Trim(self.appTempParams[name]);//最终需要返回的参数值
    //1. 判断一级缓存
    if ([NSString isNotEmpty:tempValue]) {
        return tempValue;
    }
    
    //3. 获取本地配置的参数
    tempValue = [self valueOfLocalConfig:name];
    if ([NSString isNotEmpty:tempValue]) {
        [self.appTempParams setValue:tempValue forKey:name];
        return tempValue;
    }
    return tempValue;
}

//本地配置文件参数值(只有第一次访问是读取硬盘的文件，以后就直接从内存中读取参数值)
- (NSString *)valueOfLocalConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //0. 检测缓存
    NSString *tempLocalValue = Trim(self.localTempParams[name]);
    if ([NSString isNotEmpty:tempLocalValue]) {
        return tempLocalValue;
    }
    //1. 加载到缓存
    if ([NSDictionary isEmpty:self.localTempParams]) {
        if (DEBUGMODEL) {//访问测试环境的配置文件
            if ([FileDefaultManager fileExistsAtPath:ConfigDebugPlistPath]) {
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigDebugPlistPath];
                [self.localTempParams addEntriesFromDictionary:dict];
            }
        }
        else {
            if ([FileDefaultManager fileExistsAtPath:ConfigPlistPath]) {
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ConfigPlistPath];
                [self.localTempParams addEntriesFromDictionary:dict];
            }
        }
        tempLocalValue = Trim(self.localTempParams[name]);
    }
    return tempLocalValue;
}

@end
