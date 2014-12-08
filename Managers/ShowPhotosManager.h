//
//  ShowPhotosManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-30.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowPhotosManager : NSObject

#pragma mark - TODO:showPhotoViewController

+ (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView;
+ (UIViewController *)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView;

@end
