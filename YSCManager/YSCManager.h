//
//  YSCManager.h
//  YSCKit
//
//  Created by Builder on 16/6/29.
//  Copyright © 2016年 Builder. All rights reserved.
//

/**
 *  单例类
 *  作用：存储整个项目运行过程中用到的变量
 *       常用的单例变量管理
 */

#define YSCManagerInstance              [YSCManager sharedInstance]
#define kNotifyAppIsReadyForSale        @"kNotifyAppIsReadyForSale"

// 定义网络连接状态
typedef NS_ENUM(NSUInteger, YSCReachabilityStatus) {
    YSCReachabilityStatusNotReachable  = 0,     // 没有连接
    YSCReachabilityStatusViaWWAN,               // 非wifi环境
    YSCReachabilityStatusViaWiFi                // wifi环境联网
};

//--------------------------------------
//  定义全局变量
//--------------------------------------
@interface YSCManager : NSObject

@property (nonatomic, weak) UIViewController *currentViewController;
/** APP是否通过了苹果审核 */
@property (nonatomic, assign) BOOL isAppApproved;
/** 是否处于联网状态 */
@property (nonatomic, assign) BOOL isReachable;
/** 当前网络状态 */
@property (nonatomic, assign) YSCReachabilityStatus reachabilityStatus;
/** 设备唯一编号(UMeng) */
@property (nonatomic, strong) NSString *udid;

+ (instancetype)sharedInstance;

@end
