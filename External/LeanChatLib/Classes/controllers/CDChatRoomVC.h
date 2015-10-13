//
//  CDChatRoomController.h
//  LeanChat
//
//  Created by Qihe Bian on 7/28/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import "CDChatManager.h"

@interface CDChatRoomVC : XHMessageTableViewController

@property (nonatomic, strong, readonly) AVIMConversation *conv;
@property (nonatomic, strong, readonly) NSMutableArray *msgs;

- (instancetype)initWithConv:(AVIMConversation *)conv;

@end
