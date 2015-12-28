//
//  EZGAccidentPhotoListCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/16.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGAccidentPhotoListCell.h"

@implementation EZGAccidentPhotoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor blackColor];
    [self.imageDescLabel makeRoundWithRadius:AUTOLAYOUT_LENGTH(30) / 2];
}

+ (CGFloat)HeightOfCellByObject:(NSObject *)object {
    return AUTOLAYOUT_LENGTH(360 + 20);
}

- (void)layoutObject:(ImageModel *)dataModel {
    NSString *imageDesc = Trim(dataModel.imageDescription);
    if (isNotEmpty(dataModel.image)) { //显示拍照的图片
        self.sceneImageView.hidden = NO;
        self.imageDescLabel.hidden = NO;
        self.tipImageView.hidden = YES;
        self.tipLabel.hidden = YES;
        self.sceneImageView.image = dataModel.image;
        self.imageDescLabel.text = imageDesc;
        CGFloat imageDescWidth = [self.imageDescLabel sizeThatFits:CGSizeMake(MAXFLOAT, AUTOLAYOUT_LENGTH(28))].width;
        self.imageDescWidth.constant = imageDescWidth + 10;
    }
    else {
        if ([NSString isUrl:dataModel.imageUrl]) {//网络图片直接显示
            self.sceneImageView.hidden = NO;
            self.imageDescLabel.hidden = YES;
            self.tipImageView.hidden = YES;
            self.tipLabel.hidden = YES;
            [self.sceneImageView setImageWithURLString:dataModel.imageUrl completed:^(UIImage *image, NSError *error) {
                self.sceneImageView.contentMode = UIViewContentModeScaleToFill;
                self.sceneImageView.clipsToBounds = YES;
            }];
        }
        else {//显示提示图片
            self.sceneImageView.hidden = YES;
            self.imageDescLabel.hidden = NO;
            self.tipImageView.hidden = NO;
            self.tipLabel.hidden = NO;
            self.tipImageView.image = [UIImage imageNamed:dataModel.imageUrl];
            self.tipImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.imageDescLabel.text = imageDesc;
            CGFloat imageDescWidth = [self.imageDescLabel sizeThatFits:CGSizeMake(MAXFLOAT, AUTOLAYOUT_LENGTH(28))].width;
            self.imageDescWidth.constant = imageDescWidth + 10;
        }
    }
}

@end
