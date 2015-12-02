//
//  CDChatRoomController.m
//  LeanChat
//
//  Created by Qihe Bian on 7/28/14.
//  Copyright (c) 2014 LeanCloud. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import "CDChatRoomVC.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHAudioPlayerHelper.h"

#import "LZStatusView.h"
#import "CDEmotionUtils.h"
#import "AVIMConversation+Custom.h"
#import "CDSoundManager.h"
#import "CDConversationStore.h"
#import "CDFailedMessageStore.h"
#import "AVIMEmotionMessage.h"
#import "MJRefresh.h"

static NSInteger const kOnePageSize = 10;

@interface CDChatRoomVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ZYQAssetPickerControllerDelegate>
@property (nonatomic, strong, readwrite) AVIMConversation *conv;
@property (atomic, assign) BOOL isLoadingMsg;
@property (atomic, assign) NSInteger currentSelectedIndex;
@property (nonatomic, strong) NSArray *emotionManagers;
@property (nonatomic, strong) LZStatusView *clientStatusView;
@property (nonatomic, assign) int64_t lastSentTimestamp;
@end

@implementation CDChatRoomVC

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        // 配置输入框UI的样式
        //self.allowsSendVoice = NO;
        //self.allowsSendFace = NO;
        //self.allowsSendMultiMedia = NO;
        self.isLoadingMsg = NO;
    }
    return self;
}
- (instancetype)initWithConv:(AVIMConversation *)conv {
    self = [self init];
    self.conv = conv;
    return self;
}
//重置conv
- (void)resetConversation {
    self.conv = [[CDConversationStore store] selectOneConversationByConvId:self.conv.conversationId];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAppeared = NO;
    [AppConfigManager sharedInstance].currentViewController = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageDelivered:) name:kCDNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusView) name:kCDNotificationConnectivityUpdated object:nil];
    
    NSString *received_convid = [NSString stringWithFormat:@"received_%@", Trim(self.conv.conversationId)];
    self.lastSentTimestamp = [GetCacheObject(received_convid) longLongValue];
    [self initBottomMenu];
    [self initEmotionView];
    [self.view addSubview:self.clientStatusView];
    [self loadMessagesWhenInit];
    [self updateStatusView];
    [[XHAudioPlayerHelper shareInstance] setDelegate:self];
    
    //配置下拉刷新
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadOldMessages];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.messageTableView.header = header;
    self.currentSelectedIndex = -1;
    
    //重新设置返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:DefaultNaviBarArrowBackImage
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeCurrentViewController)];
    //用户信息
    APPDATA.chatUser = [ChatUserModel GetLocalDataByUserId:self.conv.otherId];//重置当前聊天对象
    if (nil == APPDATA.chatUser) {
        self.title = @"聊天";
    }
    else {
        [self updateUserInfo:APPDATA.chatUser];
    }
    [self refreshUserInfo];
}
//更新用户头像和昵称等信息
- (void)refreshUserInfo {
    WEAKSELF
    [ChatUserModel RefreshByUserIds:@[Trim(self.conv.otherId)] ezgoalType:self.conv.ezgoalType block:^(NSObject *object, NSString *errorMessage) {
        NSArray *array = (NSArray *)object;
        if (isNotEmpty(object) && [array isKindOfClass:[NSArray class]]) {
            ChatUserModel *chatUser = array[0];
            if (nil == APPDATA.chatUser ||
                NO == [chatUser.phoneNumber isEqualToString:APPDATA.chatUser.phoneNumber] ||
                NO == [chatUser.avatarUrl isEqualToString:APPDATA.chatUser.avatarUrl] ||
                NO == [chatUser.userName isEqualToString:APPDATA.chatUser.userName]) {
                APPDATA.chatUser = [ChatUserModel GetLocalDataByUserId:weakSelf.conv.otherId];//从缓存数据库中查询
                [weakSelf updateUserInfo:APPDATA.chatUser];//刷新本页对方相关信息
                [weakSelf.messageTableView reloadData];//刷新本页列表
                YSCResultBlock block = weakSelf.params[kParamBlock];
                if (block) {
                    block(nil);//刷新cell，更新用户昵称和头像
                }
            }
        }
    }];
}
//更新用户信息
- (void)updateUserInfo:(ChatUserModel *)chatUser {
    self.title = Trim(chatUser.userName);//会话对方的昵称
}
- (void)closeCurrentViewController {
    [self closeCurrentViewControllerAnimated:YES block:nil];
}
//关闭当前会话页面
- (void)closeCurrentViewControllerAnimated:(BOOL)animated block:(YSCBlock)block {
    if (self.messageInputView.isRecording) {
        return ;//正在录音中
    }
    if (self.navigationController) {            //如果有navigationBar
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        if (index > 0) {                        //不是root，就返回上一级
            [self.navigationController popViewControllerAnimated:animated];
            if (block) {
                block();
            }
        }
        else {
            [self.presentingViewController dismissViewControllerAnimated:animated completion:^{
                if (block) {
                    block();
                }
            }];
        }
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:animated completion:^{
            if (block) {
                block();
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [CDChatManager manager].chattingConversationId = self.conv.conversationId;
}
- (void)viewDidDisappear:(BOOL)animated {
    self.isAppeared = NO;
    [CDChatManager manager].chattingConversationId = nil;
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    //如果有未读消息，且通过推送栏进入本页面后，继续有新消息到达，退出的时候就需要清空conv的未读消息，
    //因为处于当前页面时不会发送kCDNotificationUnreadsUpdated通知！
    [self updateConversationAsRead];
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isAppeared = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    YSCResultBlock block = self.params[kParamBlock];
    if (block) {
        block(nil);//刷新cell，更新最后一条聊天记录
    }
    [super viewWillDisappear:animated];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationConnectivityUpdated object:nil];
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

#pragma mark - ui init
//初始化扩展区域
- (void)initBottomMenu {
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuView.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
}
//初始化表情管理器
- (void)initEmotionView {
    _emotionManagers = [CDEmotionUtils emotionManagers];
    self.emotionManagerView.isShowEmotionStoreButton = YES;
    [self.emotionManagerView reloadData];
}

#pragma mark - connect status view
- (LZStatusView *)clientStatusView {
    if (_clientStatusView == nil) {
        _clientStatusView = [[LZStatusView alloc] initWithFrame:CGRectMake(0, 64, self.messageTableView.frame.size.width, kLZStatusViewHight)];
        _clientStatusView.hidden = YES;
    }
    return _clientStatusView;
}
- (void)updateStatusView {
    self.clientStatusView.hidden = ([AVIMClient defaultClient].status != AVIMClientStatusClosed);
}

#pragma mark -  ui config
// 是否显示时间轴Label的回调方法
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0 && indexPath.row < [self.messages count]) {
        AVIMTypedMessage *msg = [self.messages objectAtIndex:indexPath.row];
        AVIMTypedMessage *lastMsg = [self.messages objectAtIndex:indexPath.row - 1];
        return msg.sendTimestamp - lastMsg.sendTimestamp > 60 * 3 * 1000;
    }
    else {
        return YES;
    }
}
// 是否支持用户手动滚动
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

#pragma mark - alert and async utils
- (BOOL)filterError:(NSError *)error {
    return [self alertError:error] == NO;
}
- (void)alert:(NSString *)msg {
    [self alert:msg block:nil];
}
- (void)alert:(NSString *)msg block:(void (^)(void))block{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:msg];
    [alertView bk_setCancelButtonWithTitle:@"确定" handler:block];
    [alertView show];
}
- (BOOL)alertError:(NSError *)error {
    if (error) {
        if (error.code == 4303) {
            [[CDConversationStore store] deleteConversationByConvId:self.conv.conversationId];//删除本地不存在的会话
            self.conv = nil;
            WEAKSELF
            [self alert:@"会话不存在" block:^{
                [weakSelf bk_performBlock:^(id obj) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } afterDelay:0.5];
            }];
        }
        else if (kAVIMErrorConnectionLost == error.code) {
            [UIView showResultThenHideOnWindow:@"未能连接聊天服务器"];
            postN(kNotificationConnectToChatServer);
        }
        else if (kAVIMErrorConversationNotFound == error.code) {
            [UIView showResultThenHideOnWindow:@"会话不存在！"];
        }
        else if (kAVIMErrorConnectionLost == error.code) {
            [UIView showResultThenHideOnWindow:@"会话连接断开"];
        }
        else if (kAVIMErrorMessageTooLong == error.code) {
            [UIView showResultThenHideOnWindow:@"消息太长"];
        }
        else if ([error.domain isEqualToString:NSURLErrorDomain]) {
            [UIView showResultThenHideOnWindow:@"网络连接错误"];
        }
        else {
            [self alert:[NSString stringWithFormat:@"alertError: %@", error]];
        }
        return YES;
    }
    return NO;
}
- (void)runInMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}
- (void)runInGlobalQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

