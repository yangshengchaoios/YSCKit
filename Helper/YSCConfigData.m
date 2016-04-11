//
//  YSCConfigData.m
//  KanPian
//
//  Created by 杨胜超 on 16/4/8.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import "YSCConfigData.h"

@interface YSCConfigData ()
@property (nonatomic, strong) NSMutableDictionary *appParams;           //内存中的参数(high)
@property (nonatomic, strong) NSMutableDictionary *onlineParams;        //在线参数(normal)
@property (nonatomic, strong) NSMutableDictionary *localParams;         //本地参数(low)
@end

@implementation YSCConfigData
+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}
- (id)init {
    self = [super init];
    if (self) {
        self.appParams = [NSMutableDictionary dictionary];
        self.onlineParams = [NSMutableDictionary dictionary];
        self.localParams = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)resetConfigParams {
    [self.onlineParams removeAllObjects];
    [self.appParams removeAllObjects];
}
- (BOOL)boolFromConfigByName:(NSString *)name {
    RETURN_NO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value boolValue];
}
- (float)floatFromConfigByName:(NSString *)name {
    RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value floatValue];
}
- (NSInteger)intFromConfigByName:(NSString *)name {
    RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [value integerValue];
}
- (UIColor *)colorFromConfigByName:(NSString *)name {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [UIColor colorWithRGBString:value];
}
- (UIImage *)imageFromConfigByName:(NSString *)name {
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(name);
    NSString *value = [self stringFromConfigByName:name];
    return [UIImage imageNamed:value];
}
- (NSString *)stringFromConfigByName:(NSString *)name {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(name);
    //1. 判断一级缓存
    if (self.appParams[name]) {
        return TRIM_STRING(self.appParams[name]);
    }
    
    NSString *tempValue = [self _valueOfOnlineConfig:name];
    //2. 获取在线配置的参数
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    
    //3. 获取本地配置的参数
    tempValue = [self _valueOfLocalConfig:name];
    if (nil != tempValue) {
        self.appParams[name] = tempValue;
        return tempValue;
    }
    return @"";
}
// 获取本地缓存的在线参数值
- (NSString *)_valueOfOnlineConfig:(NSString *)name {
    if (self.onlineParams[name]) {
        return TRIM_STRING(self.onlineParams[name]);
    }
    [self.onlineParams removeAllObjects];
    self.onlineParams = YSCGetObjectByFile(@"AppParams", @"OnLineParams");
    if (self.onlineParams[name]) {
        return TRIM_STRING(self.onlineParams[name]);
    }
    return nil;
}
// 获取本地配置文件参数值(只有第一次访问是读取硬盘的文件，以后就直接从内存中读取参数值)
- (NSString *)_valueOfLocalConfig:(NSString *)name {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(name);
    //1. 检测缓存
    if (self.localParams[name]) {
        return TRIM_STRING(self.localParams[name]);
    }
    //2. 加载到缓存
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kAppConfigPlist ofType:@"plist"];
    if (DEBUG_MODEL) {
        plistPath = [[NSBundle mainBundle] pathForResource:kAppConfigDebugPlist ofType:@"plist"];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [self.localParams removeAllObjects];
    [self.localParams addEntriesFromDictionary:dict];
    if (self.localParams[name]) {
        return TRIM_STRING(self.localParams[name]);
    }
    return nil;
}
@end
