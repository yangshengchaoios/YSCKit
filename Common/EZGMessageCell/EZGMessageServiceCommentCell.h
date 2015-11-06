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

@property (weak, nonatomic) IBOutlet UILabel *commentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *separationLineLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *rateImageViewArray;
@property (weak, nonatomic) IBOutlet UILabel *overLabel;

@end
