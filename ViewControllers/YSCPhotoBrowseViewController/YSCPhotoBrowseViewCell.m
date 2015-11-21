//
//  YSCPhotoBrowseViewCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/23.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCPhotoBrowseViewCell.h"

@interface YSCPhotoBrowseViewCell () <UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat lastScale;

@end

@implementation YSCPhotoBrowseViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photoImageView.userInteractionEnabled = YES;
    self.zoomScrollView.userInteractionEnabled = YES;
}
- (void)layoutObject:(YSCPhotoBrowseCellModel *)dataModel {
    if (isNotEmpty(dataModel.imageUrl)) {
        WEAKSELF
        self.photoImageView.hidden = YES;
        if ([NSString isNotUrl:dataModel.imageUrl]) {
            UIImage *cacheImage = [UIImage imageWithContentsOfFile:dataModel.imageUrl];
            self.savedImage = cacheImage;
            if (cacheImage) {
                self.photoImageView.hidden = NO;
                self.photoImageView.image = cacheImage;
                self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            }
        }
        else {
            [self.photoImageView setImageWithURLString:dataModel.imageUrl completed:^(UIImage *image, NSError *error) {
                weakSelf.photoImageView.hidden = NO;
                weakSelf.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                weakSelf.savedImage = image;
            }];
        }
    }
    else {
        self.photoImageView.image = dataModel.image;
        self.savedImage = dataModel.image;
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self.zoomScrollView setZoomScale:1 animated:NO];
    self.zoomScrollView.showsHorizontalScrollIndicator = NO;
    self.zoomScrollView.showsVerticalScrollIndicator = NO;
    self.zoomScrollView.minimumZoomScale = 1.0;
    self.zoomScrollView.maximumZoomScale = 3.0;
    self.zoomScrollView.delegate = self;
    
    //NOTE:添加点击图片关闭图片查看器
    [self.photoImageView removeAllGestureRecognizers];
    [self.photoImageView bk_whenTapped:^{
        UIViewController *controller = [AppConfigManager sharedInstance].currentViewController;
        [controller.navigationController popViewControllerAnimated:NO];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

@end
