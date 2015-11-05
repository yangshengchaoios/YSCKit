//
//  EZGMessageBaseCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageStatusView.h"

#define kMarginTop              AUTOLAYOUT_LENGTH(16)
#define kMarginBottom           AUTOLAYOUT_LENGTH(4)
#define kPaddingTop             AUTOLAYOUT_LENGTH(24)
#define kBubblePaddingRight     AUTOLAYOUT_LENGTH(28)
#define kVoiceMargin            AUTOLAYOUT_LENGTH(40)
#define kXHArrowMarginWidth     AUTOLAYOUT_LENGTH(28)

// iPad
#define kIsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// image STRETCH
#define XH_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])


@interface EZGMessageBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;       //时间戳
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;  //用户头像
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;  //气泡图片
@property (weak, nonatomic) IBOutlet XHMessageStatusView *statusView;//发送消息的状态
@property (weak, nonatomic) AVIMTypedMessage *typedMessage;

+ (void)registerCellToTableView: (UITableView *)tableView;
+ (instancetype)dequeueCellByTableView :(UITableView *)tableView;

//动态计算图片显示的高度，等比例缩放，填满
+ (CGSize)SizeForPhoto:(UIImage *)photo;
//计算气泡高度
+ (CGSize)BubbleFrameWithMessage:(AVIMTypedMessage *)message;
//计算cell高度
+ (CGFloat)HeightOfCellByMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp;
//显示message
- (void)layoutMessage:(AVIMTypedMessage *)message displaysTimestamp:(BOOL)displayTimestamp;
//判断消息的方向
- (XHBubbleMessageType)bubbleMessageType;

@end
