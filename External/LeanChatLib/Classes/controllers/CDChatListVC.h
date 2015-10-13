//
//  CDChatListController.h
//  LeanChat
//
//  Created by Qihe Bian on 7/25/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "AVIMConversation+Custom.h"

@class CDChatListVC;

@protocol CDChatListVCDelegate <NSObject>

- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount;

- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv;

@end

@interface CDChatListVC : UITableViewController

@property (nonatomic, strong) id <CDChatListVCDelegate> chatListDelegate;

@end
