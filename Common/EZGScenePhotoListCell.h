//
//  EZGScenePhotoListCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/11/16.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZGScenePhotoListCell : YSCBaseTableViewCell
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *imageDescLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageDescWidth;
@property (nonatomic, weak) IBOutlet UIImageView *sceneImageView;//现场拍摄的照片
@property (nonatomic, weak) IBOutlet UIImageView *tipImageView;//提示图片
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;//请您在保证安全下拍摄
@end
