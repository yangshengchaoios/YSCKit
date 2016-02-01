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
    WEAKSELF
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_phone_white"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if (weakSelf.messageInputView.isRecording) {
            return ;//正在录音中
        }
        [YSCManager MakeCall:APPDATA.chatUser.phoneNumber success:^{
            [EZGUtils FunctionStatisticsByOperaCode:@"khgn" type:@"3"];
        }];
    }];
}

@end
