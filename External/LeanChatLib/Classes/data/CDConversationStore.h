//
//  CDDatabaseManager.h
//  LeanChatLib
//
//  Created by lzw on 15/7/13.
//  Copyright (c) 2015年 lzwjava@LeanCloud QQ: 651142978. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
/**
 *  最近对话的存储类。最近对话将保存在本地数据库中
 */
@interface CDConversationStore : NSObject

/**
 *  单例
 *  @return
 */
+ (CDConversationStore *)store;

/**
 *  会在 openClient 时调用
 *  @param path 跟自己的clientId相关的数据库路径
 */
- (void)setupStoreWithDatabasePath:(NSString *)path;

/**
 *  插入一条最近对话
 *  @param conversation
 */
- (void )insertConversation:(AVIMConversation *)conversation;

/**
 *  清空未读数
 *  @param conversation 相应的对话
 */
- (void)updateUnreadCountToZeroWithConversation:(AVIMConversation *)conversation;

/**
 *  增加未读数
 *  @param conversation 相应对话
 */
- (void)increaseUnreadCountWithConversation:(AVIMConversation *)conversation;

/**
 *  更新 mentioned 值，当接收到消息发现 @了我的时候，设为 YES，进入聊天页面，设为 NO
 *  @param mentioned  要更新的值
 *  @param conversation 相应对话
 */
- (void)updateMentioned:(BOOL)mentioned conversation:(AVIMConversation *)conversation;

/**
 *  更新每条最近对话记录里的 conversation 值，也即某对话的名字、成员可能变了，需要更新应用打开时，第一次加载最近对话列表时，会去向服务器要对话的最新数据，然后更新
 *  @param conversations 要更新的对话
 */
- (void)updateConversations:(NSArray *)conversations;

/**
 *  最近对话列表左滑删除本地数据库的对话，将不显示在列表
 *  @param conversation
 */
- (void)deleteConversation:(AVIMConversation *)conversation;

/**
 *  从数据库查找所有的对话，即所有的最近对话
 *  @return 对话数据
 */
- (NSArray *)selectAllConversations;

/**
 *  判断某对话是否存在于本地数据库。接收到消息的时候用，sdk 传过来的对话的members 等数据可能是空的，如果本地数据库存在该对话，则不去服务器请求对话了。如果不存在，则向服务器请求对话的元数据。使得在最近对话列表，取出对话的时候，对话都有元数据。
 *  @param conversation 某对话
 *  @return
 */
- (BOOL)isConversationExists:(AVIMConversation *)conversation;

@end
