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

@interface CDChatRoomVC ()

@property (nonatomic, strong, readwrite) AVIMConversation *conv;
@property (atomic, assign) BOOL isLoadingMsg;
@property (nonatomic, strong, readwrite) NSMutableArray *msgs;
@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
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
        self.msgs = [NSMutableArray array];
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
    [self initBottomMenuAndEmotionView];
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
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCDNotificationConnectivityUpdated object:nil];
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

#pragma mark - ui init
- (void)initBottomMenuAndEmotionView {
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
    
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

#pragma mark - XHMessageTableViewCell delegate
- (void)multiMediaMessageDidSelectedOnMessage:(id <XHMessageModel> )message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            [self.navigationController pushViewController:messageDisplayTextView animated:YES];
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            // Mark the voice as read and hide the red dot.
            //message.isRead = YES;
//            messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            if (self.currentSelectedCell) {
                [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (self.currentSelectedCell == messageTableViewCell) {
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            }
            else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
            
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
            
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            [self.navigationController pushViewController:displayLocationViewController animated:YES];
            break;
        }
        default:
            break;
    }
}
- (void)didDoubleSelectedOnTextMessage:(id <XHMessageModel> )message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}
- (void)didSelectedAvatorOnMessage:(id <XHMessageModel> )message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"indexPath : %@", indexPath);
}
- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
}
- (void)didRetrySendMessage:(id <XHMessageModel> )message atIndexPath:(NSIndexPath *)indexPath {
    [self resendMessageAtIndexPath:indexPath discardIfFailed:false];
}

#pragma mark - XHAudioPlayerHelper Delegate
- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!self.currentSelectedCell) {
        return;
    }
    [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHMessageInputView Delegate
//开始录音
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    if (self.currentSelectedCell) {
        [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
        self.currentSelectedCell = nil;
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
//发送文本消息的回调方法
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([text length] > 0) {
        AVIMTextMessage *msg = [AVIMTextMessage messageWithText:[CDEmotionUtils plainStringFromEmojiString:text] attributes:nil];
        [self sendMsg:msg];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    }
}
//发送图片消息的回调方法
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self sendImage:photo];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}
// 发送视频消息的回调方法
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    AVIMVideoMessage* sendVideoMessage = [AVIMVideoMessage messageWithText:nil attachedFilePath:videoPath attributes:nil];
    [self sendMsg:sendVideoMessage];
}
// 发送语音消息的回调方法
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    AVIMTypedMessage *msg = [AVIMAudioMessage messageWithText:nil attachedFilePath:voicePath attributes:nil];
    [self sendMsg:msg];
}
// 发送表情消息的回调方法
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
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
    } else {
        AVIMEmotionMessage *msg = [AVIMEmotionMessage messageWithEmotionPath:emotion];
        [self sendMsg:msg];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
    }
}
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self sendLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude address:geolocations];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}

