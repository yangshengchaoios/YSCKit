//
//  CDChatListController.h
//  LeanChat
//
//  Created by Qihe Bian on 7/25/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "AVIMConversation+Custom.h"
#import "LZConversationCell.h"

@class CDChatListVC;

/**
 *  最近对话页面的协议
 */
@protocol CDChatListVCDelegate <NSObject>

@optional

/**
 *  来设置 tabbar 的 badge。
 *  @param totalUnreadCount 未读数总和。没有算免打扰对话的未读数。
 */
- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount;

/**
 *  点击了某对话。此时可跳转到聊天页面
 *  @param viewController 最近对话 controller
 *  @param conv           点击的对话
 */
- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv;

/**
 *  额外配置 Cell。将在 tableView:cellForRowAtIndexPath 最后调用
 *  @param cell
 *  @param indexPath
 *  @param conversation 相应的对话
 */
- (void)configureCell:(LZConversationCell *)cell atIndexPath:(NSIndexPath *)indexPath withConversation:(AVIMConversation *)conversation;

- (void)prepareConversationsWhenLoad:(NSArray *)conversations completion:(AVBooleanResultBlock)completion;

@end

/**
 *  最近对话页面
 */
@interface CDChatListVC : UITableViewController

/**
 *  设置 delegate
 */
@property (nonatomic, strong) id <CDChatListVCDelegate> chatListDelegate;

@end
