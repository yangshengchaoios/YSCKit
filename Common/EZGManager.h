//
//  EZGManager.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/2.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZGManager : NSObject

//格式化车牌号
+ (NSString *)formatCarNumber:(NSString *)carNumber;
//格式化救援耗时
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate;
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate endDate:(NSDate *)endDate;
//获取推送证书名称
+ (NSString *)deviceProfile;
//检测是否用测试证书打包
+ (BOOL)isDevelopmentApp;

@end
