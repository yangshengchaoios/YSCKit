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
    [self resetImageFrame];
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
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundSize = scrollView.bounds.size;
    CGRect frameToCenter = self.photoImageView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundSize.width)
        frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0.0;
    
    // center vertically
    if (frameToCenter.size.height < boundSize.height)
        frameToCenter.origin.y = (boundSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0.0;
    
    self.photoImageView.frame = frameToCenter;
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = self.zoomScrollView.frame.size.height / scale;
    zoomRect.size.width  = self.zoomScrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x;
    zoomRect.origin.y = center.y;
    return zoomRect;
}
- (void)resetImageFrame {
    [self.zoomScrollView setZoomScale:1 animated:NO];
}


@end
