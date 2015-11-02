//
//  EZGMessageCenterViewController.m
//  B_EZGoal
//
//  Created by yangshengchao on 15/9/6.
//  Copyright (c) 2015年 YingChuangKeXun. All rights reserved.
//

#import "EZGMessageCenterViewController.h"
#import "AVIMConversation+Custom.h"
#import "CDConversationStore.h"
#import "EZGChatRoomViewController.h"
#import "EZGMessageCenterCell.h"

@interface EZGMessageCenterViewController ()
@property (weak, nonatomic) IBOutlet YSCTableView *tableView;
@property (strong, nonatomic) NSString *isS4ModelChangedIdentifier;
@property (nonatomic, strong) NSString *isUserChangedIdentifier;
@end

@implementation EZGMessageCenterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [EZGUtils FunctionStatisticsByOperaCode:@"khgn" type:@"1"];
}
- (void)dealloc {
    if (self.isS4ModelChangedIdentifier) {
        [APPDATA bk_removeObserversWithIdentifier:self.isS4ModelChangedIdentifier];
    }
    if (self.isUserChangedIdentifier) {
        [APPDATA bk_removeObserversWithIdentifier:self.isUserChangedIdentifier];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息中心";
    [self initTableView];
    WEAKSELF
    //监控是否有修改专属4S店
    self.isS4ModelChangedIdentifier = [APPDATA bk_addObserverForKeyPath:@"isS4ModelChanged" task:^(id target) {
        [weakSelf.tableView beginRefreshing];
    }];
    self.isUserChangedIdentifier = [APPDATA bk_addObserverForKeyPath:@"isUserChanged" task:^(id target) {
        if (ISNOTLOGGED) {
            weakSelf.tableView.tipsEmptyText = @"亲，请登录后查看您的消息！";
            [weakSelf.tableView.headerDataArray removeAllObjects];
            [weakSelf.tableView.cellDataArray removeAllObjects];
            [weakSelf.tableView reloadData];
            weakSelf.tableView.tipsView.hidden = NO;
        }
        else {
            weakSelf.tableView.tipsEmptyText = @"亲，暂无您的消息哟！";
            [weakSelf refreshTableView];
        }
    }];
    addNObserver(@selector(refreshTableView), kCDNotificationMessageReceived);//消息到达重新查询会话列表
    addNObserver(@selector(refreshTableView), kCDNotificationUnreadsUpdated);//未读数变化重新查询会话列表
}
- (void)refreshTableView {
    if (ISLOGGED) {
        [self refreshConversationsByPageIndex:kDefaultPageStartIndex];
    }
}
- (void)refreshWhenDataIsEmpty {
    if (ISLOGGED) {
        [self.tableView refreshWhenCellDataEmpty];
    }
}
- (void)initTableView {
    WEAKSELF
    if (ISLOGGED) {
        self.tableView.tipsEmptyText = @"亲，暂无您的消息哟！";
    }
    else {
        self.tableView.tipsEmptyText = @"亲，请登录后查看您的消息！";
    }
    self.tableView.tipsView.actionButton.hidden = YES;
    self.tableView.cellName = @"EZGMessageCenterCell";
    self.tableView.enableLoadMore = NO;
    self.tableView.enableCellEdit = YES;
    //自定义数据源获取方式
    self.tableView.requestType = RequestTypeCustomResponse;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (ISLOGGED) {
            if ([weakSelf.tableView.cellDataArray count] == 0) {
                [APPDATA refreshConversationsFromNetworkByUserId:USERID pageIndex:kDefaultPageStartIndex pageSize:20 block:^(NSArray *objects, NSError *error) {
                    [weakSelf refreshConversationsByPageIndex:kDefaultPageStartIndex];
                }];
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
        ChatUserModel *cUser = [[ChatUserModel alloc] initWithString:conversation.attributes[OtherUserInfo] error:nil];
        NSDictionary *params = @{kParamUserId : Trim(cUser.userId),
                                 kParamUserName : Trim(cUser.realName),
                                 kParamAvatarUrl : Trim(cUser.avatarUrl),
                                 kParamPhoneNumber : Trim(cUser.phoneNumber),
                                 kParamConvId : Trim(conversation.conversationId),
                                 kParamBlock : refreshCellBlock};
        postNWithInfo(kNotificationOpenChatRoom, params);
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object) {
        //启动最后一条聊天记录刷新线程
        EZGMessageCenterCell *cell = (EZGMessageCenterCell *)view;
        AVIMConversation *conversation = (AVIMConversation *)object;
        if (nil == conversation.lastMessage) {
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
    [self.tableView beginRefreshing];
}

//刷新最近的对话(下拉刷新)
- (void)refreshConversationsByPageIndex:(NSInteger)pageIndex {
    NSArray *array = [[CDConversationStore store] selectConversationsByPageIndex:pageIndex pageSize:100];
    [self.tableView refreshAtPageIndex:pageIndex response:array error:nil];
}

@end
