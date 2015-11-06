//
//  EZGMessageServiceCancelCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"

@interface EZGMessageServiceCancelCell : EZGMessageBaseCell

@property (weak, nonatomic) IBOutlet UILabel *cancelTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *separationLineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cancelIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *cancelDetailLabel;

@end
