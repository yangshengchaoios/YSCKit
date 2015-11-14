//
//  EZGChatRoomViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/7/14.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "EZGChatRoomViewController.h"
#import "CDConversationStore.h"

@interface EZGChatRoomViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
    [AppConfigManager sharedInstance].currentViewController = self;
    APPDATA.chatUser = [[ChatUserModel alloc] initWithString:self.conv.attributes[OtherUserInfo] error:nil];
    self.title = Trim(APPDATA.chatUser.realName);
    if (NO == IsAppTypeC) {//B端才需要更新用户信息
        [self refreshUserInfo];
    }
    
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

#pragma mark - 刷新对方用户信息
//刷新聊天对方用户的个人信息(主要是解决头像和昵称不同步的问题)
- (void)refreshUserInfo {
    WEAKSELF
    [ChatUserModel GetByMethod:kResPathGetUserInfo
                        params:@{kParamUserId : Trim(APPDATA.chatUser.userId)}
                         block:^(NSObject *object, NSError *error) {
                             ChatUserModel *chatUser = (ChatUserModel *)object;
                             if (isEmpty(error) && [chatUser isKindOfClass:[ChatUserModel class]] &&
                                 isNotEmpty(chatUser.avatarUrl) && isNotEmpty(chatUser.realName)) {
                                 //判断是否需要保存用户信息
                                 if (![chatUser.phoneNumber isEqualToString:APPDATA.chatUser.phoneNumber] ||
                                     ![chatUser.avatarUrl isEqualToString:APPDATA.chatUser.avatarUrl] ||
                                     ![chatUser.realName isEqualToString:APPDATA.chatUser.realName]) {
                                     APPDATA.chatUser = chatUser;
                                     weakSelf.title = Trim(chatUser.realName);
                                     [weakSelf updateUserInfo:[chatUser toJSONString]];//保存修改信息
                                     [weakSelf.messageTableView reloadData];//刷新本页列表
                                 }
                             }
                         }];
}
//更新会话对象里的用户信息 FIXME:应该本地缓存用户信息而不是去更新会话对象！
- (void)updateUserInfo:(NSString *)userInfo {
    WEAKSELF
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [tempDict addEntriesFromDictionary:self.conv.attributes];
    tempDict[OtherUserInfo] = Trim(userInfo);
    //更新会话属性,内存对象已经更新！数据库里之所以更新了是因为父类清空了未读数
    AVIMConversationUpdateBuilder *updateBuilder = [self.conv newUpdateBuilder];
    updateBuilder.attributes = tempDict;
    [self.conv update:[updateBuilder dictionary] callback:^(BOOL succeeded, NSError *error) {
        if (isEmpty(error)) {
            [[CDConversationStore store] updateConversation:weakSelf.conv];
            if (weakSelf.params[kParamBlock]) {//已经是最新的会话了，直接刷新cell，更新头像和昵称
                YSCResultBlock block = weakSelf.params[kParamBlock];
                block(nil);
            }
        }
        else {
            [[CDConversationStore store] updateConversation:weakSelf.conv];
        }
    }];
}

#pragma mark - XHShareMenuViewDelegate
//点击扩展区域的功能按钮
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    if (0 == index) {//照片
        [self didClickedShareMenuItemSendPhoto];
    }
    else if (1 == index) {//拍摄
        if ([UIDevice isCanUseCamera]) { //打开摄像头，获取的图片要保存到自定义相册EZGoal
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else {
            [UIView showAlertVieWithMessage:@"请在设置->隐私->相机,打开本应用的权限"];
        }
    }
    else if (2 == index) {//位置
        [self didClickedShareMenuItemSendLocation];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if ( ! pickedImage) {
            pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        //处理获得的图片对象
        if (pickedImage) {
            [weakSelf didSendMessageWithPhoto:[weakSelf resizeImage:pickedImage]];
            [[ALAssetsLibrary new] saveImage:pickedImage toAlbum:@"EZGoal" completion:nil failure:nil];
        }
        else {
            [UIView showResultThenHideOnWindow:@"未选择图片"];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)resizeImage:(UIImage *)image {
    CGFloat width = SCREEN_WIDTH_SCALE;
    CGFloat height = width * (image.size.height / image.size.width);
    return [YSCImageUtils resizeImage:image toSize:CGSizeMake(width, height)];
}

@end