#pragma mark - conversations store
- (void)updateConversationAsRead {
    if (self.conv) {
        [[CDConversationStore store] updateConversation:self.conv];//如果已经存在就不会继续插入，保证有消息就有会话！
        [[CDConversationStore store] updateUnreadCountToZeroByConvId:self.conv.conversationId];
        [[CDConversationStore store] updateMentioned:NO convId:self.conv.conversationId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationUnreadsUpdated object:nil];
}

#pragma mark - EZGMessageTableViewCell action
//设置cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EZGMessageBaseCell *cell = (EZGMessageBaseCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    AVIMTypedMessage *message = self.messages[indexPath.row];
    WEAKSELF
    [cell.bubbleImageView removeAllGestureRecognizers];
    
    //1. 单击头像
    [cell.avatarImageView removeAllGestureRecognizers];
    [cell.avatarImageView bk_whenTapped:^{
        [weakSelf didSelectedAvatorOnMessage:message atIndexPath:indexPath];
    }];
    
    //2. 单击重发消息
    [cell.statusView.retryButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    [cell.statusView.retryButton bk_addEventHandler:^(id sender) {
        [weakSelf didRetrySendMessage:message atIndexPath:indexPath];
    } forControlEvents:UIControlEventTouchUpInside];
    
    //3. 双击文本消息
    if (kAVIMMessageMediaTypeText == message.mediaType) {
        [cell.bubbleImageView bk_whenDoubleTapped:^{
            [weakSelf didDoubleSelectedOnTextMessage:message atIndexPath:indexPath];
        }];
    }
    
    //4. 单击消息体
    [cell.bubbleImageView bk_whenTapped:^{
        //关闭menu
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.isMenuVisible) {
            [menu setMenuVisible:NO animated:YES];
        }
        //点击媒体消息
        [weakSelf multiMediaMessageDidSelectedOnMessage:message atIndexPath:indexPath onMessageTableViewCell:cell];
    }];
    //5. 添加长按手势
    [cell addLongPressGesture];
    
    //6. 设置音频cell
    if (kAVIMMessageMediaTypeAudio == message.mediaType) {
        EZGMessageVoiceCell *voiceCell = (EZGMessageVoiceCell *)cell;
        if (self.currentSelectedIndex == indexPath.row) {
            [voiceCell.animationVoiceImageView startAnimating];
        }
        else {
            [voiceCell.animationVoiceImageView stopAnimating];
        }
    }
    return cell;
}
//单击消息体
- (void)multiMediaMessageDidSelectedOnMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(EZGMessageBaseCell *)messageTableViewCell {
    //1. 正在录音过程中不能跳转页面
    if (self.messageInputView.isRecording) {
        return;
    }
    //2. 单击消息体跳转页面
    if (kAVIMMessageMediaTypeAudio == message.mediaType) {//播放声音
        if (self.currentSelectedIndex >= 0) {//停止cell动画
            EZGMessageVoiceCell *voiceCell = [self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0]];
            [voiceCell.animationVoiceImageView stopAnimating];
        }
        
        if (indexPath.row == self.currentSelectedIndex) {
            [[XHAudioPlayerHelper shareInstance] stopAudio];//停止播放
            self.currentSelectedIndex = -1;
        }
        else {//开始cell动画
            self.currentSelectedIndex = indexPath.row;
            [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.file.localPath toPlay:YES];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if (kAVIMMessageMediaTypeImage == message.mediaType) {//打开图片浏览器
        //关闭音频播放
        if (kAVIMMessageMediaTypeImage == message.mediaType) {
            [[XHAudioPlayerHelper shareInstance] stopAudio];
            EZGMessageVoiceCell *voiceCell = [self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0]];
            [voiceCell.animationVoiceImageView stopAnimating];
            self.currentSelectedIndex = -1;
        }
        //打开图片浏览器
        YSCBaseViewController *photoDetail = (YSCBaseViewController *)[UIResponder createBaseViewController:@"YSCPhotoBrowseViewController"];
        
        //NOTE:遍历当前消息数组里所有的图片
        NSMutableArray *photoArray = [NSMutableArray array];
        NSInteger photoIndex = 0;
        for (AVIMTypedMessage *msg in self.messages) {
            if (kAVIMMessageMediaTypeImage == msg.mediaType) {
                YSCPhotoBrowseCellModel *model = [YSCPhotoBrowseCellModel new];
                if (msg.file.isDataAvailable) {
                    NSData *imageData = [msg.file getData];
                    if (imageData) {
                        model.image = [UIImage imageWithData:imageData];
                    }
                    else {
                        model.imageUrl = Trim(msg.file.url);
                    }
                }
                else if (isNotEmpty(msg.file.localPath)) {
                    model.imageUrl = Trim(msg.file.localPath);
                }
                else if (isNotEmpty(msg.file.url)) {
                    model.imageUrl = Trim(msg.file.url);
                }
                
                [photoArray addObject:model];
                if ([message.messageId isEqualToString:msg.messageId]) {
                    photoIndex = [photoArray count] - 1;
                }
            }
        }
        photoDetail.params = @{kParamImageModels : photoArray, kParamIndex : @(photoIndex)};
        [self.navigationController pushViewController:photoDetail animated:NO];
    }
    else if (kAVIMMessageMediaTypeLocation == message.mediaType) {//查看位置
        YSCBaseViewController *mapViewController = (YSCBaseViewController *)[UIResponder createBaseViewController:@"YSCLocationDisplayViewController"];
        AVIMLocationMessage *locMessage = (AVIMLocationMessage *)message;
        mapViewController.params = @{kParamBackType : @(BackTypeImage),
                                     kParamLatitude : @(locMessage.latitude),
                                     kParamLongitude : @(locMessage.longitude)};
        [self.navigationController pushViewController:mapViewController animated:YES];
    }
    else if (kAVIMMessageMediaTypeVideo == message.mediaType) {
        //TODO:播放视频
    }
}
//双击文本消息
- (void)didDoubleSelectedOnTextMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}
//单击头像
- (void)didSelectedAvatorOnMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"indexPath : %@", indexPath);
}
//重发消息
- (void)didRetrySendMessage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    [self resendMessage:message atIndexPath:indexPath discardIfFailed:false];
}




