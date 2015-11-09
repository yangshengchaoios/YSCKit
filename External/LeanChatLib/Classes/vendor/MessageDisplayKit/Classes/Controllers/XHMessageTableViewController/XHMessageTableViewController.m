//
//  XHMessageTableViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface XHMessageTableViewController ()
@property (nonatomic, assign) BOOL isUserScrolling;//判断是否用户手指滚动
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;//记录旧的textView contentSize Heigth
@property (nonatomic, assign) CGFloat keyboardViewHeight;//记录键盘的高度，为了适配iPad和iPhone
@property (nonatomic, assign) XHInputViewType textViewInputViewType;

@property (nonatomic, weak, readwrite) XHMessageTableView *messageTableView;
@property (nonatomic, weak, readwrite) XHMessageInputView *messageInputView;
@property (nonatomic, weak, readwrite) XHShareMenuView *shareMenuView;
@property (nonatomic, weak, readwrite) XHEmotionManagerView *emotionManagerView;

@property (nonatomic, strong, readwrite) XHVoiceRecordHUD *voiceRecordHUD;
@property (nonatomic, strong) XHPhotographyHelper *photographyHelper;//管理本机的摄像和图片库的工具对象
@property (nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;//管理录音工具对象
@end

@implementation XHMessageTableViewController

#pragma mark - DataSource Change
//改变数据源需要的子线程
- (void)exChangeMessageDataSourceQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}
//执行块代码在主线程
- (void)exMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}
- (void)addMessage:(XHMessage *)addedMessage {
    WEAKSELF
    [self exChangeMessageDataSourceQueue:^{
        NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
        [messages addObject:addedMessage];
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
        [indexPaths addObject:[NSIndexPath indexPathForRow:messages.count - 1 inSection:0]];
        
        [weakSelf exMainQueue:^{
            weakSelf.messages = messages;
            [weakSelf.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf scrollToBottomAnimated:YES];
        }];
    }];
}
- (void)removeMessageAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.messages.count)
        return;
    [self.messages removeObjectAtIndex:indexPath.row];
    [self.messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}
static CGPoint  delayOffset = {0.0};
// http://stackoverflow.com/a/11602040 Keep UITableView static when inserting rows at the top
- (void)insertOldMessages:(NSArray *)oldMessages completion:(void (^)())completion {
    WEAKSELF
    [self exChangeMessageDataSourceQueue:^{
        delayOffset = weakSelf.messageTableView.contentOffset;
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:oldMessages.count];
        NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
        [oldMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
            delayOffset.y += [weakSelf calculateCellHeightWithMessage:[oldMessages objectAtIndex:idx] atIndexPath:indexPath];
            [indexSets addIndex:idx];
        }];
        NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:weakSelf.messages];
        [messages insertObjects:oldMessages atIndexes:indexSets];
        [weakSelf exMainQueue:^{
            [UIView setAnimationsEnabled:NO];
            weakSelf.messageTableView.userInteractionEnabled = NO;
            [weakSelf.messageTableView beginUpdates];
            weakSelf.messages = messages;
            [weakSelf.messageTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.messageTableView endUpdates];
            [UIView setAnimationsEnabled:YES];
            [weakSelf.messageTableView setContentOffset:delayOffset animated:NO];
            weakSelf.messageTableView.userInteractionEnabled = YES;
            if (completion) {
                completion();
            }
        }];
    }];
}
- (void)insertOldMessages:(NSArray *)oldMessages {
    [self insertOldMessages:oldMessages completion:nil];
}

