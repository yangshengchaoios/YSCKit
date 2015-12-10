//
//  EZGMessageBaseCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"
#import "CDChatManager.h"

@implementation EZGMessageBaseCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
        
        self.timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kXHLabelPadding, 0, kXHTimeStampLabelHeight)];
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kXHAvatarImageSize, kXHAvatarImageSize)];
        self.bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.statusView = [[XHMessageStatusView alloc] initWithFrame:CGRectMake(0, 0, kXHStatusViewWidth, kXHStatusViewHeight)];
        [self.contentView addSubview:self.timeStampLabel];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bubbleImageView];
        [self.contentView addSubview:self.statusView];
        
        self.bubbleImageView.clipsToBounds = YES;
        self.bubbleImageView.userInteractionEnabled = YES;
        self.bubbleImageView.backgroundColor = [UIColor clearColor];
        self.avatarImageView.userInteractionEnabled = YES;
        self.timeStampLabel.font = [UIFont systemFontOfSize:13];
        self.timeStampLabel.textColor = [UIColor whiteColor];
        self.timeStampLabel.textAlignment = NSTextAlignmentCenter;
        [self.timeStampLabel makeRoundWithRadius:kXHTimeStampLabelHeight / 2];
        self.timeStampLabel.backgroundColor = RGB(178, 178, 178);
        self.statusView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - 注册与重用
+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerClass:self.class forCellReuseIdentifier:NSStringFromClass(self.class)];
}
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView {
    EZGMessageBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    return cell;
}

