//
//  AVIMConversation+CustomAttributes.h
//  LeanChatLib
//
//  Created by lzw on 15/4/8.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import <AVOSCloudIM/AVOSCloudIM.h>

#define CONV_TYPE @"type"

typedef enum : NSUInteger {
    CDConvTypeSingle = 0,
    CDConvTypeGroup,
} CDConvType;

@interface AVIMConversation (Custom)
/**
 *  最后一条消息。通过 SDK 的消息缓存找到的
 */
@property (nonatomic, strong) AVIMTypedMessage *lastMessage;

/**
 *  未读消息数，保存在了数据库。收消息的时候，更新数据库
 */
@property (nonatomic, assign) NSInteger unreadCount;

/**
 *  是否有人提到了你，配合 @ 功能。不能看最后一条消息。
 *  因为可能倒数第二条消息提到了你，所以维护一个标记。
 */
@property (nonatomic, assign) BOOL mentioned;

/**
 *  对话的类型，因为可能是两个人的群聊。所以不能通过成员数量来判断
 *
 *  @return 单聊或群聊
 */
- (CDConvType)type;

/**
 *  单聊对话的对方的 clientId
 */
- (NSString *)otherId;

/**
 *  对话显示的名称。单聊显示对方名字，群聊显示对话的 name
 */
- (NSString *)displayName;

/**
 *  对话的标题。如 兴趣群(30)
 */
- (NSString *)title;


/**
 *  对话的图标，通过 conversationId 生成五彩图像
 */
- (UIImage *)icon;

/**
 *  组合多个用户的名字。如 小王、老李
 *
 *  @param userIds 用户的 userId 集合
 *
 *  @return 拼成的名字
 */
+ (NSString *)nameOfUserIds:(NSArray *)userIds;

@end
