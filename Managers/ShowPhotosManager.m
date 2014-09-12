//
//  ShowPhotosManager.m
//  CJLogistic
//
//  Created by  YangShengchao on 14-7-30.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "ShowPhotosManager.h"

@implementation ShowPhotosManager

#pragma mark - showPhotoViewController

- (UIViewController *)showPhotosWithImage:(UIImage *)image {
	if (!image) {
		return nil;
	}
	return [self showPhotosWithImages:@[image]];
}

- (UIViewController *)showPhotosWithImages:(NSArray *)images {
	return [self showPhotosWithImages:images atIndex:0];
}

- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index {
	if (![imageUrls count]) {
		return nil;
	}
//	UIViewController *viewController = [self pushViewController:@"PhotoViewController" withParams:@{@"imageUrls" : imageUrls, @"index" : @(index)}];
//	return viewController;
    return nil;
}

- (UIViewController *)showPhotosWithImageUrl:(NSString *)imageUrl {
	if ([NSString isEmpty:imageUrl]) {
		return nil;
	}
	return [self showPhotosWithImageUrls:@[imageUrl]];
}

- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls {
	return [self showPhotosWithImageUrls:imageUrls atIndex:0];
}

- (UIViewController *)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index {
	if (![images count]) {
		return nil;
	}
//	UIViewController *viewController = [self pushViewController:@"PhotoViewController" withParams:@{@"images" : images, @"index" : @(index)}];
//	return viewController;
    return nil;
}


@end
