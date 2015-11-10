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
#import "EZGAddressSearchViewController.h"
#import "YSCPhotoBrowseViewController.h"

static NSInteger const kOnePageSize = 10;

@interface CDChatRoomVC () <UINavigationControllerDelegate, ZYQAssetPickerControllerDelegate>
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
        _isLoadingMsg = NO;
    }
    return self;
}
- (instancetype)initWithConv:(AVIMConversation *)conv {
    self = [self init];
    self.conv = conv;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageDelivered:) name:kCDNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusView) name:kCDNotificationConnectivityUpdated object:nil];
    
    NSString *received_convid = [NSString stringWithFormat:@"received_%@", Trim(self.conv.conversationId)];
    self.lastSentTimestamp = [GetCacheObject(received_convid) longLongValue];
    if (0 == self.lastSentTimestamp) {
        self.lastSentTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    [self initBottomMenu];
    [self initEmotionView];
    [self.view addSubview:self.clientStatusView];
    [self loadMessagesWhenInit];
    [self updateStatusView];
    [[XHAudioPlayerHelper shareInstance] setDelegate:self];
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadOldMessages];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.messageTableView.header = header;
    self.currentSelectedIndex = -1;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [CDChatManager manager].chattingConversationId = self.conv.conversationId;
}
- (void)viewDidDisappear:(BOOL)animated {
    [CDChatManager manager].chattingConversationId = nil;
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    //如果有未读消息，且通过推送栏进入本页面后，继续有新消息到达，退出的时候就需要清空conv的未读消息，
    //因为处于当前页面时不会发送kCDNotificationUnreadsUpdated通知！
    [self updateConversationAsRead];
    [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    if (self.refreshCellBlock) {//刷新cell，更新最后一条聊天记录
        self.refreshCellBlock(nil);
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
    self.shareMenuItems = shareMenuItems;
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

#pragma mark - EZGMessageTableViewCell action
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
        YSCPhotoBrowseViewController *photoDetail = (YSCPhotoBrowseViewController *)[UIResponder createBaseViewController:@"YSCPhotoBrowseViewController"];
        if (isNotEmpty(message.file.localPath)) {
            photoDetail.params = @{kParamImageUrls : @[Trim(message.file.localPath)]};
            [self.navigationController pushViewController:photoDetail animated:NO];
        }
        else if (message.file.isDataAvailable) {
            NSData *imageData = [message.file getData];
            if (imageData) {
                photoDetail.params = @{kParamImages : @[imageData]};
                [self.navigationController pushViewController:photoDetail animated:NO];
            }
            else {
                [UIView showResultThenHideOnWindow:@"图片数据问题"];
            }
        }
        else {
            [UIView showResultThenHideOnWindow:@"图片下载中"];
        }
    }
    else if (kAVIMMessageMediaTypeLocation == message.mediaType) {//查看位置
        //FIXME: 打开百度地图
//        XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
//        displayLocationViewController.message = message;
//        [self.navigationController pushViewController:displayLocationViewController animated:YES];
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
    [self resendMessageAtIndexPath:indexPath discardIfFailed:false];
}
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
    
    //3. 点击消息体
    if (kAVIMMessageMediaTypeText == message.mediaType) {//双击文本消息
        [cell.bubbleImageView bk_whenDoubleTapped:^{
            [weakSelf didDoubleSelectedOnTextMessage:message atIndexPath:indexPath];
        }];
    }
    else {//单击其它类型的消息
        [cell.bubbleImageView bk_whenTapped:^{
            [weakSelf multiMediaMessageDidSelectedOnMessage:message atIndexPath:indexPath onMessageTableViewCell:cell];
        }];
    }
    
    //4. 设置音频cell
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

#pragma mark - select share menu item
//点击扩展功能按钮-发送位置
- (void)didClickedShareMenuItemSendLocation {
    WEAKSELF
    YSCResultBlock block = ^(NSObject *object) {//发送位置信息
        if (object) {
            SearchPoiModel *dataModel = (SearchPoiModel *)object;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:dataModel.poiLocation.latitude longitude:dataModel.poiLocation.longitude];
            NSString *locationAddress = isEmpty(dataModel.poiAddress) ? Trim(dataModel.poiName) : Trim(dataModel.poiAddress);
            [weakSelf didSendGeolocationsMessageWithGeolocaltions:locationAddress location:location];
        }
        else {
            [UIView showResultThenHideOnWindow:@"没有选择位置信息"];
        }
    };
    EZGAddressSearchViewController *viewController = (EZGAddressSearchViewController *)[UIResponder createBaseViewController:@"EZGAddressSearchViewController"];
    viewController.params = @{kParamBackType : @(BackTypeImage), kParamBlock : block};
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]
                       animated:YES completion:nil];
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

