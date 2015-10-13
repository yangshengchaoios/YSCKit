//
//  CDChatListController.m
//  LeanChat
//
//  Created by Qihe Bian on 7/25/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import "CDChatListVC.h"
#import "LZStatusView.h"
#import "UIView+XHRemoteImage.h"
#import "CDChatManager.h"
#import "AVIMConversation+Custom.h"
#import "UIView+XHRemoteImage.h"
#import "CDEmotionUtils.h"
#import "CDMessageHelper.h"
#import "DateTools.h"
#import "CDConversationStore.h"
#import "CDChatManager_Internal.h"
#import "CDMacros.h"

@interface CDChatListVC ()

@property (nonatomic, strong) LZStatusView *clientStatusView;

@property (nonatomic, strong) NSMutableArray *conversations;

@property (atomic, assign) BOOL isRefreshing;

@end

static NSMutableArray *cacheConvs;

@implementation CDChatListVC

static NSString *cellIdentifier = @"ContactCell";

- (instancetype)init {
    if ((self = [super init])) {
        _conversations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [LZConversationCell registerCellToTableView:self.tableView];
    self.refreshControl = [self getRefreshControl];
    // 当在其它 Tab 的时候，收到消息 badge 增加，所以需要一直监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kCDNotificationUnreadsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusView) name:kCDNotificationConnectivityUpdated object:nil];
    [self updateStatusView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 刷新 unread badge 和新增的对话
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationConnectivityUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationUnreadsUpdated object:nil];
}

#pragma mark - client status view

- (LZStatusView *)clientStatusView {
    if (_clientStatusView == nil) {
        _clientStatusView = [[LZStatusView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kLZStatusViewHight)];
    }
    return _clientStatusView;
}

- (void)updateStatusView {
    if ([CDChatManager manager].connect) {
        self.tableView.tableHeaderView = nil ;
    }else {
        self.tableView.tableHeaderView = self.clientStatusView;
    }
}

- (UIRefreshControl *)getRefreshControl {
    UIRefreshControl *refreshConrol = [[UIRefreshControl alloc] init];
    [refreshConrol addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    return refreshConrol;
}

#pragma mark - refresh

- (void)refresh {
    [self refresh:nil];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    if (self.isRefreshing) {
        return;
    }
    self.isRefreshing = YES;
    [[CDChatManager manager] findRecentConversationsWithBlock:^(NSArray *conversations, NSInteger totalUnreadCount, NSError *error) {
        dispatch_block_t finishBlock = ^{
            [self stopRefreshControl:refreshControl];
            if ([self filterError:error]) {
                self.conversations = conversations;
                [self.tableView reloadData];
                if ([self.chatListDelegate respondsToSelector:@selector(setBadgeWithTotalUnreadCount:)]) {
                    [self.chatListDelegate setBadgeWithTotalUnreadCount:totalUnreadCount];
                }
                [self selectConversationIfHasRemoteNotificatoinConvid];
            }
            self.isRefreshing = NO;
        };
        
        if ([self.chatListDelegate respondsToSelector:@selector(prepareConversationsWhenLoad:completion:)]) {
            [self.chatListDelegate prepareConversationsWhenLoad:conversations completion:^(BOOL succeeded, NSError *error) {
                if ([self filterError:error]) {
                    finishBlock();
                } else {
                    [self stopRefreshControl:refreshControl];
                    self.isRefreshing = NO;
                }
            }];
        } else {
            finishBlock();
        }
    }];
}

- (void)selectConversationIfHasRemoteNotificatoinConvid {
    if ([CDChatManager manager].remoteNotificationConvid) {
        // 进入之前推送弹框点击的对话
        BOOL found = NO;
        for (AVIMConversation *conversation in self.conversations) {
            if ([conversation.conversationId isEqualToString:[CDChatManager manager].remoteNotificationConvid]) {
                if ([self.chatListDelegate respondsToSelector:@selector(viewController:didSelectConv:)]) {
                    [self.chatListDelegate viewController:self didSelectConv:conversation];
                    found = YES;
                }
            }
        }
        if (!found) {
            DLog(@"not found remoteNofitciaonID");
        }
        [CDChatManager manager].remoteNotificationConvid = nil;
    }
}

#pragma mark - utils

- (void)stopRefreshControl:(UIRefreshControl *)refreshControl {
    if (refreshControl != nil && [[refreshControl class] isSubclassOfClass:[UIRefreshControl class]]) {
        [refreshControl endRefreshing];
    }
}

- (BOOL)filterError:(NSError *)error {
    if (error) {
        [[[UIAlertView alloc]
          initWithTitle:nil message:[NSString stringWithFormat:@"%@", error] delegate:nil
          cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LZConversationCell *cell = [LZConversationCell dequeueOrCreateCellByTableView:tableView];
    AVIMConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    if (conversation.type == CDConvTypeSingle) {
        id <CDUserModel> user = [[CDChatManager manager].userDelegate getUserById:conversation.otherId];
        cell.nameLabel.text = user.username;
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
    else {
        [cell.avatarImageView setImage:conversation.icon];
        cell.nameLabel.text = conversation.displayName;
    }
    if (conversation.lastMessage) {
        cell.messageTextLabel.attributedText = [[CDMessageHelper helper] attributedStringWithMessage:conversation.lastMessage conversation:conversation];
        cell.timestampLabel.text = [[NSDate dateWithTimeIntervalSince1970:conversation.lastMessage.sendTimestamp / 1000] timeAgoSinceNow];
    }
    if (conversation.unreadCount > 0) {
        if (conversation.muted) {
            cell.litteBadgeView.hidden = NO;
        } else {
            cell.badgeView.badgeText = [NSString stringWithFormat:@"%ld", conversation.unreadCount];
        }
    }
    if ([self.chatListDelegate respondsToSelector:@selector(configureCell:atIndexPath:withConversation:)]) {
        [self.chatListDelegate configureCell:cell atIndexPath:indexPath withConversation:conversation];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AVIMConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
        [[CDConversationStore store] deleteConversation:conversation];
        [self refresh];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AVIMConversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    if ([self.chatListDelegate respondsToSelector:@selector(viewController:didSelectConv:)]) {
        [self.chatListDelegate viewController:self didSelectConv:conversation];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LZConversationCell heightOfCell];
}

@end
