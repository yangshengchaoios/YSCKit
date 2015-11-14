//
//  EZGMessageModel.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/6.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "AVIMTypedMessage.h"

//自定义消息类型
typedef NS_ENUM(NSInteger, EZGMessageType) {
    EZGMessageTypeScene             = 1,
    EZGMessageTypeCar               = 2,
    EZGMessageTypeService           = 3,
    EZGMessageTypeServiceCancel     = 4,        //请求取消服务
    EZGMessageTypeServiceComment    = 5,        //完成对服务的评价
};

#pragma mark - 消息扩展参数值宏定义
//现场照片消息类型
typedef NS_ENUM(NSInteger, EZGSceneType) {
    EZGSceneTypeSingleCar           = 1,
    EZGSceneTypeMultiCar            = 2,
};
//服务消息类型
typedef NS_ENUM(NSInteger, EZGServiceType) {
    EZGServiceTypeStart             = 1,    //服务开始
    EZGServiceTypeFinish            = 2,    //服务完成(等待评价)
    EZGServiceTypeOver              = 3,    //服务结束(有结束标志！)
    EZGServiceTypeResume            = 4,    //取消放弃操作
};

//消息扩展参数名定义
#define MParamSceneType                 @"sceneType"        //现场照片类型
#define MParamCarInfo                   @"carInfo"          //爱车模型
#define MParamDetailInfo                @"detailInfo"       //详细信息
#define MParamServiceType               @"serviceType"      //服务类型
#define MParamRateScore                 @"rateScore"        //评分数
#define MParamAccidentId                @"accidentId"       //现场记录id

#define MParamAvatarUrl                 @"avatarUrl"        //消息对应的头像地址



#pragma mark - 自定义消息模型
//现场记录的消息(包括单车和多车)
@interface EZGSceneMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
//@property (nonatomic, assign) EZGSceneType sceneType;
@end


//爱车信息消息
@interface EZGCarMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
//@property (nonatomic, strong) NSString *carInfo;
@end


//包括
//1.服务开始消息(成功发送位置信息后由B端自动发出)
//2.服务结束：正常结束后需要用户评价、取消服务的结束就直接关闭沟通功能
//3.服务过程中的特殊消息(如取消放弃救援...)
@interface EZGServiceMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
//@property (nonatomic, strong) NSString *detailInfo;
//@property (nonatomic, assign) EZGServiceType serviceType;
@end


//服务申请取消消息(C端申请取消)
@interface EZGServiceCancelMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
//@property (nonatomic, strong) NSString *detailInfo;
@end


//评论消息(由C端发出)
@interface EZGServiceCommentMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
//@property (nonatomic, assign) NSInteger rateScore;//评分数 1-5
@end
