//
//  XHMessageTableViewCell.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageTableViewCell.h"
#import "XHMessageStatusView.h"

static const CGFloat kXHLabelPadding = 5.0f;
static const CGFloat kXHTimeStampLabelHeight = 20.0f;

static const CGFloat kXHAvatorPaddingX = 8.0;
static const CGFloat kXHAvatorPaddingY = 15;

static const CGFloat kXHBubbleMessageViewPadding = 8;


@interface XHMessageTableViewCell ()
@property (nonatomic, weak, readwrite) XHMessageBubbleView *messageBubbleView;
@property (nonatomic, weak, readwrite) UIButton *avatorButton;
@property (nonatomic, weak, readwrite) XHMessageStatusView *statusView;
@property (nonatomic, weak, readwrite) LKBadgeView *timestampLabel;
@property (nonatomic, assign) BOOL displayTimestamp;
@end

@implementation XHMessageTableViewCell

//头像按钮，点击事件
- (void)avatorButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectedAvatorOnMessage:atIndexPath:)]) {
        [self.delegate didSelectedAvatorOnMessage:self.messageBubbleView.message atIndexPath:self.indexPath];
    }
}
- (void)retryButtonClicked:(UIButton*)sender{
    if([_delegate respondsToSelector:@selector(didRetrySendMessage:atIndexPath:)]){
        [_delegate didRetrySendMessage:self.messageBubbleView.message atIndexPath:self.indexPath];
    }
}

#pragma mark - Copying Method
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (XHBubbleMessageMediaTypePhoto == self.messageBubbleView.message.messageMediaType) {
        return (action == @selector(copyed:) ||
                action == @selector(transpond:) ||
                action == @selector(favorites:) ||
                action == @selector(more:) ||
                action == @selector(save:));
    }
    else {
        return NO;
    }
}

