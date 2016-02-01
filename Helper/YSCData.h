//
//  YSCData.h
//  YSCKit
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//


/**
 *  单例类
 *  作用：存储整个项目运行过程中用到的变量
 *       常用的单例变量管理
 */

#define YSCInstance             [YSCData SharedInstance]

//--------------------------------------
//  定义全局变量
//--------------------------------------
@interface YSCData : NSObject
@property (nonatomic, weak) UIViewController *currentViewController;
@property (nonatomic, strong) NSString *cacheDBPath;        //缓存数据库路径
//network status
@property (nonatomic, assign) BOOL isReachable;             //是否处于联网状态
@property (nonatomic, assign) BOOL isReachableViaWiFi;      //是否通过wifi联网

//app config
@property (nonatomic, strong) NSString *udid;               //设备唯一编号(UMeng)
@property (nonatomic, strong) NSString *deviceToken;        //推送通知的token
@property (nonatomic, assign) BOOL isOnlineParamsChanged;   //在线参数是否改动了
//current date
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;//服务器当前时间戳(秒)从1970-01-01 00:00:00开始

+ (instancetype)SharedInstance;

#pragma mark - 获取服务器当前时间
- (void)refreshServerTimeWithBlock:(YSCResultBlock)block;   //如果具体项目的网络请求不同就重新该方法

#pragma mark - 获取配置参数(本地参数+在线参数)
- (void)resetAppParams;                                     //重置参数键值对(当有在线参数更新时调用)
- (NSString *)valueOfAppConfig:(NSString *)name;            //在线参数值优先级 > 本地参数值

#pragma mark - 播放音频
- (void)playAudioWithFilePath:(NSString *)filePath;
- (void)playAudioWithFilePath:(NSString *)filePath repeatCount:(NSInteger)count;
@end
