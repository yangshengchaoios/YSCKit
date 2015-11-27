//
//  EZGCommonHeaderView.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/20.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZGCommonHeaderView : YSCBaseTableHeaderFooterView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *bkgImageView;
@property (weak, nonatomic) IBOutlet UILabel *lineTopLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpace;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineBottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end