#pragma mark - Menu Actions
- (void)copyed:(id)sender {
    [[UIPasteboard generalPasteboard] setString:Trim(self.messageBubbleView.displayTextView.text)];
    [self resignFirstResponder];
    DLog(@"Cell was copy");
}
- (void)transpond:(id)sender {
    DLog(@"Cell was transpond");
}
- (void)favorites:(id)sender {
    DLog(@"Cell was favorites");
}
- (void)more:(id)sender {
    DLog(@"Cell was more");
}
- (void)save:(id)sender {
    DLog(@"Cell was save");
    if (self.messageBubbleView.bubblePhotoImageView.messagePhoto) {
        [UIView showHUDLoadingOnWindow:@"正在保存"];
        UIImageWriteToSavedPhotosAlbum(self.messageBubbleView.bubblePhotoImageView.messagePhoto, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
// 写到文件的完成时执行
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (nil == error) {
        [UIView showResultThenHideOnWindow:@"保存成功"];
    }
    else {
        [UIView showResultThenHideOnWindow:@"保存失败！"];
    }
}

#pragma mark - Setters
- (void)configureCellWithMessage:(id <XHMessageModel>)message displaysTimestamp:(BOOL)displayTimestamp {
    self.displayTimestamp = displayTimestamp;
    // 1、是否显示TimeLine的label
    [self configureTimestampAtMessage:message];
    
    // 2、配置头像
    [self configAvatorWithMessage:message];
    
    // 3、配置需要显示什么消息内容，比如语音、文字、视频、图片
    [self configureMessageBubbleViewWithMessage:message];
    
    [self.statusView setStatus:[message status]];
}
//1、是否显示Time Line的label
- (void)configureTimestampAtMessage:(id <XHMessageModel>)message {
    self.timestampLabel.hidden = ! self.displayTimestamp;
    if (self.displayTimestamp) {
        NSString *dateText = [message.timestamp stringWithFormat:@"yyyy-M-d"];
        NSString *timeText = [message.timestamp stringWithFormat:@"HH:mm"];
        if ([message.timestamp isThisYear]) {
            if ([message.timestamp isToday]) {
                dateText = NSLocalizedStringFromTable(@"Today", @"MessageDisplayKitString", @"今天");
            }
            else if ([message.timestamp isYesterday]) {
                dateText = NSLocalizedStringFromTable(@"Yesterday", @"MessageDisplayKitString", @"昨天");
            }
            else {
                dateText = [message.timestamp stringWithFormat:@"M-d"];
            }
        }
        self.timestampLabel.text = [NSString stringWithFormat:@"%@ %@",dateText,timeText];
    }
}
//2、配置头像
- (void)configAvatorWithMessage:(id <XHMessageModel>)message {
    if (message.avator) {
        [self.avatorButton setImage:message.avator forState:UIControlStateNormal];
    }
    else if(message.avatorUrl) {
        [self.avatorButton setImageWithURL:[NSURL URLWithString:message.avatorUrl] placeholer:DefaultAvatarImage];
    }
    else {
        [self.avatorButton setImage:[XHMessageAvatorFactory avatarImageNamed:[UIImage imageNamed:@"avator"] messageAvatorType:XHMessageAvatorTypeSquare] forState:UIControlStateNormal];
    }
}
//3、配置需要显示什么消息内容，比如语音、文字、视频、图片
- (void)configureMessageBubbleViewWithMessage:(id <XHMessageModel>)message {
    XHBubbleMessageMediaType currentMediaType = message.messageMediaType;
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubbleImageView.gestureRecognizers) {
        [self.messageBubbleView.bubbleImageView removeGestureRecognizer:gesTureRecognizer];
    }
    for (UIGestureRecognizer *gesTureRecognizer in self.messageBubbleView.bubblePhotoImageView.gestureRecognizers) {
        [self.messageBubbleView.bubblePhotoImageView removeGestureRecognizer:gesTureRecognizer];
    }
    switch (currentMediaType) {
        case XHBubbleMessageMediaTypePhoto:
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypeLocalPosition: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            [self.messageBubbleView.bubblePhotoImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypeVoice: {
            NSString* durationStr = @"";
            if(message.voiceDuration != 0){
                durationStr = [NSString stringWithFormat:@"%@\'\'", message.voiceDuration];
            }
            self.messageBubbleView.voiceDurationLabel.text = durationStr;
        }
        case XHBubbleMessageMediaTypeEmotion: {
            UITapGestureRecognizer *tapGestureRecognizer;
            if (currentMediaType == XHBubbleMessageMediaTypeText) {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizerHandle:)];
            } else {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            }
            tapGestureRecognizer.numberOfTapsRequired = (currentMediaType == XHBubbleMessageMediaTypeText ? 2 : 1);
            [self.messageBubbleView.bubbleImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        default:
            break;
    }
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self.messageBubbleView.bubbleImageView addGestureRecognizer:recognizer];
    [self.messageBubbleView.bubblePhotoImageView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [self.messageBubbleView configureCellWithMessage:message];
}

#pragma mark - Gestures
//统一一个方法隐藏MenuController，多处需要调用
- (void)setupNormalMenuController {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}
//点击Cell的手势处理方法，用于隐藏MenuController的
- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self setupNormalMenuController];
}
//长按Cell的手势处理方法，用于显示MenuController的
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder]) {
        return;
    }
