//
//  YSCData.h
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//


/**
 *  单例类
 *  作用：存储整个项目运行过程中用到的变量
 *       常用的单例变量管理
 */

#define YSCInstance         [YSCData SharedInstance]


//--------------------------------------
//  常用业务变量
//--------------------------------------
@interface YSCData : NSObject

+ (instancetype)SharedInstance;

- (NSDate *)currentDate;
- (NSTimeInterval)currentTimeInterval;

@end


//--------------------------------------
//  获取配置参数(本地参数+在线参数)
//--------------------------------------
@interface YSCData (AppConfig)



@end


//--------------------------------------
//  网络状态监测
//--------------------------------------
@interface YSCData (Reachability)



@end



//--------------------------------------
//  播放音频
//--------------------------------------
@interface YSCData (PlayAudio)



@end