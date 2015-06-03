//
//  CommonUtils.h
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewVersionModel;
/**
 *  全局通用静态类
 *  作用：主要是公用可以独立执行的方法集合
 */
@interface YSCCommonUtils : NSObject

+ (void)checkNewVersionShowMessage:(BOOL)showMessage;
+ (void)checkNewVersionShowMessage:(BOOL)showMessage withParams:(NSDictionary *)params;
+ (void)checkNewVersion:(NewVersionModel *)versionModel showMessage:(BOOL)showMessage;

+ (void)configNavigationBar;

+ (void)configUmeng;
+ (void)configUmengPushWithOptions:(NSDictionary *)launchOptions;
+ (UIView *)createSearchViewWithWidth:(NSInteger)width withTextField:(UITextField *)textField;

#pragma mark - 格式化金额

/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点）
 *
 *  @param price 价格参数
 *
 *  @return
 */
+ (NSString *)formatPrice:(NSNumber *)price;
/**
 *  常用的价格字符串格式化方法（默认：显示￥、显示小数点、显示元）
 *
 *  @param price
 *
 *  @return
 */
+ (NSString *)formatPriceWithUnit:(NSNumber *)price;
/**
 *  格式化价格字符串输出
 *
 *  @param price     价格
 *  @param useTag    是否显示￥
 *  @param isDecimal 是否显示小数点
 *
 *  @return 组装好的字符串
 */
+ (NSString *)formatPrice:(NSNumber *)price showMoneyTag:(BOOL)isTagUsed showDecimalPoint:(BOOL) isDecimal useUnit:(BOOL)isUnitUsed;

#pragma mark - 打电话

+ (void)MakeCall:(NSString *)phoneNumber;

#pragma mark - 更新Sqlite操作

+ (BOOL)SqliteUpdate:(NSString *)sql;
+ (BOOL)SqliteUpdate:(NSString *)sql dbPath:(NSString *)dbPath;
+ (BOOL)SqliteCheckIfExists:(NSString *)sql;
+ (BOOL)SqliteCheckIfExists:(NSString *)sql dbPath:(NSString *)dbPath;


#pragma mark - 过去了多长时间 + 还剩多少时间

+ (NSString *)TimePassed:(NSString *)timeStamp;
+ (NSString *)TimeRemain:(NSString *)timeStamp;
+ (NSString *)TimeRemain:(NSString *)timeStamp currentTime:(NSString *)currentTime;

#pragma mark - NSURL获取参数

+ (NSDictionary *)GetParamsInNSURL:(NSURL *)url;
+ (NSDictionary *)GetParamsInQueryString:(NSString *)queryString;

#pragma mark - UIButton添加pop动画

+ (void)addPopAnimationToButton:(UIButton *)button;

@end
