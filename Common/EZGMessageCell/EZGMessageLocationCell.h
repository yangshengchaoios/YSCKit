//
//  EZGMessageLocationCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"
#import "XHBubblePhotoImageView.h"

@interface EZGMessageLocationCell : EZGMessageBaseCell

@property (weak, nonatomic) IBOutlet XHBubblePhotoImageView *bubblePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *geolocationsLabel;

@end
