//
//  YSCData.m
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//

#import "YSCData.h"

//--------------------------------------
//  常用业务变量
//--------------------------------------
@implementation YSCData
+ (instancetype)SharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}




@end


//--------------------------------------
//  获取配置参数(本地参数+在线参数)
//--------------------------------------
@implementation YSCData (AppConfig)



@end


//--------------------------------------
//  网络状态监测
//--------------------------------------
@implementation YSCData (Reachability)



@end


//--------------------------------------
//  播放音频
//--------------------------------------
@implementation YSCData (PlayAudio)



@end