//================================================
//
//  扩展功能
//
//================================================
#pragma mark - XHShareMenuViewDelegate
//点击扩展区域的功能按钮
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    if ([@"照片" isEqualToString:shareMenuItem.title]) {
        [self didClickedShareMenuItemSendPhoto];
    }
    else if ([@"拍摄" isEqualToString:shareMenuItem.title]) {
        [self didClickedShareMenuItemCamera];
    }
    else if ([@"位置" isEqualToString:shareMenuItem.title]) {
        [self didClickedShareMenuItemSendLocation];
    }
}
#pragma mark - select share menu item
//点击扩展功能按钮-发送位置
- (void)didClickedShareMenuItemSendLocation {
    WEAKSELF
    YSCResultBlock block = ^(NSObject *object) {//发送位置信息
        if (object) {
            SearchPoiModel *dataModel = (SearchPoiModel *)object;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:dataModel.poiLocation.latitude longitude:dataModel.poiLocation.longitude];
            NSString *locationAddress = isEmpty(dataModel.poiAddress) ? Trim(dataModel.poiName) : Trim(dataModel.poiAddress);
            [weakSelf didSendGeolocationsMessageWithGeolocaltions:locationAddress location:location level:dataModel.level];
        }
        else {
            [UIView showResultThenHideOnWindow:@"没有选择位置信息"];
        }
    };
    YSCBaseViewController *viewController = (YSCBaseViewController *)[UIResponder createBaseViewController:@"EZGAddressSearchViewController"];
    viewController.params = @{kParamBackType : @(BackTypeImage), kParamBlock : block};
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]
                       animated:YES completion:nil];
}
//点击扩展功能按钮-发送拍摄照片
- (void)didClickedShareMenuItemCamera {
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
//点击扩展功能按钮-发送图片
- (void)didClickedShareMenuItemSendPhoto {
    if ([UIDevice isPhotoLibraryAvailable]) {
        ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
        picker.delegate = self;
        picker.maximumNumberOfSelection = 9;//最大同时选择的照片数量
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.showEmptyGroups = NO;
        picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                return duration >= 5;
            }
            else {
                return YES;
            }
        }];
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else {
        [UIView showAlertVieWithMessage:@"请在设置->隐私->照片,打开本应用的权限"];
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
            [[ALAssetsLibrary new] saveImage:pickedImage toAlbum:@"翼畅行" completion:nil failure:nil];
            [weakSelf didSendMessageWithPhoto:[YSCImageUtils resizeImage:pickedImage]];
        }
        else {
            [UIView showResultThenHideOnWindow:@"未选择图片"];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - ZYQAssetPickerControllerDelegate
- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    for (int i = 0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        UIImage *pickedImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImage *sendImage = [YSCImageUtils resizeImage:pickedImage];
        [self didSendMessageWithPhoto:sendImage];
    }
}
- (void)assetPickerControllerDidCancel:(ZYQAssetPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}



