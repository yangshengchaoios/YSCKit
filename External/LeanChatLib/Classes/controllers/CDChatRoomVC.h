//
//  CDChatRoomController.h
//  LeanChat
//
//  Created by Qihe Bian on 7/28/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "XHDisplayLocationViewController.h"
#import "CDChatManager.h"

/**
 *  聊天页面
 */
@interface CDChatRoomVC : XHMessageTableViewController

@property (nonatomic, strong, readonly) AVIMConversation *conv;
@property (nonatomic, strong, readonly) NSMutableArray *msgs;
@property (nonatomic, strong) NSDictionary *params;

- (instancetype)initWithConv:(AVIMConversation *)conv;

#pragma mark - EZGMessageTableViewCell action
- (void)multiMediaMessageDidSelectedOnMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(EZGMessageBaseCell *)messageTableViewCell;
- (void)didDoubleSelectedOnTextMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectedAvatorOnMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath;
- (void)didRetrySendMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - select share menu item
//点击扩展功能按钮-发送位置
- (void)didClickedShareMenuItemSendLocation;
//点击扩展功能按钮-发送图片
- (void)didClickedShareMenuItemSendPhoto;
//发送消息
- (void)sendMsg:(AVIMTypedMessage *)msg;
@end
