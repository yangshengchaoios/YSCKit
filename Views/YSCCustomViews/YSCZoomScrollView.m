//
//  YSCZoomScrollView.m
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/6.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//

#import "YSCZoomScrollView.h"

@interface YSCZoomScrollView ()
@property (nonatomic, strong) UIImageView *photoImageView;
@end
@implementation YSCZoomScrollView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.photoImageView.backgroundColor = [UIColor clearColor];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.photoImageView];
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 3.0;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    
    self.photoImageView.userInteractionEnabled = YES;
    [self.photoImageView bk_whenTapped:^{
        UIViewController *controller = [AppConfigManager sharedInstance].currentViewController;
        [controller.navigationController popViewControllerAnimated:NO];
    }];
}
//这里需要根据image的大小动态计算imageView的大小
- (void)setImage:(UIImage *)image {
    self.photoImageView.image = image;
    self.photoImageView.size = CGSizeMake(SCREEN_WIDTH, image.size.height * SCREEN_WIDTH / image.size.width);
    self.photoImageView.center = CGPointMake(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f);
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;//contentSize根据该缩放view的size等比例缩放
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {//在缩放过程中，动态设置图片的中心点始终处于屏幕中心
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) /2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) /2 : 0.0;
    self.photoImageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,
                                             scrollView.contentSize.height / 2 + offsetY);
}
@end