//================================================
//
//  toolBar相关delegate
//
//================================================
#pragma mark - XHAudioPlayerHelper Delegate
- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (self.currentSelectedIndex < 0) {
        return;
    }
    //停止cell动画
    EZGMessageVoiceCell *voiceCell = [self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0]];
    [voiceCell.animationVoiceImageView stopAnimating];
    self.currentSelectedIndex = -1;
}

#pragma mark - XHMessageInputView Delegate
//开始录音
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    if (self.currentSelectedIndex >= 0) {//停止cell动画
        EZGMessageVoiceCell *voiceCell = [self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedIndex inSection:0]];
        [voiceCell.animationVoiceImageView stopAnimating];
        self.currentSelectedIndex = -1;
    }
    [super prepareRecordingVoiceActionWithCompletion:completion];
}

#pragma mark - XHEmotionManagerView DataSource
- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}
- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}
- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}



//================================================
//
// 消息收发
//
//================================================
#pragma mark - Message Send
//根据文本开始发送文本消息
- (void)didSendMessageWithText:(NSString *)text {
    if (isEmpty(text)) {
        [UIView showResultThenHideOnWindow:@"消息内容不能为空"];
        return;
    }
    AVIMTextMessage *msg = [AVIMTextMessage messageWithText:[CDEmotionUtils plainStringFromEmojiString:text] attributes:nil];
    [self sendMsg:msg];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}