#pragma mark -  ui config
// 是否显示时间轴Label的回调方法
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0 && indexPath.row < [self.messages count]) {
        XHMessage *msg = [self.messages objectAtIndex:indexPath.row];
        XHMessage *lastMsg = [self.messages objectAtIndex:indexPath.row - 1];
        int interval = [msg.timestamp timeIntervalSinceDate:lastMsg.timestamp];
        return (interval > 60 * 3);
    }
    else {
        return YES;
    }
}
// 配置Cell的样式或者字体
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.messages count]) {
        XHMessage *msg = [self.messages objectAtIndex:indexPath.row];
        SETextView *textView = cell.messageBubbleView.displayTextView;
        if (msg.bubbleMessageType == XHBubbleMessageTypeSending) {
            [textView setTextColor:[UIColor whiteColor]];
        }
        else {
            [textView setTextColor:[UIColor blackColor]];
        }
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

#pragma mark - LeanCloud 

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
    self.msgs[indexPath.row] = message;
    XHMessage *xhMessage = [self getXHMessageByMsg:message];
    self.messages[indexPath.row] = xhMessage;
    [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)resendMessageAtIndexPath:(NSIndexPath *)indexPath discardIfFailed:(BOOL)discardIfFailed {
    AVIMTypedMessage *msg = self.msgs[indexPath.row];
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
        for (int pos = 0; pos < self.msgs.count; pos++) {
            AVIMTypedMessage *msg = self.msgs[pos];
            if (AVIMMessageIOTypeOut == msg.ioType &&
                AVIMMessageStatusDelivered != msg.status) {
                msg.status = AVIMMessageStatusDelivered;
                XHMessage *xhMsg = [self getXHMessageByMsg:msg];
                [self.messages setObject:xhMsg atIndexedSubscript:pos];
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
        for (pos = 0; pos < self.msgs.count; pos++) {
            AVIMTypedMessage *msg = self.msgs[pos];
            if ([msg.messageId isEqualToString:message.messageId]) {
                foundMessage = msg;
                break;
            }
        }
        if (foundMessage !=nil) {
            foundMessage.status = AVIMMessageStatusDelivered;
            XHMessage *xhMsg = [self getXHMessageByMsg:foundMessage];
            [self.messages setObject:xhMsg atIndexedSubscript:pos];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pos inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomAnimated:YES];
        }
    }
}

#pragma mark - modal convert
- (NSDate *)getTimestampDate:(int64_t)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
}
- (XHMessage *)getXHMessageByMsg:(AVIMTypedMessage *)msg {
    id <CDUserModel> fromUser = [[CDChatManager manager].userDelegate getUserById:msg.clientId];
    XHMessage *xhMessage;
    NSDate *time = [self getTimestampDate:msg.sendTimestamp];
    if (msg.mediaType == kAVIMMessageMediaTypeText) {
        AVIMTextMessage *textMsg = (AVIMTextMessage *)msg;
        xhMessage = [[XHMessage alloc] initWithText:[CDEmotionUtils emojiStringFromString:textMsg.text] sender:fromUser.username timestamp:time];
    }
    else if (msg.mediaType == kAVIMMessageMediaTypeAudio) {
        AVIMAudioMessage *audioMsg = (AVIMAudioMessage *)msg;
        NSString *duration = [NSString stringWithFormat:@"%.0f", audioMsg.duration];
        xhMessage = [[XHMessage alloc] initWithVoicePath:audioMsg.file.localPath voiceUrl:nil voiceDuration:duration sender:fromUser.username timestamp:time];
    }
    else if (msg.mediaType == kAVIMMessageMediaTypeLocation) {
        AVIMLocationMessage *locationMsg = (AVIMLocationMessage *)msg;
        xhMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:locationMsg.text location:[[CLLocation alloc] initWithLatitude:locationMsg.latitude longitude:locationMsg.longitude] sender:fromUser.username timestamp:time];
    }
    else if (msg.mediaType == kAVIMMessageMediaTypeImage) {
        AVIMImageMessage *imageMsg = (AVIMImageMessage *)msg;
        UIImage *image;
        NSError *error;
        NSData *data = [imageMsg.file getData:&error];
        if (error) {
            DLog(@"get Data error: %@", error);
        } else {
            image = [UIImage imageWithData:data];
        }
        xhMessage = [[XHMessage alloc] initWithPhoto:image thumbnailUrl:nil originPhotoUrl:nil sender:fromUser.username timestamp:time];
    }
    else if (msg.mediaType == kAVIMMessageMediaTypeEmotion) {
        AVIMEmotionMessage *emotionMsg = (AVIMEmotionMessage *)msg;
        NSString *path = [[NSBundle mainBundle] pathForResource:emotionMsg.emotionPath ofType:@"gif"];
        xhMessage = [[XHMessage alloc] initWithEmotionPath:path sender:fromUser.username timestamp:time];
    }
    else if (msg.mediaType == kAVIMMessageMediaTypeVideo) {
        AVIMVideoMessage *videoMsg = (AVIMVideoMessage *)msg;
        NSString *path = [[CDChatManager manager] videoPathOfMessag:videoMsg];
        xhMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:path] videoPath:path videoUrl:nil sender:fromUser.username timestamp:time];
    } else {
        xhMessage = [[XHMessage alloc] initWithText:@"未知消息" sender:fromUser.username timestamp:time];
        DLog("unkonwMessage");
    }
    
    xhMessage.avator = nil;
    xhMessage.avatorUrl = [fromUser avatarUrl];
    
    if ([[CDChatManager manager].selfId isEqualToString:msg.clientId]) {
        xhMessage.bubbleMessageType = XHBubbleMessageTypeSending;
    }
    else {
        xhMessage.bubbleMessageType = XHBubbleMessageTypeReceiving;
    }
    NSInteger msgStatuses[4] = { AVIMMessageStatusSending, AVIMMessageStatusSent, AVIMMessageStatusDelivered, AVIMMessageStatusFailed };
    NSInteger xhMessageStatuses[4] = { XHMessageStatusSending, XHMessageStatusSent, XHMessageStatusReceived, XHMessageStatusFailed };
    
    if (self.conv.type == CDConvTypeGroup) {
        if (msg.status == AVIMMessageStatusSent) {
            msg.status = AVIMMessageStatusDelivered;
        }
    }
    if (xhMessage.bubbleMessageType == XHBubbleMessageTypeSending) {
        XHMessageStatus status = XHMessageStatusReceived;
        int i;
        for (i = 0; i < 4; i++) {
            if (msgStatuses[i] == msg.status) {
                status = xhMessageStatuses[i];
                break;
            }
        }
        xhMessage.status = status;
    }
    else {
        xhMessage.status = XHMessageStatusReceived;
    }
    return xhMessage;
}
- (NSMutableArray *)getXHMessages:(NSArray *)msgs {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (AVIMTypedMessage *msg in msgs) {
        XHMessage *xhMsg = [self getXHMessageByMsg:msg];
        if (xhMsg) {
            [messages addObject:xhMsg];
        }
    }
    return messages;
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
                
                NSMutableArray *xhMsgs = [self getXHMessages:allMessages];
                self.messages = xhMsgs;
                self.msgs = allMessages;
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
        return;
    } else {
        WEAKSELF
        self.isLoadingMsg = YES;
        AVIMTypedMessage *msg = [self.msgs objectAtIndex:0];
        int64_t timestamp = msg.sendTimestamp;
        [self queryAndCacheMessagesWithTimestamp:timestamp block:^(NSArray *msgs, NSError *error) {
            if ([weakSelf filterError:error] && isNotEmpty(msgs)) {
                NSMutableArray *xhMsgs = [[weakSelf getXHMessages:msgs] mutableCopy];
                NSMutableArray *newMsgs = [NSMutableArray arrayWithArray:msgs];
                [newMsgs addObjectsFromArray:weakSelf.msgs];
                weakSelf.msgs = newMsgs;
                if ([xhMsgs count] > 0) {
                    [weakSelf insertOldMessages:xhMsgs completion: ^{
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
            XHMessage *xhMessage = [self getXHMessageByMsg:message];
            [self.msgs addObject:message];
            [self.messages addObject:xhMessage];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.msgs.count -1 inSection:0];
            [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomAnimated:YES];
        }
        self.isLoadingMsg = NO;
    }];
}

@end
