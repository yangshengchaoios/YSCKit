//
//  EZGMessageCenterViewController.h
//  B_EZGoal
//
//  Created by yangshengchao on 15/9/6.
//  Copyright (c) 2015年 YingChuangKeXun. All rights reserved.
//

#import "YSCBaseViewController.h"
#import "AVIMConversation+Custom.h"
#import "CDConversationStore.h"
#import "EZGMessageCenterCell.h"
#import "CDChatManager.h"

@interface EZGMessageCenterViewController : YSCBaseViewController

@property (nonatomic, weak) IBOutlet YSCTableView *tableView;

//初始化列表
- (void)initTableView;
//刷新列表
- (void)refreshTableView;
//刷新最近的对话
- (void)refreshConversationsByPageIndex:(NSInteger)pageIndex;
//从IM服务器刷新会话列表
- (void)refreshConversationsFromInternet;

@end
