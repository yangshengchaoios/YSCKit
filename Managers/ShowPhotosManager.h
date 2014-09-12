//
//  ShowPhotosManager.h
//  CJLogistic
//
//  Created by  YangShengchao on 14-7-30.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowPhotosManager : NSObject

#pragma mark - TODO:showPhotoViewController
- (UIViewController *)showPhotosWithImage:(UIImage *)image;
- (UIViewController *)showPhotosWithImages:(NSArray *)images;
- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index;
- (UIViewController *)showPhotosWithImageUrl:(NSString *)imageUrl;
- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls;
- (UIViewController *)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index;

@end
