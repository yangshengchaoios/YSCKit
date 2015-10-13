//
//  CDChatRoomController.h
//  LeanChat
//
//  Created by Qihe Bian on 7/28/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "CDChatManager.h"

/**
 *  聊天页面
 */
@interface CDChatRoomVC : XHMessageTableViewController

/**
 *  开放给子类，来对当前对话进行额外操作
 */
@property (nonatomic, strong, readonly) AVIMConversation *conv;

/**
 *  当前对话的 AVIMTypedMessage Array，开放给子类来定制
 */
@property (nonatomic, strong, readonly) NSMutableArray *msgs;

/**
 *  初始化方法
 *  @param conv 要聊天的对话
 *  @return
 */
- (instancetype)initWithConv:(AVIMConversation *)conv;

@end
