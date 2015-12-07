//
//  EZGConstants.h
//  B_EZGoal
//
//  Created by yangshengchao on 15/12/2.
//  Copyright © 2015年 YingChuangKeXun. All rights reserved.
//

#ifndef EZGConstants_h
#define EZGConstants_h

//自定义消息cell
#import "EZGMessageBaseCell.h"
#import "EZGMessageTextCell.h"
#import "EZGMessageVoiceCell.h"
#import "EZGMessageImageCell.h"
#import "EZGMessageLocationCell.h"
#import "EZGMessageVideoCell.h"
#import "EZGMessageSceneCell.h"
#import "EZGMessageCarCell.h"
#import "EZGMessageServiceCell.h"
#import "EZGMessageServiceCancelCell.h"
#import "EZGMessageServiceCommentCell.h"

//自定义消息类型
typedef NS_ENUM(NSInteger, EZGMessageType) {
    EZGMessageTypeScene             = 1,
    EZGMessageTypeCar               = 2,
    EZGMessageTypeService           = 3,
    EZGMessageTypeServiceCancel     = 4,        //请求取消服务
    EZGMessageTypeServiceComment    = 5,        //完成对服务的评价
};

//救援任务类型(救援会话类型)
typedef NS_ENUM(NSInteger, RescueStatusType) {
    RescueStatusTypeUnProcess           = 0,//暂未开始/C端放弃取消救援
    RescueStatusTypeProcessing          = 1,//救援中/C端放弃取消救援
    RescueStatusTypeFinished            = 2,//救援完成/未评价
    RescueStatusTypeConfirm             = 3,//C端确认完成/已评价 (over)
    RescueStatusTypeGiveUpByB           = 4,//B端放弃救援(over)
    RescueStatusTypeCancelByC1          = 5,//C端申请取消救援(从救援中改变而来)
    RescueStatusTypeCancelByB           = 6,//B端确认取消救援(over)
    RescueStatusTypeCancelByC0          = 7,//C端申请取消救援(从暂未开始改变而来)
    RescueStatusTypeCancelBySystem      = 8,//系统到时自动取消(over)
};

#pragma mark - 消息扩展参数值宏定义
//现场照片消息类型
typedef NS_ENUM(NSInteger, EZGSceneType) {
    EZGSceneTypeSingleCar           = 1,
    EZGSceneTypeMultiCar            = 2,
};

//ezgoalType参数值定义(用于区分普通聊天会话)
static const NSString *EzgoalTypeRescue         = @"RescueModule";
static const NSString *EzgoalTypeReservation    = @"ReservationModule";
static const NSString *EzgoalTypeCustomer       = @"CustomerModule";
static const NSString *EzgoalTypeNewCar         = @"NewCarModule";
static const NSString *EzgoalTypeUsedCar        = @"UsedCarModule";
static const NSString *EzgoalTypeNews           = @"NewsModule";
static const NSString *EzgoalTypeDataReport     = @"DataReportModule";
static const NSString *EzgoalTypeShop           = @"ShopModule";
static const NSString *EzgoalTypeStaff          = @"StaffModule";
static const NSString *EzgoalTypeContact        = @"ContactModule";
static const NSString *EzgoalTypeNotice         = @"NoticeModule";

static const NSString *EzgoalTypeC2B            = @"C2B";//C端创建与B端的普通会话
static const NSString *EzgoalTypeB2B            = @"B2B";//B端同事之间的会话
static const NSString *EzgoalTypeB2C            = @"B2C";//B端创建与C端的普通会话(暂未启用)
static const NSString *EzgoalTypeC2C            = @"C2C";//C端用户之间的会话(暂未启用)
static const NSString *EzgoalTypeGroup          = @"Group";//群会话(暂未启用)

#define kDefaultConversationPageSize            50       //默认查询会话列表一页的数量

//消息扩展参数名定义
#define MParamSceneType                 @"sceneType"        //现场照片类型
#define MParamCarInfo                   @"carInfo"          //爱车模型
#define MParamDetailInfo                @"detailInfo"       //详细信息
#define MParamCancelType                @"cancelType"       //取消救援类型 0-救援状态从0取消的 1-救援状态从1取消的
#define MParamRateScore                 @"rateScore"        //评分数
#define MParamAccidentId                @"accidentId"       //现场记录id
#define MParamServerTime                @"serverTime"       //发送该消息时服务器的时间（用于：取消救援的时间起点）
#define MParamAvatarUrl                 @"avatarUrl"        //消息对应的头像地址
#define MParamMapLevel                  @"mapLevel"         //地图的放大系数

#endif /* EZGConstants_h */
