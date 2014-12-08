//
//  AppConfigManager.h
//  KQ
//
//  Created by  YangShengchao on 14-6-9.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>

@interface AppConfigManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - AppConfig.plist管理

- (NSString *)valueInAppConfig:(NSString *)key;

@end
