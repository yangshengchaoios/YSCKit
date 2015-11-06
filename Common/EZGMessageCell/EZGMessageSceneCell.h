//
//  EZGMessageSceneCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/5.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGMessageBaseCell.h"

@interface EZGMessageSceneCell : EZGMessageBaseCell

@property (weak, nonatomic) IBOutlet UILabel *sceneTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *separationLineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleSceneImageView;

@end
