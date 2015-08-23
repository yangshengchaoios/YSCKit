//
//  ShowPhotosManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-30.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "ShowPhotosManager.h"

@implementation ShowPhotosManager

+ (void)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView {
    YSCBaseViewController *baseVC = (YSCBaseViewController *)[AppConfigManager sharedInstance].currentViewController;
    [baseVC pushViewController:@"YSCPhotoBrowseViewController"
                    withParams:@{kParamImageUrls : imageUrls, kParamIndex : @(index)}
                      animated:NO];
}
+ (void)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView {
    YSCBaseViewController *baseVC = (YSCBaseViewController *)[AppConfigManager sharedInstance].currentViewController;
    [baseVC pushViewController:@"YSCPhotoBrowseViewController"
                    withParams:@{kParamImages : images, kParamIndex : @(index)}
                      animated:NO];
}

@end
