//
//  EZGMessageModel.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/6.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "AVIMTypedMessage.h"


//========================================
//
//  自定义消息模型
//
//========================================
//现场记录的消息(包括单车和多车)
@interface EZGSceneMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
@end

//爱车信息消息
@interface EZGCarMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
@end

//包括
//1.服务开始消息(成功发送位置信息后由B端自动发出)
//2.服务结束：正常结束后需要用户评价、取消服务的结束就直接关闭沟通功能
//3.服务过程中的特殊消息(如取消放弃救援...)
@interface EZGServiceMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
@end

//服务申请取消消息(C端申请取消)
@interface EZGServiceCancelMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
@end

//评论消息(由C端发出)
@interface EZGServiceCommentMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>
@end
