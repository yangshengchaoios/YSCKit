//
//  EZGMessageLocationCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageLocationCell.h"

@implementation EZGMessageLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bubbleLocationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubbleLocationImageView];
        [self.contentView addSubview:self.addressLabel];
        
        self.addressLabel.font = [UIFont systemFontOfSize:14];
        self.addressLabel.numberOfLines = 2;
        self.addressLabel.textColor = [UIColor whiteColor];
        [self.bubbleLocationImageView makeRoundWithRadius:4];
    }
    return self;
}

#pragma mark - 计算大小
//计算气泡大小
+ (CGSize)BubbleFrameWithMessage:(AVIMLocationMessage *)message {
    return [self SizeForPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"]];
}

#pragma mark - 显示内容
//显示message
- (void)layoutMessage:(AVIMLocationMessage *)message displaysTimestamp:(BOOL)displayTimestamp {
    [super layoutMessage:message displaysTimestamp:displayTimestamp];
    self.bubbleLocationImageView.image = [UIImage imageNamed:@"Fav_Cell_Loc"];
    self.addressLabel.text = Trim(message.text);
}

//动态计算位置和大小
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //调整默认位置图片大小和位置
    CGRect contentFrame = [self calculateContentFrame];
    self.bubbleLocationImageView.frame = CGRectInset(contentFrame, -kXHBubbleMarginHor, -kXHBubbleMarginVer);
    self.bubbleLocationImageView.width -= 3;//FIXME:
    
    //调整文字大小和位置
    
    [self.addressLabel sizeToFit];
    self.addressLabel.width = self.bubbleLocationImageView.width - 2;
    self.addressLabel.height += 5;
    self.addressLabel.left = self.bubbleLocationImageView.left + 1;
    self.addressLabel.top = CGRectGetMaxY(self.bubbleLocationImageView.frame) - 1 - self.addressLabel.height;
}

@end