#pragma mark - 计算大小
//动态计算图片显示的大小，等比例缩放，填满
+ (CGSize)SizeForPhoto:(UIImage *)photo {
    CGFloat photoWidth = photo.size.width;
    photoWidth = MIN(photoWidth, kBubbleServiceWidth);
    photoWidth = MAX(photoWidth, AUTOLAYOUT_LENGTH(150));
    CGFloat photoHeight = photoWidth * photo.size.height / photo.size.width;
    photoHeight = MAX(kXHAvatarImageSize, photoHeight);
    return CGSizeMake(photoWidth, photoHeight);
}
//计算内容大小(不包括气泡四周的边距)
+ (CGSize)ContentSizeWithMessage:(AVIMTypedMessage *)message {
    return AUTOLAYOUT_SIZE_WH(60, kXHAvatarImageSize);
}
//计算气泡大小(包括气泡四周的边距)
+ (CGSize)BubbleSizeWithMessage:(AVIMTypedMessage *)message {
    CGSize contentSize = [self ContentSizeWithMessage:message];
    return CGSizeMake(contentSize.width + kXHBubbleArrowWidth + kXHBubbleTailWidth,
                      contentSize.height + 2 * kXHBubbleMarginVerOffset);
}
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    //提前下载文件
    if (message.file && NO == message.file.isDataAvailable) {
        //异步下载图片、音频、视频
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error || data == nil) {
                NSLog(@"download file error : %@", error);
            }
        }];
    }
    
    CGFloat timestampHeight = displayTimestamp ? (kXHTimeStampLabelHeight + kXHLabelPadding * 2) : kXHLabelPadding;
    CGFloat avatarHeight = kXHAvatarImageSize + 2 * kXHBubbleMarginVerOffset;
    CGFloat bubbleHeight = [self BubbleSizeWithMessage:message].height;
    return timestampHeight + MAX(avatarHeight, bubbleHeight) + kXHLabelPadding;
}
//计算内容部分的坐标和大小(不包括内容与气泡边线的间隔)
- (CGRect)calculateContentFrame {
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        return CGRectMake(self.bubbleImageView.left + kXHBubbleArrowWidth + kXHBubbleMarginHor,
                          self.bubbleImageView.top + kXHBubbleMarginVerOffset + kXHBubbleMarginVer,
                          self.bubbleImageView.width - kXHBubbleArrowWidth - kXHBubbleTailWidth - 2 * kXHBubbleMarginHor,
                          self.bubbleImageView.height - 2 * kXHBubbleMarginVerOffset - 2 * kXHBubbleMarginVer);
    }
    else {
        return CGRectMake(self.bubbleImageView.left + kXHBubbleTailWidth + kXHBubbleMarginHor,
                          self.bubbleImageView.top + kXHBubbleMarginVerOffset + kXHBubbleMarginVer,
                          self.bubbleImageView.width - kXHBubbleArrowWidth - kXHBubbleTailWidth - 2 * kXHBubbleMarginHor,
                          self.bubbleImageView.height - 2 * kXHBubbleMarginVerOffset - 2 * kXHBubbleMarginVer);
    }
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    self.typedMessage = message;
    self.statusView.status = message.status;//设置消息状态
    
    //1. 设置时间
    self.timeStampLabel.hidden = ! displayTimestamp;
    if (displayTimestamp) {
        self.timeStampLabel.text = [self formatMessageTimeByTimeStamp:message.sendTimestamp];
    }
    
    //2. 设置头像
    if (message.attributes[MParamAvatarUrl]) {//如果消息中带有头像地址就直接显示该头像
        [self.avatarImageView setImageWithURLString:message.attributes[MParamAvatarUrl] placeholderImage:DefaultAvatarImage withFadeIn:NO];
    }
    else {
        if (EZGBubbleMessageTypeSending == [self bubbleMessageType]) {//自己的头像
            [self.avatarImageView setImageWithURLString:USERAVATAR placeholderImage:DefaultAvatarImage withFadeIn:NO];
        }
        else {//对方的头像
            [self.avatarImageView setImageWithURLString:APPDATA.chatUser.avatarUrl placeholderImage:DefaultAvatarImage withFadeIn:NO];
        }
    }
    
    //3. 设置气泡图片
    UIEdgeInsets edgeInsets = AUTOLAYOUT_EDGEINSETS(60, 50, 170, 50);// UIEdgeInsetsMake(30, 28, 85, 28);
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleImageView.image = [[UIImage imageNamed:@"EZGoal_Receiving_White"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    }
    else {
        //只有发送语音和文本消息用蓝色气泡
        if (kAVIMMessageMediaTypeText == message.mediaType || kAVIMMessageMediaTypeAudio == message.mediaType) {
            self.bubbleImageView.image = [[UIImage imageNamed:@"EZGoal_Sending_Blue"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
        else {
            self.bubbleImageView.image = [[UIImage imageNamed:@"EZGoal_Sending_White"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        }
    }
}
//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL displayTimestamp = ! self.timeStampLabel.hidden;
    CGFloat layoutOriginY = kXHLabelPadding;
    //调整timeStampLabel位置
    if (displayTimestamp) {
        [self.timeStampLabel sizeToFit];
        self.timeStampLabel.centerX = SCREEN_WIDTH / 2;
        self.timeStampLabel.width += AUTOLAYOUT_LENGTH(40);
        self.timeStampLabel.height = kXHTimeStampLabelHeight;
        layoutOriginY += kXHTimeStampLabelHeight + kXHLabelPadding;
    }
    
    //调整头像位置
    self.avatarImageView.top = layoutOriginY;
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.avatarImageView.left = kXHAvatorPadding;
    }
    else {
        self.avatarImageView.left = SCREEN_WIDTH - kXHAvatorPadding - kXHAvatarImageSize;
    }
    
    //重新调整气泡位置和大小
    self.bubbleImageView.top = self.avatarImageView.top - kXHBubbleMarginVerOffset;//NOTE:气泡边线与边界有5个像素透明高度
    self.bubbleImageView.size = [self.class BubbleSizeWithMessage:self.typedMessage];
    if (EZGBubbleMessageTypeReceiving == [self bubbleMessageType]) {
        self.bubbleImageView.left = kXHAvatorPadding + kXHAvatarImageSize;
    }
    else {
        self.bubbleImageView.left = self.avatarImageView.left - self.bubbleImageView.width;
    }
    
    //重新调整statusView位置
    if(EZGBubbleMessageTypeSending == [self bubbleMessageType]) {
        self.statusView.hidden = NO;
        self.statusView.centerY = self.bubbleImageView.centerY;
        self.statusView.left = self.bubbleImageView.left - kXHStatusViewWidth;
    }
    else {
        self.statusView.hidden = YES;
    }
}
//判断消息的方向
- (EZGBubbleMessageType)bubbleMessageType {
    if ([[CDChatManager manager].selfId isEqualToString:self.typedMessage.clientId]) {
        return EZGBubbleMessageTypeSending;
    }
    else {
        return EZGBubbleMessageTypeReceiving;
    }
}
//格式化消息时间
- (NSString *)formatMessageTimeByTimeStamp:(int64_t)timeStamp {
    NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:timeStamp / 1000];
    return [self formatMessageTimeByDate:sendDate];
}
- (NSString *)formatMessageTimeByDate:(NSDate *)messageDate {
    NSString *dateText = [messageDate stringWithFormat:@"yyyy年M月d日"];
    NSString *timeText = [messageDate stringWithFormat:@"HH:mm"];
    if ([messageDate isThisYear]) {
        if ([messageDate isToday]) {
            dateText = NSLocalizedStringFromTable(@"Today", @"MessageDisplayKitString", @"今天");
        }
        else if ([messageDate isYesterday]) {
            dateText = NSLocalizedStringFromTable(@"Yesterday", @"MessageDisplayKitString", @"昨天");
        }
        else {
            dateText = [messageDate stringWithFormat:@"M月d日"];
        }
    }
    return [NSString stringWithFormat:@"%@ %@",dateText,timeText];
}



#pragma mark - Long Press Gesture
//自动判断是否添加
- (void)addLongPressGesture {
    if ([self canPerformAction:@selector(copyed:) withSender:nil] ||
        [self canPerformAction:@selector(save:) withSender:nil]) {//NOTE:如果子类需要功能，就重写该方法
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
        [self.bubbleImageView addGestureRecognizer:longPressGesture];
    }
}
//统一一个方法隐藏MenuController，多处需要调用
- (void)setupNormalMenuController {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}
//长按Cell的手势处理方法，用于显示MenuController的
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder]) {
        return;
    }
    UIMenuItem *copyed = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", @"MessageDisplayKitString", @"复制") action:@selector(copyed:)];
    UIMenuItem *transpond = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"transpond", @"MessageDisplayKitString", @"转发") action:@selector(transpond:)];
    UIMenuItem *favorites = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"favorites", @"MessageDisplayKitString", @"收藏") action:@selector(favorites:)];
    UIMenuItem *more = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"more", @"MessageDisplayKitString", @"更多") action:@selector(more:)];
    UIMenuItem *save = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"save", @"MessageDisplayKitString", @"保存") action:@selector(save:)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObjects:save, copyed, transpond, favorites, more, nil]];
    [menu setTargetRect:CGRectInset(self.bubbleImageView.frame, 0.0f, 4.0f) inView:self.contentView];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark - Extend Methods
- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

#pragma mark - Menu Actions
- (void)copyed:(id)sender {

}
- (void)transpond:(id)sender {

}
- (void)favorites:(id)sender {

}
- (void)more:(id)sender {

}
- (void)save:(id)sender {

}

@end
