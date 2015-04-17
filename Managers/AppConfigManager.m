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
        NSString *tempUdid = @"";//保证只获取一次udid就保存在内存中！
        NSDictionary *tempDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"OpenUDID"];
        if ([NSDictionary isNotEmpty:tempDict] && [NSString isNotEmpty:tempDict[@"OpenUDID"]]) {
            tempUdid = Trim(tempDict[@"OpenUDID"]);
        }
        if ([NSString isEmpty:tempUdid]) {
            tempUdid = [UIDevice openUdid];
        }
        _udid = tempUdid;
    }
    return _udid;
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
    
    //2. 判断UMeng在线参数缓存
    tempValue = [self valueOfUMengConfig:name];
    if ([NSString isNotEmpty:tempValue]) {
        [self.appTempParams setValue:tempValue forKey:name];
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

//UMeng在线参数值(保证从该方法返回的都一定是最新的参数值)
- (NSString *)valueOfUMengConfig:(NSString *)name {
    ReturnEmptyWhenObjectIsEmpty(name);
    //0. 检测缓存是否有值
    NSString *tempOnlineValue = Trim(self.umengTempParams[name]);
    if ([NSString isNotEmpty:tempOnlineValue]) {
        return tempOnlineValue;//直接返回内存中的参数值
    }
    
    //1. 针对特定udid的参数
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, self.udid, @"");//s_udid_param
    }
    
    //2. 检测带渠道名称的参数
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, kAppChannel, ProductVersion);//s_AppStore_1_0_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, kAppChannel, AppVersion);//s_AppStore_1_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, kAppChannel, MainVersion);//s_AppStore_1_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, kAppChannel, @"");//s_AppStore_param
    }
    
    //3. 检测不带渠道名称的参数
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, @"", ProductVersion);//s_1_0_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, @"", AppVersion);//s_1_0_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, @"", MainVersion);//s_1_param
    }
    if ([NSString isEmpty:tempOnlineValue]) {
        tempOnlineValue = UMengParamValue(name, @"", @"");//s_param
    }
    
    [self.umengTempParams setValue:tempOnlineValue forKey:name];
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
    return tempString;
}

@end
