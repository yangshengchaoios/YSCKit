//
//  EZGChatRoomViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/14.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "EZGChatRoomViewController.h"
#import "CDConversationStore.h"

@interface EZGChatRoomViewController ()

@end

@implementation EZGChatRoomViewController

- (void)dealloc {
    NSLog(@"EZGChatRoomViewController deallocing...");
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    APPDATA.chatUser = [[ChatUserModel alloc] initWithString:self.conv.attributes[OtherUserInfo] error:nil];
    self.title = Trim(APPDATA.chatUser.realName);
    [self updateUserInfo];
    
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_phone_white"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (weakSelf.messageInputView.isRecording) {
            return ;//正在录音中
        }
        [YSCCommonUtils MakeCall:APPDATA.chatUser.phoneNumber success:^{
            [EZGUtils FunctionStatisticsByOperaCode:@"khgn" type:@"3"];
        }];
    }];
}
//更新用户头像和昵称信息
//FIXME:应该做到本地缓存对方头像等信息
- (void)updateUserInfo {
    WEAKSELF
    [APPDATA.chatUser updateUserInfoWithBlock:^(NSObject *object) {
        if (object) {
            ChatUserModel *chatUser = (ChatUserModel *)object;
            APPDATA.chatUser = chatUser;
            weakSelf.title = Trim(chatUser.realName);
            [weakSelf.messageTableView reloadData];//刷新本页列表
            
            //更新conversation
            [EZGDATA updateConversation:weakSelf.conv byParams:@{OtherUserInfo : Trim([chatUser toJSONString])} block:^(NSObject *object) {
                if (nil == object) {
                    YSCResultBlock block = weakSelf.params[kParamBlock];
                    if (block) {
                        block(nil);//刷新cell，更新最后一条聊天记录
                    }
                }
            }];
        }
    }];
}

@end
