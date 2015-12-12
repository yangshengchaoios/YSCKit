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
@property (nonatomic, strong) NSMutableDictionary *localOnlineParams;
@property (nonatomic, strong) NSMutableDictionary *localParams;
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
        self.localOnlineParams = [NSMutableDictionary dictionary];
        self.localParams = [NSMutableDictionary dictionary];
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
    if (isEmpty(_deviceToken)) {
        _deviceToken = GetObject(@"DeviceToken");
    }
    return Trim(_deviceToken);
}

//重置参数键值对
- (void)resetAppParams {
    [self.localOnlineParams removeAllObjects];
    [self.appParams removeAllObjects];
}

//在线参数值优先级 > 本地参数值
- (NSString *)valueOfAppConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //1. 判断一级缓存
    if (self.appParams[name]) {
        return Trim(self.appParams[name]);
    }
    
    NSString *tempValue = [self valueOfOnlineConfig:name];
    //2. 获取在线配置的参数
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    
    //3. 获取本地配置的参数
    tempValue = [self valueOfLocalConfig:name];
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    return @"";
}

//获取本地缓存的在线参数值
- (NSString *)valueOfOnlineConfig:(NSString *)name {
    if (self.localOnlineParams[name]) {
        return Trim(self.localOnlineParams[name]);
    }
    [self.localOnlineParams removeAllObjects];
    self.localOnlineParams = GetObjectByFile(@"AppParams", @"OnLineParams");
    if (self.localOnlineParams[name]) {
        return Trim(self.localOnlineParams[name]);
    }
    return nil;
}

//获取本地配置文件参数值(只有第一次访问是读取硬盘的文件，以后就直接从内存中读取参数值)
- (NSString *)valueOfLocalConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //1. 检测缓存
    if (self.localParams[name]) {
        return Trim(self.localParams[name]);
    }
    //2. 加载到缓存
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"];
    if (DEBUGMODEL) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"AppConfigDebug" ofType:@"plist"];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [self.localParams removeAllObjects];
    [self.localParams addEntriesFromDictionary:dict];
    if (self.localParams[name]) {
        return Trim(self.localParams[name]);
    }
    return nil;
}

@end
