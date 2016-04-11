//
//  YSCConfigData.h
//  KanPian
//
//  Created by 杨胜超 on 16/4/8.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  单例类
 *  作用：管理配置文件里的参数
 */

#define YSCConfigDataInstance             [YSCConfigData sharedInstance]

@interface YSCConfigData : NSObject
+ (instancetype)sharedInstance;

- (void)resetConfigParams;                                  //重置参数键值对(当有在线参数更新时调用)
- (BOOL)boolFromConfigByName:(NSString *)name;
- (float)floatFromConfigByName:(NSString *)name;
- (NSInteger)intFromConfigByName:(NSString *)name;
- (UIColor *)colorFromConfigByName:(NSString *)name;
- (UIImage *)imageFromConfigByName:(NSString *)name;
- (NSString *)stringFromConfigByName:(NSString *)name;      //在线参数值优先级 > 本地参数值
@end
