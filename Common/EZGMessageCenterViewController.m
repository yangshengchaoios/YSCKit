//
//  EZGMessageCenterViewController.m
//  B_EZGoal
//
//  Created by yangshengchao on 15/9/6.
//  Copyright (c) 2015年 YingChuangKeXun. All rights reserved.
//

#import "EZGMessageCenterViewController.h"

@interface EZGMessageCenterViewController ()

@end

@implementation EZGMessageCenterViewController

- (void)dealloc {
    NSLog(@"%@ deallocing...", NSStringFromClass(self.class));
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息中心";
    [self initTableView];
    addNObserver(@selector(refreshTableView), kNotificationRefreshMessageCenter);//消息到达后被APPDATA拦截处理后再确定是否需要刷新这个列表
    addNObserver(@selector(refreshTableView), kCDNotificationUnreadsUpdated);//未读数变化重新查询会话列表
}
- (void)initTableView {
    WEAKSELF
    if (ISLOGGED) {
        self.tableView.tipsEmptyText = @"亲，暂无您的消息哟！";
    }
    else {
        self.tableView.tipsEmptyText = @"亲，请登录后查看您的消息！";
    }
    self.tableView.cellName = @"EZGMessageCenterCell";
    self.tableView.tipsView.actionButton.hidden = YES;
    self.tableView.enableLoadMore = NO;
    self.tableView.enableCellEdit = YES;
    //自定义数据源获取方式
    self.tableView.requestType = RequestTypeCustomResponse;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (ISLOGGED) {
            if ([weakSelf.tableView.cellDataArray count] == 0) {
                [weakSelf refreshConversationsFromInternet];
            }
            else {
                [weakSelf refreshConversationsByPageIndex:kDefaultPageStartIndex];
            }
        }
        else {
            [weakSelf.tableView refreshAtPageIndex:kDefaultPageStartIndex response:nil error:nil];
        }
    }];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSInteger pageIndex = weakSelf.tableView.currentPageIndex + 1;
        if (ISLOGGED) {
            [weakSelf refreshConversationsByPageIndex:pageIndex];
        }
        else {
            [weakSelf.tableView refreshAtPageIndex:pageIndex response:nil error:nil];
        }
    }];
    self.tableView.successBlock = ^(){ weakSelf.isClicked = NO; };
    self.tableView.failedBlock = ^(){ weakSelf.isClicked = NO; };
    //点击cell的回调
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        CheckWeakSelfIsClicked
        YSCResultBlock refreshCellBlock = ^(NSObject *object) {
            if ([weakSelf.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        };
        AVIMConversation *conversation = (AVIMConversation *)object;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        NSDictionary *params = @{kParamConversationId   : Trim(conversation.conversationId),
                                 kParamChatRoom         : @{kParamBlock : refreshCellBlock}};
        postNWithInfo(kNotificationOpenChatRoom, params);
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object) {
        //启动最后一条聊天记录刷新线程
        EZGMessageCenterCell *cell = (EZGMessageCenterCell *)view;
        AVIMConversation *conversation = (AVIMConversation *)object;
        if (isNotEmpty(conversation) && nil == conversation.lastMessage) {
            [conversation queryMessagesWithLimit:1 callback:^(NSArray *objects, NSError *error) {
                if (isNotEmpty(objects)) {
                    [[CDConversationStore store] updateLastMessage:objects[0] byConvId:conversation.conversationId];
                    [cell layoutConversationByConvId:conversation.conversationId];
                }
            }];
        }
    };
    self.tableView.deleteCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"确定要删除该会话？"];
        [alertView bk_addButtonWithTitle:@"删除" handler:^{
            AVIMConversation *conv = (AVIMConversation *)object;
            [[CDConversationStore store] deleteConversationByConvId:conv.conversationId];
            NSMutableArray *tempArray = weakSelf.tableView.cellDataArray[indexPath.section];
            [tempArray removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView show];
    };
}

//刷新会话（被通知激活）
- (void)refreshTableView {
    if (ISLOGGED) {
        [self refreshConversationsByPageIndex:kDefaultPageStartIndex];
    }
}
//刷新最近的对话（分页机制）
- (void)refreshConversationsByPageIndex:(NSInteger)pageIndex {
    NSArray *array = [[CDConversationStore store] selectConversationsByPageIndex:pageIndex pageSize:100];
    [self.tableView refreshAtPageIndex:pageIndex response:array error:nil];
}
//从IM服务器刷新会话列表
- (void)refreshConversationsFromInternet {
    WEAKSELF
    [EZGDATA refreshConversationsByPageIndex:kDefaultPageStartIndex pageSize:20 block:^(NSArray *objects, NSError *error) {
        [weakSelf refreshConversationsByPageIndex:kDefaultPageStartIndex];
    }];
}
@end
