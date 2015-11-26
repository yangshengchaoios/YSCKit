//
//  EZGAddressSearchCell.h
//  EZGoal
//
//  Created by 钟博文 on 15/11/3.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZGAddressSearchCell : YSCBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImgView;
@property (assign, nonatomic) BOOL isSelected;
@end