#pragma mark - ZYQAssetPickerControllerDelegate
- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    for (int i = 0; i<assets.count; i++) {
        ALAsset *asset = assets[i];
        UIImage *pickedImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImage *sendImage = [self resizeImage:pickedImage];
        [self didSendMessageWithPhoto:sendImage];
    }
}
- (void)assetPickerControllerDidCancel:(ZYQAssetPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)resizeImage:(UIImage *)image {
    CGFloat width = SCREEN_WIDTH_SCALE;
    CGFloat height = width * (image.size.height / image.size.width);
    return [YSCImageUtils resizeImage:image toSize:CGSizeMake(width, height)];
}

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

#pragma mark - didSend delegate
//发送文本
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([text length] > 0) {
        AVIMTextMessage *msg = [AVIMTextMessage messageWithText:[CDEmotionUtils plainStringFromEmojiString:text] attributes:nil];
        [self sendMsg:msg];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    }
}
//发送图片
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self sendImage:photo];
}
//发送视频
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    AVIMVideoMessage* sendVideoMessage = [AVIMVideoMessage messageWithText:nil attachedFilePath:videoPath attributes:nil];
    [self sendMsg:sendVideoMessage];
}
//发送语音
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    AVIMTypedMessage *msg = [AVIMAudioMessage messageWithText:nil attachedFilePath:voicePath attributes:nil];
    [self sendMsg:msg];
}
//发送表情
- (void)didSendEmotion:(NSString *)emotion fromSender:(NSString *)sender onDate:(NSDate *)date {
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
//发送地理位置
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self sendLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude address:geolocations];
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

