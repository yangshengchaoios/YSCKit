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
#import "CDMessageHelper.h"

@interface EZGMessageCenterViewController ()
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *staffNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *badgeBkgView;//专门用来放badgeView的
@property (strong, nonatomic) JSBadgeView *badgeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;//170  0
@property (nonatomic, strong) NSString *isUserChangedIdentifier;
@property (strong, nonatomic) NSString *isRescueChangedIdentifier;
@end

@implementation EZGMessageCenterViewController

- (void)dealloc {
    if (self.isUserChangedIdentifier) {
        [APPDATA bk_removeObserversWithIdentifier:self.isUserChangedIdentifier];
    }
    if (self.isRescueChangedIdentifier) {
        [APPDATA bk_removeObserversWithIdentifier:self.isRescueChangedIdentifier];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息中心";
    self.headerView.backgroundColor = [UIColor clearColor];
    self.badgeBkgView.backgroundColor = [UIColor clearColor];
    [self layoutRescueConversation:nil];//初始化隐藏救援会话
    [self initTableView];
    WEAKSELF
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
    self.isRescueChangedIdentifier = [APPDATA bk_addObserverForKeyPath:@"isRescueModelChanged" task:^(id target) {
        [weakSelf refreshTableView];
    }];
    addNObserver(@selector(refreshTableView), kNotificationRefreshMessageCenter);//消息到达后被APPDATA拦截处理后再确定是否需要刷新这个列表
    addNObserver(@selector(refreshTableView), kCDNotificationUnreadsUpdated);//未读数变化重新查询会话列表
}
//显示救援特殊会话
- (void)layoutRescueConversation:(AVIMConversation *)conversation {
    [self.headerView removeAllGestureRecognizers];
    if (conversation) {
        self.headerView.hidden = NO;
        self.tableViewTop.constant = AUTOLAYOUT_LENGTH(170);
        if (nil == self.badgeView) {
            self.badgeView = [[JSBadgeView alloc] initWithParentView:self.badgeBkgView alignment:JSBadgeViewAlignmentCenterRight];
        }
        //显示救援人员信息
        ChatUserModel *userModel = [[ChatUserModel alloc] initWithString:conversation.attributes[OtherUserInfo] error:nil];
        self.staffNameLabel.text = [NSString stringWithFormat:@"救援负责人：%@", Trim(userModel.realName)];
        self.badgeView.badgeText = [NSString stringWithFormat:@"%ld", (long)conversation.unreadCount];
        self.badgeView.hidden = (conversation.unreadCount == 0);
        if (conversation.lastMessage) {
            self.lastMessageLabel.attributedText = [[CDMessageHelper helper] attributedStringWithMessage:conversation.lastMessage conversation:conversation];
            self.timePassedLabel.text = [NSDate TimePassedByStartDate:[NSDate dateWithTimeIntervalSince1970:conversation.lastMessage.sendTimestamp / 1000]];
        }
        else {
            self.badgeView.hidden = YES;
            self.lastMessageLabel.text = self.timePassedLabel.text = nil;
        }
        //点击进入救援会话
        [self.headerView bk_whenTapped:^{
            NSDictionary *params = @{kParamOtherId          : Trim(userModel.userId),
                                     kParamConversationId   : Trim(conversation.conversationId)};
            postNWithInfo(kNotificationOpenChatRoom, params);
        }];
    }
    else {
        self.headerView.hidden = YES;
        self.tableViewTop.constant = 0;
    }
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
                [EZGDATA refreshConversationsFromNetworkByUserId:USERID pageIndex:kDefaultPageStartIndex pageSize:20 block:^(NSArray *objects, NSError *error) {
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
    self.tableView.preProcessBlock = ^NSArray *(NSArray *array) {
        NSMutableArray *retArray = [NSMutableArray array];
        AVIMConversation *tempConv = nil;
        for (AVIMConversation *conv in array) {
            if ([EzgoalTypeRescue isEqualToString:conv.attributes[kParamEzgoalType]]) {
                RescueStatusType rescueStatus = [conv.attributes[kParamEzgoalStatus] integerValue];
                if (RescueStatusTypeConfirm != rescueStatus && RescueStatusTypeGiveUpByB != rescueStatus && RescueStatusTypeCancelByB != rescueStatus) {
                    tempConv = conv;
                }
            }
            else {
                [retArray addObject:conv];
            }
        }
        [weakSelf layoutRescueConversation:tempConv];
        return retArray;
    };
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
        ChatUserModel *otherUser = [[ChatUserModel alloc] initWithString:conversation.attributes[OtherUserInfo] error:nil];
        
        NSDictionary *params = @{kParamOtherId          : Trim(otherUser.userId),
                                 kParamConversationId   : Trim(conversation.conversationId),
                                 kParamChatRoom         : @{kParamBlock : refreshCellBlock}};
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
