//
//  CommonUtils.h
//  YSCKit
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  本地缓存(对象的序列化与反序列化)
 */
#define SaveObject(obj,key)                         [YSCCommonUtils SaveObject:obj forKey:key fileName:nil subFolder:nil]
#define SaveObjectByFile(obj,key,file)              [YSCCommonUtils SaveObject:obj forKey:key fileName:file subFolder:nil]
#define SaveCacheObject(obj,key)                    [YSCCommonUtils SaveCacheObject:obj forKey:key fileName:nil subFolder:nil]
#define SaveCacheObjectByFile(obj,key,file)         [YSCCommonUtils SaveCacheObject:obj forKey:key fileName:file subFolder:nil]

#define GetObject(key)                              [YSCCommonUtils GetObjectForKey:key fileName:nil subFolder:nil]
#define GetObjectByFile(key,file)                   [YSCCommonUtils GetObjectForKey:key fileName:file subFolder:nil]
#define GetCacheObject(key)                         [YSCCommonUtils GetCacheObjectForKey:key fileName:nil subFolder:nil]
#define GetCacheObjectByFile(key,file)              [YSCCommonUtils GetCacheObjectForKey:key fileName:file subFolder:nil]

@class NewVersionModel;
/**
 *  全局通用静态类
 *  作用：主要是公用可以独立执行的方法集合
 */
@interface YSCCommonUtils : NSObject

+ (void)checkNewVersionShowMessage:(BOOL)showMessage;
+ (void)checkNewVersionShowMessage:(BOOL)showMessage withParams:(NSDictionary *)params andType:(NSInteger)type;
+ (void)checkNewVersion:(NewVersionModel *)versionModel showMessage:(BOOL)showMessage;
+ (void)checkNewVersionByAppleId:(NSString *)appleId;

+ (void)configNavigationBar;

+ (void)configUmeng;
+ (void)configUmengPushWithOptions:(NSDictionary *)launchOptions;
+ (void)registerForRemoteNotification;

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
//规范化floatValue：如果有小数点才显示两位，否则就不显示小数点
+ (NSString *)formatFloatValue:(CGFloat)value;
+ (NSString *)formatNumberValue:(NSNumber *)value;
//规范化mac地址
+ (NSString *)formatMacAddress:(NSString *)macAddress;

#pragma mark - 打电话
+ (void)MakeCall:(NSString *)phoneNumber;
+ (void)MakeCall:(NSString *)phoneNumber success:(void (^)(void))block;

#pragma mark - 打开APP的设置并进入隐私界面
+ (void)OpenPrivacyOfSetting;

#pragma mark - 更新Sqlite操作
+ (BOOL)SqliteUpdate:(NSString *)sql;
+ (BOOL)SqliteUpdate:(NSString *)sql dbPath:(NSString *)dbPath;
+ (BOOL)SqliteCheckIfExists:(NSString *)sql;
+ (BOOL)SqliteCheckIfExists:(NSString *)sql dbPath:(NSString *)dbPath;
+ (int)SqliteGetRows:(NSString *)sql;
+ (int)SqliteGetRows:(NSString *)sql dbPath:(NSString *)dbPath;


#pragma mark - 过去了多长时间 + 还剩多少时间
+ (NSString *)TimePassed:(NSString *)timeStamp;
+ (NSString *)TimeRemain:(NSString *)timeStamp;
+ (NSString *)TimeRemain:(NSString *)timeStamp currentTime:(NSString *)currentTime;

#pragma mark - NSURL获取参数
+ (NSDictionary *)GetParamsInNSURL:(NSURL *)url;
+ (NSDictionary *)GetParamsInQueryString:(NSString *)queryString;

#pragma mark - UIButton添加pop动画
+ (void)addPopAnimationToButton:(UIButton *)button;

#pragma mark - 加密解密
+ (NSString *)AESEncryptString:(NSString *)string byKey:(NSString *)key;
+ (NSString *)AESDecryptString:(NSString *)string byKey:(NSString *)key;

#pragma mark - 获取wifi的mac地址
+ (id)FetchSSIDInfo;
+ (NSString *)CurrentWifiBSSID;

#pragma mark - 缓存数据
+ (BOOL)SaveObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
+ (BOOL)SaveCacheObject:(NSObject *)object forKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;

+ (id)GetObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;
+ (id)GetCacheObjectForKey:(NSString *)key fileName:(NSString *)fileName subFolder:(NSString *)subFoler;

@end
