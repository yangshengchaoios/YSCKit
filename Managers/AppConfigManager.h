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

@property (nonatomic, strong) NSMutableDictionary *appParams;           //优先级最高
@property (nonatomic, strong) NSString *udid;                           //设备唯一编号
@property (nonatomic, strong) NSString *deviceToken;                    //推送通知的token
@property (nonatomic, weak) UIViewController *currentViewController;
@property (nonatomic, assign) BOOL isOnlineParamsChanged;               //在线参数是否改动了

+ (instancetype)sharedInstance;
- (void)resetAppParams;                             //重置参数键值对(当有在线参数更新时调用)
- (NSString *)valueOfAppConfig:(NSString *)name;     //在线参数值优先级 > 本地参数值

@end
