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

@property (nonatomic, copy) NSDictionary *appConfigDictionary;
@property (nonatomic, copy) NSDictionary *appDebugConfigDictionary;

@end

@implementation AppConfigManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

#pragma mark - AppConfig.plist管理

/**
 *  返回项目配置文件里的配置信息
 *
 *  @param key
 *
 *  @return
 */
- (NSString *)valueInAppConfig:(NSString *)key {
    ReturnEmptyWhenObjectIsEmpty(key);
    if (DEBUGMODEL) {//访问测试配置文件
        if (![FileDefaultManager fileExistsAtPath:ConfigDebugPlistPath]) {
            return @"";
        }
        
        if ( ! self.appDebugConfigDictionary) {
            self.appDebugConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:ConfigDebugPlistPath];
        }
        
        if (self.appDebugConfigDictionary[key]) {
            return self.appDebugConfigDictionary[key];
        }
        else {
            return nil;
        }
    }
    else {//访问正式的配置文件
        if (![FileDefaultManager fileExistsAtPath:ConfigPlistPath]) {
            return @"";
        }
        
        if ( ! self.appConfigDictionary) {
            self.appConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:ConfigPlistPath];
        }
        
        if (self.appConfigDictionary[key]) {
            return self.appConfigDictionary[key];
        }
        else {
            return nil;
        }
    }
}

@end