#pragma mark - Propertys
- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _messages;
}
- (XHShareMenuView *)shareMenuView {
    if (!_shareMenuView) {
        XHShareMenuView *shareMenuView = [[XHShareMenuView alloc] initWithFrame:CGRectMake(0,
                                                                                           CGRectGetHeight(self.view.bounds),
                                                                                           CGRectGetWidth(self.view.bounds),
                                                                                           /*self.keyboardViewHeight*/
                                                                                           120)];
        shareMenuView.delegate = self;
        shareMenuView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        shareMenuView.alpha = 0.0;
        shareMenuView.shareMenuItems = self.shareMenuItems;
        [self.view addSubview:shareMenuView];
        _shareMenuView = shareMenuView;
    }
    [self.view bringSubviewToFront:_shareMenuView];
    return _shareMenuView;
}
- (XHEmotionManagerView *)emotionManagerView {
    if (!_emotionManagerView) {
        XHEmotionManagerView *emotionManagerView = [[XHEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), self.keyboardViewHeight)];
        emotionManagerView.delegate = self;
        emotionManagerView.dataSource = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 0.0;
        [self.view addSubview:emotionManagerView];
        _emotionManagerView = emotionManagerView;
    }
    [self.view bringSubviewToFront:_emotionManagerView];
    return _emotionManagerView;
}
- (XHVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[XHVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}
- (XHPhotographyHelper *)photographyHelper {
    if (!_photographyHelper) {
        _photographyHelper = [[XHPhotographyHelper alloc] init];
    }
    return _photographyHelper;
}
- (XHLocationHelper *)locationHelper {
    if (!_locationHelper) {
        _locationHelper = [[XHLocationHelper alloc] init];
    }
    return _locationHelper;
}
- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            DLog(@"已经达到最大限制时间了，进入下一步的提示");
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
        _voiceRecordHelper.minRecordTime = kVoiceRecorderMinTime;
    }
    return _voiceRecordHelper;
}

