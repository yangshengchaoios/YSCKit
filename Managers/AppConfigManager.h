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
@property (nonatomic, strong) NSString *udid;                           //设备唯一编号
@property (nonatomic, strong) NSString *deviceToken;                    //推送通知的token
@property (nonatomic, weak) UIViewController *currentViewController;

+ (instancetype)sharedInstance;

#pragma mark - AppConfig.plist管理

- (NSString *)valueOfAppConfig:(NSString *)name;     //UMeng参数值优先级 > 本地参数值
- (NSString *)valueOfLocalConfig:(NSString *)name;   //本地配置文件参数值

@end
