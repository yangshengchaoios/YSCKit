//
//  YSCPhotoBrowseViewCell.m
//  EZGoal
//
//  Created by yangshengchao on 15/8/23.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import "YSCPhotoBrowseViewCell.h"

@interface YSCPhotoBrowseViewCell ()

@property (assign, nonatomic) CGFloat lastScale;

@end

@implementation YSCPhotoBrowseViewCell

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
    
    self.photoImageView.transform = CGAffineTransformMakeScale(1, 1);
    self.photoImageView.userInteractionEnabled = YES;
    [self.photoImageView removeAllGestureRecognizers];
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.photoImageView addGestureRecognizer:pinchGestureRecognizer];
}

// 处理缩放手势
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        self.lastScale = [pinchGestureRecognizer scale];
    }
    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [pinchGestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[pinchGestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.5;
        const CGFloat kMinScale = 0.75;
        
        CGFloat newScale = 1 -  (self.lastScale - [pinchGestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[pinchGestureRecognizer view] transform], newScale, newScale);
        [pinchGestureRecognizer view].transform = transform;
        
        self.lastScale = [pinchGestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

@end
