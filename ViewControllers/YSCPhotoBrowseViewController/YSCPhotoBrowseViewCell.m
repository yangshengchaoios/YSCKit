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
@property (assign, nonatomic) BOOL isAnimating;//是否正在加载图片
@end

@implementation YSCPhotoBrowseViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photoImageView.userInteractionEnabled = YES;
    self.zoomScrollView.userInteractionEnabled = YES;
    self.zoomScrollView.showsHorizontalScrollIndicator = NO;
    self.zoomScrollView.showsVerticalScrollIndicator = NO;
    self.zoomScrollView.minimumZoomScale = 1.0;
    self.zoomScrollView.maximumZoomScale = 3.0;
    self.zoomScrollView.delegate = self;
}
- (void)layoutObject:(YSCPhotoBrowseCellModel *)dataModel {
    [self.zoomScrollView setZoomScale:1 animated:NO];
    if (isNotEmpty(dataModel.image)) {
        self.isAnimating = NO;
        self.photoImageView.image = dataModel.image;
        self.savedImage = dataModel.image;
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else {
        self.indicatorLabel.text = @"图片加载中";
        self.isAnimating = YES;
        if ([NSString isNotUrl:dataModel.imageUrl]) {
            UIImage *cacheImage = [UIImage imageWithContentsOfFile:dataModel.imageUrl];
            self.savedImage = cacheImage;
            if (cacheImage) {
                self.isAnimating = NO;
                self.photoImageView.image = cacheImage;
                self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            }
            else {
                [self.indicatorView stopAnimating];
                self.indicatorView.hidden = YES;
                self.indicatorLabel.text = @"图片加载失败";
            }
        }
        else {
            WEAKSELF
            [self.photoImageView setImageWithURLString:dataModel.imageUrl completed:^(UIImage *image, NSError *error) {
                if (image) {
                    weakSelf.isAnimating = NO;
                    weakSelf.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                    weakSelf.savedImage = image;
                }
                else {
                    [weakSelf.indicatorView stopAnimating];
                    weakSelf.indicatorView.hidden = YES;
                    weakSelf.indicatorLabel.text = @"图片加载失败";
                }
            }];
        }
    }
    
    //NOTE:添加点击图片关闭图片查看器
    [self.photoImageView removeAllGestureRecognizers];
    [self.photoImageView bk_whenTapped:^{
        UIViewController *controller = [AppConfigManager sharedInstance].currentViewController;
        [controller.navigationController popViewControllerAnimated:NO];
    }];
}
//设置是否正在下载图片
- (void)setIsAnimating:(BOOL)isAnimating {
    _isAnimating = isAnimating;
    self.photoImageView.hidden = isAnimating;
    self.indicatorView.hidden = self.indicatorLabel.hidden = ! isAnimating;
    [self.indicatorView startAnimating];
    self.zoomScrollView.userInteractionEnabled = ! isAnimating;
}

#pragma mark - UIScrollViewDelegate
//scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样
//1.返回要缩放的图片
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.photoImageView;
}
//2.重新确定缩放完后的缩放倍数
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

@end