//    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", @"MessageDisplayKitString", @"复制") action:@selector(copyed:)];
//    UIMenuItem *transpond = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"transpond", @"MessageDisplayKitString", @"转发") action:@selector(transpond:)];
//    UIMenuItem *favorites = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"favorites", @"MessageDisplayKitString", @"收藏") action:@selector(favorites:)];
//    UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"more", @"MessageDisplayKitString", @"更多") action:@selector(more:)];
    UIMenuItem *save = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"MessageDisplayKitString", @"保存") action:@selector(save:)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:save/*copy, transpond, favorites, more*/, nil]];
    
    
    CGRect targetRect = [self convertRect:[self.messageBubbleView bubbleFrame]
                                 fromView:self.messageBubbleView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
    [menu setMenuVisible:YES animated:YES];
}
//单击手势处理方法，用于点击多媒体消息触发方法，比如点击语音需要播放的回调、点击图片需要查看大图的回调
- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setupNormalMenuController];
        if ([self.delegate respondsToSelector:@selector(multiMediaMessageDidSelectedOnMessage:atIndexPath:onMessageTableViewCell:)]) {
            [self.delegate multiMediaMessageDidSelectedOnMessage:self.messageBubbleView.message atIndexPath:self.indexPath onMessageTableViewCell:self];
        }
    }
}
//双击手势处理方法，用于双击文本消息，进行放大文本的回调
- (void)doubleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didDoubleSelectedOnTextMessage:atIndexPath:)]) {
            [self.delegate didDoubleSelectedOnTextMessage:self.messageBubbleView.message atIndexPath:self.indexPath];
        }
    }
}

#pragma mark - Notifications
- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillHideMenuNotification
                                                  object:nil];
}
- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMenuWillHideNotification:)
                                                 name:UIMenuControllerWillHideMenuNotification
                                               object:nil];
}

#pragma mark - Getters
- (XHBubbleMessageType)bubbleMessageType {
    return self.messageBubbleView.message.bubbleMessageType;
}
+ (CGFloat)calculateCellHeightWithMessage:(id <XHMessageModel>)message displaysTimestamp:(BOOL)displayTimestamp {
    CGFloat timestampHeight = displayTimestamp ? (kXHTimeStampLabelHeight + kXHLabelPadding * 2) : kXHLabelPadding;
    CGFloat avatarHeight = kXHAvatarImageSize;
    CGFloat userNameHeight = 0;
    CGFloat subviewHeights = timestampHeight + kXHBubbleMessageViewPadding * 2 + userNameHeight;
    CGFloat bubbleHeight = [XHMessageBubbleView calculateCellHeightWithMessage:message];
    return subviewHeights + MAX(avatarHeight, bubbleHeight);
}

