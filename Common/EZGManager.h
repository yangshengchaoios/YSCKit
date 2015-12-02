//
//  EZGManager.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/2.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  【翼畅行】C端和B端共享代码——静态方法
 */
@interface EZGManager : NSObject

#pragma mark - 格式化公共数据
//格式化图片url
+ (NSString *)FormatImageUrl:(NSString *)imageUrl width:(CGFloat)width;
//格式化评分
+ (float)FormatStaffScore:(NSNumber *)score;
//判断救援状态是否还在处理中
+ (BOOL)checkRescueStatusIsProcessing:(RescueStatusType)rescueStatus;
//判断救援状态是否结束
+ (BOOL)checkRescueStatusIsOver:(RescueStatusType)rescueStatus;

#pragma mark - 车牌号相关
//今日限号
+ (NSArray *)TodayLimitedNumbers;
//检测车牌今天是否限号
+ (BOOL)CheckIfLimitedByCarNumber:(NSString *)carNumber;
//计算出车牌号的下标数组
+ (NSArray *)carNumberIndexes:(NSString *)carNumber;
//车牌号最后一位数字，-1表示没数字
+ (NSInteger)lastNumberOfCarNumber:(NSString *)carNumber;
//格式化车牌号
+ (NSString *)formatCarNumber:(NSString *)carNumber;

#pragma mark - 格式化救援耗时
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate;
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate endDate:(NSDate *)endDate;
//计算时间过了多少
+ (NSString *)timePassedByStartDate:(NSDate *)startDate;
+ (NSString *)timePassedByStartDate:(NSDate *)startDate flag:(BOOL)flag;

//获取推送证书名称
+ (NSString *)deviceProfile;
//检测是否用测试证书打包
+ (BOOL)isDevelopmentApp;

@end
