//
//  CDChatManager.h
//  LeanChat
//
//  Created by lzw on 15/1/21.
//  Copyright (c) 2015年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDUserModel.h"
#import "AVIMConversation+Custom.h"

static NSString *const kCDNotificationUnreadsUpdated = @"UnreadsUpdated";
static NSString *const kCDNotificationMessageReceived = @"MessageReceived";
static NSString *const kCDNotificationMessageDelivered = @"MessageDelivered";
static NSString *const kCDNotificationConversationUpdated = @"ConversationUpdated";
static NSString *const kCDNotificationConnectivityUpdated = @"ConnectStatus";

typedef void (^CDRecentConversationsCallback)(NSArray *conversations, NSInteger totalUnreadCount,  NSError *error);

@protocol CDUserDelegate <NSObject>

@required

//同步方法，下面的 cacheUserByIds:block 方法是为了 getUserById: 能同步返回用户信息
- (id <CDUserModel> )getUserById:(NSString *)userId;

//对于每条消息，都会调用这个方法来缓存发送者的用户信息，以便 getUserById 直接返回用户信息
// 可全局搜索下面函数来看看作用
- (void)cacheUserByIds:(NSSet *)userIds block:(AVBooleanResultBlock)block;

@end

@interface CDChatManager : NSObject

@property (nonatomic, strong) id <CDUserDelegate> userDelegate;

@property (nonatomic, strong, readonly) NSString *selfId;
@property (nonatomic, assign, readonly) BOOL connect;
@property (nonatomic, strong) NSString *chattingConversationId;

// 是否使用开发证书去推送，默认为 NO。YES 的话每条消息会带上这个参数，云代码利用 Hook 设置证书
// 参考 https://github.com/leancloud/leanchat-cloudcode/blob/master/cloud/mchat.js
@property (nonatomic, assign) BOOL useDevPushCerticate;

+ (instancetype)manager;

- (AVIMClient *)imClient;

- (void)openWithClientId:(NSString *)clientId callback:(AVIMBooleanResultBlock)callback;
- (void)closeWithCallback:(AVBooleanResultBlock)callback;

- (void)fecthConvWithConvid:(NSString *)convid callback:(AVIMConversationResultBlock)callback;
- (void)fetchConvWithOtherId:(NSString *)otherId callback:(AVIMConversationResultBlock)callback;
- (void)fetchConvWithMembers:(NSArray *)members callback:(AVIMConversationResultBlock)callback;
- (void)findGroupedConvsWithBlock:(AVIMArrayResultBlock)block;

- (void)createConvWithMembers:(NSArray *)members type:(CDConvType)type callback:(AVIMConversationResultBlock)callback;
- (void)updateConv:(AVIMConversation *)conv name:(NSString *)name attrs:(NSDictionary *)attrs callback:(AVIMBooleanResultBlock)callback;


- (void)cacheConvsWithIds:(NSMutableSet *)convids callback:(AVBooleanResultBlock)callback;
- (AVIMConversation *)lookupConvById:(NSString *)convid;

- (void)sendMessage:(AVIMTypedMessage*)message conversation:(AVIMConversation *)conversation callback:(AVBooleanResultBlock)block;
- (void)sendWelcomeMessageToOther:(NSString *)other text:(NSString *)text block:(AVBooleanResultBlock)block;

- (void)queryTypedMessagesWithConversation:(AVIMConversation *)conversation timestamp:(int64_t)timestamp limit:(NSInteger)limit block:(AVIMArrayResultBlock)block;

- (void)findRecentConversationsWithBlock:(CDRecentConversationsCallback)block;

- (void)deleteConversation:(AVIMConversation *)conversation;

- (NSString *)getPathByObjectId:(NSString *)objectId;
- (NSString *)tmpPath;
- (NSString *)uuid;

@end