//根据图片开始发送图片消息
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.6);
    AVFile *imageFile = [AVFile fileWithData:imageData];
    AVIMImageMessage *msg = [AVIMImageMessage messageWithText:nil file:imageFile attributes:nil];
    [self sendMsg:msg];
}
//根据录音路径开始发送语音消息
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    AVIMAudioMessage *msg = [AVIMAudioMessage messageWithText:nil attachedFilePath:voicePath attributes:nil];
    [self sendMsg:msg];
}
//根据地理位置信息和地理经纬度开始发送地理位置消息
- (void)didSendGeolocationsMessageWithGeolocaltions:(NSString *)geolocations location:(CLLocation *)location level:(NSInteger)level {
    if (0 == level) {
        level = 15;
    }
    AVIMLocationMessage *locMsg = [AVIMLocationMessage messageWithText:geolocations
                                                              latitude:location.coordinate.latitude
                                                             longitude:location.coordinate.longitude
                                                            attributes:@{MParamMapLevel : @(level)}];
    [self sendMsg:locMsg];
    
}
//发送表情
- (void)didSendEmotionMessageWithEmotion:(NSString *)emotion {
    if ([emotion hasPrefix:@":"]) {
        // 普通表情
        UITextView *textView = self.messageInputView.inputTextView;
        NSRange range = [textView selectedRange];
        NSMutableString *str = [[NSMutableString alloc] initWithString:textView.text];
        [str deleteCharactersInRange:range];
        [str insertString:emotion atIndex:range.location];
        textView.text = [CDEmotionUtils emojiStringFromString:str];
        textView.selectedRange = NSMakeRange(range.location + emotion.length, 0);
    } else {
        AVIMEmotionMessage *msg = [AVIMEmotionMessage messageWithEmotionPath:emotion];
        [self sendMsg:msg];
    }
}