#pragma mark - @ reference other
- (void)didInputAtSignOnMessageTextView:(XHMessageTextView *)messageInputTextView {
    
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
        else if (error.code == kAVIMErrorConnectionLost) {
            [UIView showResultThenHideOnWindow:@"未能连接聊天服务器"];
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

#pragma mark - send message
- (void)sendImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    NSString *path = [[CDChatManager manager] tmpPath];
    NSError *error;
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error == nil) {
        AVIMImageMessage *msg = [AVIMImageMessage messageWithText:nil attachedFilePath:path attributes:nil];
        [self sendMsg:msg];
    }
    else {
        [self alert:@"write image to file error" block:nil];
    }
}
- (void)sendLocationWithLatitude:(double)latitude longitude:(double)longitude address:(NSString *)address {
    AVIMLocationMessage *locMsg = [AVIMLocationMessage messageWithText:address latitude:latitude longitude:longitude attributes:nil];
    [self sendMsg:locMsg];
}
- (void)sendMsg:(AVIMTypedMessage *)msg {
    [[CDChatManager manager] sendMessage:msg conversation:self.conv callback:^(BOOL succeeded, NSError *error) {
        if ([self alertError:error]) {// 伪造一个 messageId，重发的成功的时候，根据这个伪造的id把数据库中的改过来
            msg.messageId = [[CDChatManager manager] tempMessageId];
            msg.sendTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
            if (msg.conversationId == nil) {
                //文件没有保存上会导致 conversationId 为空
                msg.clientId = [CDChatManager manager].selfId;
                msg.conversationId = self.conv.conversationId;
            }
            [[CDFailedMessageStore store] insertFailedMessage:msg];
            [[CDSoundManager manager] playSendSoundIfNeed];
            [self insertMessage:msg];
        } else {
            [[CDSoundManager manager] playSendSoundIfNeed];
            [self insertMessage:msg];
        }
        [[CDConversationStore store] updateLastMessage:msg byConvId:self.conv.conversationId];
    }];
}
- (void)replaceMesssage:(AVIMTypedMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    self.messages[indexPath.row] = message;
    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)resendMessageAtIndexPath:(NSIndexPath *)indexPath discardIfFailed:(BOOL)discardIfFailed {
    AVIMTypedMessage *msg = self.messages[indexPath.row];
    msg.status = AVIMMessageStatusSending;
    [self replaceMesssage:msg atIndexPath:indexPath];
    NSString *recordId = msg.messageId;
    [[CDChatManager manager] sendMessage:msg conversation:self.conv callback:^(BOOL succeeded, NSError *error) {
        if ([self alertError:error]) {
            if (discardIfFailed) {
                // 服务器连通的情况下重发依然失败，说明消息有问题，如音频文件不存在，删掉这条消息
                [[CDFailedMessageStore store] deleteFailedMessageByRecordId:recordId];
                // 显示失败状态。列表里就让它存在吧，反正也重发不出去
                [self replaceMesssage:msg atIndexPath:indexPath];
            }
            else {
                [self replaceMesssage:msg atIndexPath:indexPath];
            }
        }
        else {
            [[CDFailedMessageStore store] deleteFailedMessageByRecordId:recordId];
            [self replaceMesssage:msg atIndexPath:indexPath];
        }
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
                block (msgs, error);
            }];
        }
    }];
}
- (void)loadMessagesWhenInit {
    if (self.isLoadingMsg) {
        return;
    } else {
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
                    for (NSInteger row = msgs.count;row < allMessages.count; row ++) {
                        [self resendMessageAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] discardIfFailed:YES];
                    }
                }
            }
            self.isLoadingMsg = NO;
        }];
    }
}
- (void)loadOldMessages {
    if (self.messages.count == 0 || self.isLoadingMsg) {
        [self.messageTableView.header endRefreshing];
        return;
    } else {
        WEAKSELF
        self.isLoadingMsg = YES;
        AVIMTypedMessage *msg = self.messages[0];
        int64_t timestamp = msg.sendTimestamp;
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
}
//缓存消息内容文件，不是消息本身！
- (void)cacheMsgs:(NSArray *)msgs callback:(AVBooleanResultBlock)callback {
    if (isEmpty(msgs)) {
        callback(YES, nil);
    }
    [self runInGlobalQueue:^{
        NSMutableSet *userIds = [[NSMutableSet alloc] init];
        for (AVIMTypedMessage *msg in msgs) {
            
            //设置消息是已读的>>>>>>>>>>>>>>>>>>>
            if (msg.sendTimestamp <= self.lastSentTimestamp &&
                AVIMMessageIOTypeOut == msg.ioType &&
                AVIMMessageStatusDelivered != msg.status) {
                msg.status = AVIMMessageStatusDelivered;
            }
            //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            
            [userIds addObject:msg.clientId];
            if (msg.mediaType == kAVIMMessageMediaTypeImage || msg.mediaType == kAVIMMessageMediaTypeAudio) {
                AVFile *file = msg.file;
                if (file && file.isDataAvailable == NO) {
                    NSError *error;
                    // 下载到本地
                    NSData *data = [file getData:&error];
                    if (error || data == nil) {
                        DLog(@"download file error : %@", error);
                    }
                }
            } else if (msg.mediaType == kAVIMMessageMediaTypeVideo) {
                NSString *path = [[CDChatManager manager] videoPathOfMessag:(AVIMVideoMessage *)msg];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    NSError *error;
                    NSData *data = [msg.file getData:&error];
                    if (error) {
                        DLog(@"download file error : %@", error);
                    } else {
                        [data writeToFile:path atomically:YES];
                    }
                }
            }
        }
        [self runInMainQueue:^{
            callback(YES, nil);
        }];
    }];
}
- (void)insertMessage:(AVIMTypedMessage *)message {
    if (self.isLoadingMsg) {
        [self performSelector:@selector(insertMessage:) withObject:message afterDelay:1];
        return;
    }
    self.isLoadingMsg = YES;
    [self cacheMsgs:@[message] callback:^(BOOL succeeded, NSError *error) {
        if ([self filterError:error]) {
            [self.messageTableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
            [self.messages addObject:message];
            [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.messageTableView endUpdates];
            [self scrollToBottomAnimated:YES];
        }
        self.isLoadingMsg = NO;
    }];
}

@end
