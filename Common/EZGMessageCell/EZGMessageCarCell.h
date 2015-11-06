//
//  EZGMessageCarCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"

@interface EZGMessageCarCell : EZGMessageBaseCell

@property (weak, nonatomic) IBOutlet UILabel *carTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *separationLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *carBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@end
