//
//  YSCPhotoBrowseViewCell.h
//  EZGoal
//
//  Created by yangshengchao on 15/8/23.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCPhotoBrowseViewCell : YSCBaseCollectionViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *zoomScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) UIImage *savedImage;

@end
