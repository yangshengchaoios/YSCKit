//
//  EZGMessageServiceCommentCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"
#import "TQStarRatingView.h"

@interface EZGMessageServiceCommentCell : EZGMessageBaseCell

@property (strong, nonatomic) UILabel *commentTitleLabel;
@property (strong, nonatomic) UILabel *separationLineLabel;
@property (strong, nonatomic) NSMutableArray *rateImageViewArray;
@property (strong, nonatomic) UILabel *overLabel;

@end