#pragma mark - Life cycle

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
}
- (instancetype)initWithMessage:(id <XHMessageModel>)message reuseIdentifier:(NSString *)cellIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (self) {//根据Message类型进行初始化控件，比如配置头像，配置发送和接收的样式
        // 1、显示Time Line的label
        if (nil == self.timestampLabel) {
            LKBadgeView *timestampLabel = [[LKBadgeView alloc] initWithFrame:CGRectMake(0, kXHLabelPadding, [UIScreen mainScreen].bounds.size.width, kXHTimeStampLabelHeight)];
            timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            timestampLabel.badgeColor = [UIColor colorWithWhite:0.000 alpha:0.380];
            timestampLabel.textColor = [UIColor whiteColor];
            timestampLabel.font = [UIFont systemFontOfSize:13.0f];
            timestampLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, timestampLabel.center.y);
            [self.contentView addSubview:timestampLabel];
            [self.contentView bringSubviewToFront:timestampLabel];
            self.timestampLabel = timestampLabel;
        }
        
        // 2、配置头像
        if(nil == self.avatorButton){
            UIButton *avatorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kXHAvatarImageSize, kXHAvatarImageSize)];
            [avatorButton setImage:[XHMessageAvatorFactory avatarImageNamed:[UIImage imageNamed:@"avator"] messageAvatorType:XHMessageAvatorTypeCircle] forState:UIControlStateNormal];
            [avatorButton addTarget:self action:@selector(avatorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:avatorButton];
            [self.contentView bringSubviewToFront:avatorButton];
            self.avatorButton = avatorButton;
        }
        
        // 4、配置需要显示什么消息内容，比如语音、文字、视频、图片
        if (nil == self.messageBubbleView) {
            XHMessageBubbleView *messageBubbleView = [[XHMessageBubbleView alloc] initWithFrame:CGRectZero message:message];
            messageBubbleView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                                  | UIViewAutoresizingFlexibleHeight
                                                  | UIViewAutoresizingFlexibleBottomMargin);
            [self.contentView addSubview:messageBubbleView];
            [self.contentView sendSubviewToBack:messageBubbleView];
            self.messageBubbleView = messageBubbleView;
        }
        
        if(nil == self.statusView){
            XHMessageStatusView *statusView = [[XHMessageStatusView alloc] initWithFrame:CGRectMake(0, 0, kXHStatusViewWidth, kXHStatusViewHeight)];
            [self.contentView addSubview:statusView];
            [self.contentView bringSubviewToFront:statusView];
            [statusView.retryButton addTarget:self action:@selector(retryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.statusView = statusView;
        }
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [self setup];
}
//在显示界面的时候重新根据message来调整元素位置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //重新调整头像位置
    CGFloat layoutOriginY = kXHAvatorPaddingY + (self.displayTimestamp ? kXHTimeStampLabelHeight : 0);
    CGRect avatorButtonFrame = self.avatorButton.frame;
    avatorButtonFrame.origin.y = layoutOriginY;
    avatorButtonFrame.origin.x = ([self bubbleMessageType] == XHBubbleMessageTypeReceiving) ? kXHAvatorPaddingX : ((CGRectGetWidth(self.bounds) - kXHAvatorPaddingX - kXHAvatarImageSize));
    self.avatorButton.frame = avatorButtonFrame;
    
    //重新调整气泡位置和大小
    layoutOriginY = kXHBubbleMessageViewPadding + (self.displayTimestamp ? kXHTimeStampLabelHeight : 0);
    CGRect bubbleMessageViewFrame = self.messageBubbleView.frame;
    bubbleMessageViewFrame.origin.y = layoutOriginY;
    CGFloat bubbleX = 0.0f;
    CGFloat offsetX = 0.0f;
    if ([self bubbleMessageType] == XHBubbleMessageTypeReceiving) {
        bubbleX = kXHAvatarImageSize + kXHAvatorPaddingX + kXHAvatorPaddingX;
    }
    else {
        offsetX = kXHAvatarImageSize + kXHAvatorPaddingX + kXHAvatorPaddingX;
    }
    bubbleMessageViewFrame.origin.x = bubbleX;
    bubbleMessageViewFrame.size.width = self.contentView.frame.size.width - bubbleX - offsetX;
    bubbleMessageViewFrame.size.height = self.contentView.frame.size.height - (kXHBubbleMessageViewPadding + (self.displayTimestamp ? (kXHTimeStampLabelHeight + kXHLabelPadding) : kXHLabelPadding));
    self.messageBubbleView.frame = bubbleMessageViewFrame;
    
    //重新调整statusView位置
    if(self.bubbleMessageType == XHBubbleMessageTypeSending) {
        self.statusView.hidden = NO;
        CGFloat statusX = CGRectGetMinX(self.messageBubbleView.bubbleFrame) - kXHStatusViewWidth - 3;
        CGFloat halfH = self.messageBubbleView.bubbleFrame.size.height / 2;
        CGRect statusFrame = self.statusView.frame;
        statusFrame.origin.y = layoutOriginY + halfH;
        if([self.messageBubbleView.message messageMediaType] == XHBubbleMessageMediaTypeVoice && self.messageBubbleView.message.voiceDuration != 0){
            statusX = statusX - 20;
        }
        statusFrame.origin.x = statusX;
        self.statusView.frame = statusFrame;
    }
    else {
        self.statusView.hidden = YES;
    }
}
- (void)dealloc {
    _avatorButton = nil;
    _timestampLabel = nil;
    _messageBubbleView = nil;
    _indexPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableViewCell
- (void)prepareForReuse {
    [super prepareForReuse];
    NSLog(@"XHMessageTableViewCell prepareForResue");
    self.messageBubbleView.animationVoiceImageView.image = nil;
    self.messageBubbleView.displayTextView.text = nil;
    self.messageBubbleView.displayTextView.attributedText = nil;
    self.messageBubbleView.bubblePhotoImageView.messagePhoto = nil;
    self.messageBubbleView.emotionImageView.animatedImage = nil;
    self.timestampLabel.text = nil;
}
@end