#pragma mark - send message
- (void)sendMsg:(AVIMTypedMessage *)msg {
    msg.status = AVIMMessageStatusSending;

    //>>>>>设置临时消息必要的属性，先在cell中显示出来>>>>>>>>>>>
    msg.messageId = [[CDChatManager manager] tempMessageId];
    msg.sendTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    msg.clientId = [CDChatManager manager].selfId;
    msg.conversationId = self.conv.conversationId;
    [self insertMessage:msg];
    NSInteger msgIndex = [self.messages indexOfObject:msg];//先缓存该消息在列表中的位置
    [[CDConversationStore store] updateLastMessage:msg byConvId:self.conv.conversationId];//更新最后一条消息对象
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    WEAKSELF
    [[CDChatManager manager] sendMessage:msg conversation:self.conv callback:^(BOOL succeeded, NSError *error) {
        if ([weakSelf alertError:error]) {
            [[CDFailedMessageStore store] insertFailedMessage:msg];
            msg.status = AVIMMessageStatusFailed;
        }
        else {
            msg.status = AVIMMessageStatusSent;
        }
        [[CDSoundManager manager] playSendSoundIfNeed];
        //NOTE:刷新当前message所在的cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgIndex inSection:0];
        [weakSelf.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
- (void)replaceMesssage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    self.messages[indexPath.row] = message;
    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)resendMessage:(AVIMTypedMessage *)msg atIndexPath:(NSIndexPath *)indexPath discardIfFailed:(BOOL)discardIfFailed {
    msg.status = AVIMMessageStatusSending;
    [self replaceMesssage:msg atIndexPath:indexPath];
    NSString *recordId = msg.messageId;//NOTE:先缓存该临时消息的id，因为重发成功后messageId是要改变的
    WEAKSELF
    [[CDChatManager manager] sendMessage:msg conversation:self.conv callback:^(BOOL succeeded, NSError *error) {
        if ([weakSelf alertError:error]) {
            if (discardIfFailed) {//判断是否需要删除重发失败的消息
                [[CDFailedMessageStore store] deleteFailedMessageByRecordId:recordId];
            }
            msg.status = AVIMMessageStatusFailed;
        }
        else {//重发成功后删除失败消息
            [[CDFailedMessageStore store] deleteFailedMessageByRecordId:recordId];
            msg.status = AVIMMessageStatusSent;
        }
        //刷新message所在的cell
        [weakSelf replaceMesssage:msg atIndexPath:indexPath];
    }];
}

#pragma mark - receive and delivered
- (void)receiveMessage:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ([message.conversationId isEqualToString:self.conv.conversationId]) {
        //关闭'未读'提示标记>>>>>>>>>>>>>>>>>>>>>>>>>
        for (int pos = 0; pos < self.messages.count; pos++) {
            AVIMTypedMessage *msg = self.messages[pos];
            if (AVIMMessageIOTypeOut == msg.ioType &&
                AVIMMessageStatusDelivered != msg.status) {
                msg.status = AVIMMessageStatusDelivered;
                [self.messages setObject:msg atIndexedSubscript:pos];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pos inSection:0];
                [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        if (self.conv.muted == NO) {
            [[CDSoundManager manager] playReceiveSoundIfNeed];
        }
        [self insertMessage:message];
    }
}
- (void)onMessageDelivered:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ([message.conversationId isEqualToString:self.conv.conversationId]) {
        AVIMTypedMessage *foundMessage;
        NSInteger pos;
        for (pos = 0; pos < self.messages.count; pos++) {
            AVIMTypedMessage *msg = self.messages[pos];
            if ([msg.messageId isEqualToString:message.messageId]) {
                foundMessage = msg;
                break;
            }
        }
        if (foundMessage !=nil) {
            foundMessage.status = AVIMMessageStatusDelivered;
            [self.messages setObject:foundMessage atIndexedSubscript:pos];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pos inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomAnimated:YES];
        }
    }
}

#pragma mark - query messages
- (void)queryAndCacheMessagesWithTimestamp:(int64_t)timestamp block:(AVIMArrayResultBlock)block {
    [[CDChatManager manager] queryTypedMessagesWithConversation:self.conv timestamp:timestamp limit:kOnePageSize block:^(NSArray *msgs, NSError *error) {
        if (error) {
            block(msgs, error);
        }
        else {
            [self cacheMsgs:msgs callback:^(BOOL succeeded, NSError *error) {
                block(msgs, error);
            }];
        }
    }];
}
- (void)loadMessagesWhenInit {
    if (self.isLoadingMsg) {
        return;
    }
    self.isLoadingMsg = YES;
    
    [self queryAndCacheMessagesWithTimestamp:0 block:^(NSArray *msgs, NSError *error) {
        if ([self filterError:error]) {
            // 失败消息加到末尾，因为 SDK 缓存不保存它们
            NSArray *failedMessages = [[CDFailedMessageStore store] selectFailedMessagesByConversationId:self.conv.conversationId];
            NSMutableArray *allMessages = [NSMutableArray arrayWithArray:msgs];
            [allMessages addObjectsFromArray:failedMessages];
            
            self.messages = allMessages;
            [self.messageTableView reloadData];
            [self scrollToBottomAnimated:NO];
            if ([msgs count] > 0) {
                [self updateConversationAsRead];
            }
            
            // 如果连接上，则重发所有的失败消息。若夹杂在历史消息中间不好处理
            if ([CDChatManager manager].connect) {
                for (NSInteger i = msgs.count; i < allMessages.count; i++) {
                    [self resendMessage:allMessages[i] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0] discardIfFailed:YES];
                }
            }
        }
        self.isLoadingMsg = NO;
    }];
}
- (void)loadOldMessages {
    if (self.messages.count == 0 || self.isLoadingMsg) {
        [self.messageTableView.header endRefreshing];
        return;
    }
    self.isLoadingMsg = YES;
    AVIMTypedMessage *msg = self.messages[0];
    int64_t timestamp = msg.sendTimestamp;
    WEAKSELF
    [self queryAndCacheMessagesWithTimestamp:timestamp block:^(NSArray *msgs, NSError *error) {
        if ([weakSelf filterError:error] && isNotEmpty(msgs)) {
            NSMutableArray *newMsgs = [NSMutableArray arrayWithArray:msgs];
            [newMsgs addObjectsFromArray:weakSelf.messages];
            if ([msgs count] > 0) {
                [weakSelf insertOldMessages:msgs completion: ^{
                    weakSelf.isLoadingMsg = NO;
                    [weakSelf.messageTableView.header endRefreshing];
                }];
            }
            else {
                weakSelf.isLoadingMsg = NO;
                [weakSelf.messageTableView.header endRefreshing];
            }
        }
        else {
            weakSelf.isLoadingMsg = NO;
            [weakSelf.messageTableView.header endRefreshing];
        }
    }];
}
//缓存消息内容文件，不是消息本身！
- (void)cacheMsgs:(NSArray *)msgs callback:(AVBooleanResultBlock)callback {
    if (isEmpty(msgs)) {
        callback(YES, nil);
    }
    for (AVIMTypedMessage *msg in msgs) {
        //设置消息是已读的>>>>>>>>>>>>>>>>>>>
        if (msg.sendTimestamp <= self.lastSentTimestamp &&
            AVIMMessageIOTypeOut == msg.ioType &&
            AVIMMessageStatusDelivered != msg.status) {
            msg.status = AVIMMessageStatusDelivered;
        }
        //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    }
    callback(YES, nil);
}
- (void)insertMessage:(AVIMTypedMessage *)message {
    WEAKSELF
    [self cacheMsgs:@[message] callback:^(BOOL succeeded, NSError *error) {
        if ([weakSelf filterError:error]) {
            [weakSelf.messageTableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messages.count inSection:0];
            [weakSelf.messages addObject:message];
            [weakSelf.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.messageTableView endUpdates];
            [weakSelf scrollToBottomAnimated:YES];
        }
        weakSelf.isLoadingMsg = NO;
    }];
}

@end
