//
//  AppConfigManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-6-9.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>

@interface AppConfigManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *appTempParams;       //优先级最高
@property (nonatomic, strong) NSMutableDictionary *umengTempParams;     //优先级次之
@property (nonatomic, strong) NSString *udid;                   //设备唯一编号

+ (instancetype)sharedInstance;

#pragma mark - AppConfig.plist管理

- (NSString *)valueOfAppConfig:(NSString *)name;     //UMeng参数值优先级 > 本地参数值
- (NSString *)valueOfLocalConfig:(NSString *)name;   //本地配置文件参数值
- (NSString *)valueOfUMengConfig:(NSString *)name;   //UMeng在线参数值

//组装UMeng在线参数名称
- (NSString *)UMengParamName:(NSString *)name
                 withChannel:(NSString *)channel
                  andVersion:(NSString *)version;

@end