#pragma mark - Messages View Controller
- (void)finishSendMessageWithBubbleMessageType:(XHBubbleMessageMediaType)mediaType {
    switch (mediaType) {
        case XHBubbleMessageMediaTypeText: {
            [self.messageInputView.inputTextView setText:nil];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                self.messageInputView.inputTextView.enablesReturnKeyAutomatically = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.messageInputView.inputTextView.enablesReturnKeyAutomatically = YES;
                    [self.messageInputView.inputTextView reloadInputViews];
                });
            }
            break;
        }
        case XHBubbleMessageMediaTypePhoto: {
            break;
        }
        case XHBubbleMessageMediaTypeVideo: {
            break;
        }
        case XHBubbleMessageMediaTypeVoice: {
            break;
        }
        case XHBubbleMessageMediaTypeEmotion: {
            break;
        }
        case XHBubbleMessageMediaTypeLocalPosition: {
            break;
        }
        default:
            break;
    }
}
- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    _messageTableView.backgroundColor = color;
}
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.messageTableView.backgroundView = nil;
    self.messageTableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
}
- (void)scrollToBottomAnimated:(BOOL)animated {
	if (![self shouldAllowScroll])
        return;
	
    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated {
	if (![self shouldAllowScroll])
        return;
	
	[self.messageTableView scrollToRowAtIndexPath:indexPath
						  atScrollPosition:position
								  animated:animated];
}

#pragma mark - Previte Method
- (BOOL)shouldAllowScroll {
    if (self.isUserScrolling) {
        if ([self.delegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
            && [self.delegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Life Cycle
- (void)setup {
    // iPhone or iPad keyboard view height set here.
    self.keyboardViewHeight = (kIsiPad ? 264 : 216);
    _allowsPanToDismissKeyboard = NO;
    _allowsSendVoice = YES;
    _allowsSendMultiMedia = YES;
    _allowsSendFace = YES;
    _inputViewStyle = XHMessageInputViewStyleFlat;
    
    self.delegate = self;
    self.dataSource = self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [self setup];
}
- (void)initilzer {
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 默认设置用户滚动为NO
    _isUserScrolling = NO;
    
    // 初始化message tableView
	XHMessageTableView *messageTableView = [[XHMessageTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	messageTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	messageTableView.dataSource = self;
	messageTableView.delegate = self;
    messageTableView.separatorColor = [UIColor clearColor];
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:messageTableView];
    [self.view sendSubviewToBack:messageTableView];
	_messageTableView = messageTableView;
    
    //注册自定义消息cell
    [EZGMessageTextCell registerCellToTableView:messageTableView];
    [EZGMessageVoiceCell registerCellToTableView:messageTableView];
    [EZGMessageImageCell registerCellToTableView:messageTableView];
    [EZGMessageLocationCell registerCellToTableView:messageTableView];
    [EZGMessageVideoCell registerCellToTableView:messageTableView];
    [EZGMessageSceneCell registerCellToTableView:messageTableView];
    [EZGMessageCarCell registerCellToTableView:messageTableView];
    [EZGMessageServiceCell registerCellToTableView:messageTableView];
    [EZGMessageServiceCancelCell registerCellToTableView:messageTableView];
    [EZGMessageServiceCommentCell registerCellToTableView:messageTableView];
    
    // 设置Message TableView 的bottom edg
    CGFloat inputViewHeight = (self.inputViewStyle == XHMessageInputViewStyleFlat) ? 45.0f : 40.0f;
    [self setTableViewInsetsWithBottomValue:inputViewHeight];
    
    // 设置整体背景颜色
    [self setBackgroundColor:RGB(228, 231, 233)];
    
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    WEAKSELF
    if (self.allowsPanToDismissKeyboard) {
        // 控制输入工具条的位置块
        void (^AnimationForMessageInputViewAtPoint)(CGPoint point) = ^(CGPoint point) {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            CGPoint keyboardOrigin = [weakSelf.view convertPoint:point fromView:nil];
            inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
        
        self.messageTableView.keyboardDidScrollToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.messageTableView.keyboardWillSnapBackToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        self.messageTableView.keyboardWillBeDismissed = ^() {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            inputViewFrame.origin.y = weakSelf.view.bounds.size.height - inputViewFrame.size.height;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
    }
    
    // block回调键盘通知
    self.messageTableView.keyboardWillChange = ^(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyborad) {
        if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:options
                             animations:^{
                                 CGFloat keyboardY = [weakSelf.view convertRect:keyboardRect fromView:nil].origin.y;
                                 
                                 CGRect inputViewFrame = weakSelf.messageInputView.frame;
                                 CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
                                 
                                 // for ipad modal form presentations
                                 CGFloat messageViewFrameBottom = weakSelf.view.frame.size.height - inputViewFrame.size.height;
                                 if (inputViewFrameY > messageViewFrameBottom)
                                     inputViewFrameY = messageViewFrameBottom;
                                 
                                 weakSelf.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                              inputViewFrameY,
                                                                              inputViewFrame.size.width,
                                                                              inputViewFrame.size.height);
                                 
                                 [weakSelf setTableViewInsetsWithBottomValue:weakSelf.view.frame.size.height
                                  - weakSelf.messageInputView.frame.origin.y];
                                 if (showKeyborad)
                                     [weakSelf scrollToBottomAnimated:NO];
                             }
                             completion:nil];
        }
    };
    
    self.messageTableView.keyboardDidChange = ^(BOOL didShowed) {
        if ([weakSelf.messageInputView.inputTextView isFirstResponder]) {
            if (didShowed) {
                if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
                    weakSelf.shareMenuView.alpha = 0.0;
                    weakSelf.emotionManagerView.alpha = 0.0;
                }
            }
        }
    };
    
    self.messageTableView.keyboardDidHide = ^() {
        [weakSelf.messageInputView.inputTextView resignFirstResponder];
    };
    
    // 初始化输入工具条
    XHMessageInputView *inputView = [[XHMessageInputView alloc] initWithFrame:inputFrame];
    inputView.allowsSendFace = self.allowsSendFace;
    inputView.allowsSendVoice = self.allowsSendVoice;
    inputView.allowsSendMultiMedia = self.allowsSendMultiMedia;
    inputView.delegate = self;
    [self.view addSubview:inputView];
    [self.view bringSubviewToFront:inputView];
    
    _messageInputView = inputView;
    
    
    // 设置手势滑动，默认添加一个bar的高度值
    self.messageTableView.messageInputBarHeight = CGRectGetHeight(_messageInputView.bounds);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置键盘通知或者手势控制键盘消失
    [self.messageTableView setupPanGestureControlKeyboardHide:self.allowsPanToDismissKeyboard];
    
    // KVO 检查contentSize
    [self.messageInputView.inputTextView addObserver:self
                                          forKeyPath:@"contentSize"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
    
    [self.messageInputView.inputTextView setEditable:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self finishRecordingWhenErrorBehaviors];
    if (self.textViewInputViewType != XHInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
    
    // remove键盘通知或者手势
    [self.messageTableView disSetupPanGestureControlKeyboardHide:self.allowsPanToDismissKeyboard];
    
    // remove KVO
    [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    [self.messageInputView.inputTextView setEditable:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initilzer];
    [[XHMessageBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRecordingWhenErrorBehaviors) name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    _messages = nil;
    _delegate = nil;
    _dataSource = nil;
    _messageTableView.delegate = nil;
    _messageTableView.dataSource = nil;
    _messageTableView = nil;
    _messageInputView = nil;
    
    _photographyHelper = nil;
    _locationHelper = nil;
}

#pragma mark - View Rotation
- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - RecorderPath Helper Method
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    recorderPath = [[NSString alloc] initWithFormat:@"%@/Documents/IMRecorderPath", NSHomeDirectory()];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.aac", [dateFormatter stringFromDate:now]];
    return recorderPath;
}

#pragma mark - UITextView Helper Method
//获取某个UITextView对象的content高度
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    }
    else {
        return textView.contentSize.height;
    }
}

#pragma mark - Layout Message Input View Helper Method
//动态改变TextView的高度
- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [XHMessageInputView maxHeight];
    CGFloat contentH = [self getTextViewContentH:textView];
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setTableViewInsetsWithBottomValue:self.messageTableView.contentInset.bottom + changeInHeight];
                             
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - Scroll Message TableView Helper Method
//根据bottom的数值配置消息列表的内部布局变化
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.messageTableView.contentInset = insets;
    self.messageTableView.scrollIndicatorInsets = insets;
}
//根据底部高度获取UIEdgeInsets常量
- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = 64;
    }
    insets.bottom = bottom;
    return insets;
}

#pragma mark - Message Calculate Cell Height
//统一计算Cell的高度方法
- (CGFloat)calculateCellHeightWithMessage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    cellHeight = [XHMessageTableViewCell calculateCellHeightWithMessage:message displaysTimestamp:displayTimestamp];
    return cellHeight;
}

#pragma mark - Message Send helper Method
//根据文本开始发送文本消息
- (void)didSendMessageWithText:(NSString *)text {
    DLog(@"send text : %@", text);
    if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
        [self.delegate didSendText:text fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//根据图片开始发送图片消息
- (void)didSendMessageWithPhoto:(UIImage *)photo {
    DLog(@"send photo : %@", photo);
    if ([self.delegate respondsToSelector:@selector(didSendPhoto:fromSender:onDate:)]) {
        [self.delegate didSendPhoto:photo fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//根据视频的封面和视频的路径开始发送视频消息
- (void)didSendMessageWithVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath  {
    DLog(@"send videoPath : %@  videoConverPhoto : %@", videoPath, videoConverPhoto);
    if ([self.delegate respondsToSelector:@selector(didSendVideoConverPhoto:videoPath:fromSender:onDate:)]) {
        [self.delegate didSendVideoConverPhoto:videoConverPhoto videoPath:videoPath fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//根据录音路径开始发送语音消息
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration {
    DLog(@"send voicePath : %@", voicePath);
    if ([self.delegate respondsToSelector:@selector(didSendVoice:voiceDuration:fromSender:onDate:)]) {
        [self.delegate didSendVoice:voicePath voiceDuration:voiceDuration fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//根据第三方gif表情路径开始发送表情消息
- (void)didSendEmotionMessageWithEmotion:(NSString *)emotion {
    DLog(@"send emotion : %@", emotion);
    if ([self.delegate respondsToSelector:@selector(didSendEmotion:fromSender:onDate:)]) {
        [self.delegate didSendEmotion:emotion fromSender:self.messageSender onDate:[NSDate date]];
    }
}
//根据地理位置信息和地理经纬度开始发送地理位置消息
- (void)didSendGeolocationsMessageWithGeolocaltions:(NSString *)geolcations location:(CLLocation *)location {
    DLog(@"send geolcations : %@", geolcations);
    if ([self.delegate respondsToSelector:@selector(didSendGeoLocationsPhoto:geolocations:location:fromSender:onDate:)]) {
        [self.delegate didSendGeoLocationsPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:geolcations location:location fromSender:self.messageSender onDate:[NSDate date]];
    }
}

#pragma mark - Other Menu View Frame Helper Mehtod
//根据显示或隐藏的需求对所有第三方Menu进行管理
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    [self.messageInputView.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.messageInputView.frame;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            self.messageInputView.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.emotionManagerView.alpha = !hide;
            self.emotionManagerView.frame = otherMenuViewFrame;
        };
        
        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.shareMenuView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.shareMenuView.alpha = !hide;
            self.shareMenuView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
        [self scrollToBottomAnimated:NO];
    } completion:^(BOOL finished) {
        if (hide) {
            self.textViewInputViewType = XHInputViewTypeNormal;
        }
    }];
}

#pragma mark - Voice Recording Helper Method
- (void)prepareRecordWithCompletion:(XHPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}
- (void)startRecord {
    self.messageTableView.scrollEnabled = NO;
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}
- (void)finishRecorded {
    WEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
        weakSelf.messageInputView.isRecording = NO;
        weakSelf.messageInputView.isCancelled = NO;
        weakSelf.messageTableView.scrollEnabled = YES;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        [weakSelf didSendMessageWithVoice:weakSelf.voiceRecordHelper.recordPath voiceDuration:weakSelf.voiceRecordHelper.recordDuration];
    }];
}
- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}
- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}
- (void)cancelRecord {
    WEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
        weakSelf.messageInputView.isRecording = NO;
        weakSelf.messageInputView.isCancelled = YES;
        weakSelf.messageTableView.scrollEnabled = YES;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}
//当其它错误操作发生时，停止录音
- (void)finishRecordingWhenErrorBehaviors {
    if (self.messageInputView.isRecording) {
        [self didFinishRecoingVoiceAction];
    }
}

#pragma mark - XHMessageInputView Delegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView {
    self.textViewInputViewType = XHInputViewTypeText;
}
- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView {
    if (!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = [self getTextViewContentH:messageInputTextView];
}
- (void)didChangeSendVoiceAction:(BOOL)changed {
    DLog(@"didChangeSendVoiceAction");
    if (changed) {
        if (self.textViewInputViewType == XHInputViewTypeText)
            return;
        // 在这之前，textViewInputViewType已经不是XHTextViewTextInputType
        [self layoutOtherMenuViewHiden:YES];
    }
}
- (void)didInputAtSign:(XHMessageTextView *)messageInputTextView {
    DLog(@"didInputAtSign");
    if ([self.delegate respondsToSelector:@selector(didInputAtSignOnMessageTextView:)]) {
        [self.delegate didInputAtSignOnMessageTextView:messageInputTextView];
    }
}
- (void)didSendTextAction:(NSString *)text {
    DLog(@"text : %@", text);
    if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
        [self.delegate didSendText:text fromSender:self.messageSender onDate:[NSDate date]];
    }
}
- (void)didSelectedMultipleMediaAction {
    DLog(@"didSelectedMultipleMediaAction");
    self.textViewInputViewType = XHInputViewTypeShareMenu;
    [self layoutOtherMenuViewHiden:NO];
}
- (void)didSendFaceAction:(BOOL)sendFace {
    DLog(@"didSendFaceAction");
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    DLog(@"prepareRecordingWithCompletion");
    [self prepareRecordWithCompletion:completion];
}
- (void)didStartRecordingVoiceAction {
    DLog(@"didStartRecordingVoice");
    [self startRecord];
}
- (void)didCancelRecordingVoiceAction {
    DLog(@"didCancelRecordingVoice");
    [self cancelRecord];
}
- (void)didFinishRecoingVoiceAction {
    DLog(@"didFinishRecoingVoice");
    if (self.voiceRecordHelper.currentTimeInterval < self.voiceRecordHelper.minRecordTime) {
        [UIView showResultThenHideOnWindow:@"录音时间太短" afterDelay:0.5];
        [self cancelRecord];
    }
    else {
        [self finishRecorded];
    }
}
- (void)didDragOutsideAction {
    DLog(@"didDragOutsideAction");
    [self resumeRecord];
}
- (void)didDragInsideAction {
    DLog(@"didDragInsideAction");
    [self pauseRecord];
}

#pragma mark - XHShareMenuView Delegate
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    WEAKSELF
    void (^PickerMediaBlock)(UIImage *image, NSDictionary *editingInfo) = ^(UIImage *image, NSDictionary *editingInfo) {
        if (image) {
            [weakSelf didSendMessageWithPhoto:image];
        }
        else {
            if (!editingInfo)
                return ;
            NSString *mediaType = [editingInfo objectForKey: UIImagePickerControllerMediaType];
            NSString *videoPath;
            NSURL *videoUrl;
            if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
                videoUrl = (NSURL*)[editingInfo objectForKey:UIImagePickerControllerMediaURL];
                videoPath = [videoUrl path];
                UIImage *thumbnailImage = [XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath];
                [weakSelf didSendMessageWithVideoConverPhoto:thumbnailImage videoPath:videoPath];
            }
            else {
                [weakSelf didSendMessageWithPhoto:[editingInfo valueForKey:UIImagePickerControllerOriginalImage]];
            }
        }
    };
    switch (index) {
        case 0: {
            [self.photographyHelper showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypePhotoLibrary onViewController:self compled:PickerMediaBlock];
            break;
        }
        case 1: {
            [self.photographyHelper showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypeCamera onViewController:self compled:PickerMediaBlock];
            break;
        }
        case 2: {
            [self.locationHelper getCurrentGeolocationsCompled:^(NSArray *placemarks) {
                CLPlacemark *placemark = [placemarks lastObject];
                if (placemark) {
                    NSDictionary *addressDictionary = placemark.addressDictionary;
                    NSArray *formattedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    NSString *geoLocations = [formattedAddressLines lastObject];
                    if (geoLocations) {
                        [weakSelf didSendGeolocationsMessageWithGeolocaltions:geoLocations location:placemark.location];
                    }
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - XHEmotionManagerView Delegate
- (void)didSelecteEmotion:(XHEmotion *)emotion atIndexPath:(NSIndexPath *)indexPath {
    if (emotion.emotionPath) {
        [self didSendEmotionMessageWithEmotion:emotion.emotionPath];
    }
}
- (void)didSelectEmotionStoreButton:(UIButton *)button{
    [self didSendMessageWithText:self.messageInputView.inputTextView.text];
}

#pragma mark - XHEmotionManagerView DataSource
- (NSInteger)numberOfEmotionManagers {
    return 0;
}
- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return nil;
}
- (NSArray *)emotionManagersAtManager {
    return nil;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.isUserScrolling = YES;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.textViewInputViewType != XHInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
}

#pragma mark - XHMessageTableViewController Delegate
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

#pragma mark - XHMessageTableViewController DataSource
- (id <XHMessageModel>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.row];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <XHMessageModel> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    static NSString *cellIdentifier = @"XHMessageTableViewCell";
    XHMessageTableViewCell *messageTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == messageTableViewCell) {
        messageTableViewCell = [[XHMessageTableViewCell alloc] initWithMessage:message reuseIdentifier:cellIdentifier];
        messageTableViewCell.delegate = self;
    }
    messageTableViewCell.indexPath = indexPath;
    [messageTableViewCell configureCellWithMessage:message displaysTimestamp:displayTimestamp];
    if ([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.delegate configureCell:messageTableViewCell atIndexPath:indexPath];
    }
    
    return messageTableViewCell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <XHMessageModel> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    return [self calculateCellHeightWithMessage:message atIndexPath:indexPath];
}

#pragma mark - Key-value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.messageInputView.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

@end
