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

+ (instancetype)sharedInstance;

#pragma mark - AppConfig.plist管理

- (NSString *)valueOfAppConfig:(NSString *)key;     //UMeng参数值优先级 > 本地参数值
- (NSString *)valueOfLocalConfig:(NSString *)key;   //本地配置文件参数值
- (NSString *)valueOfUMengConfig:(NSString *)key;   //UMeng在线参数值

@end
