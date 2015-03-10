//
//  ShowPhotosManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-30.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//

#import "ShowPhotosManager.h"
#import "CXPhotoBrowser.h"

#define BROWSER_TITLE_LBL_TAG       12731

@interface ShowPhotosManager () <CXPhotoBrowserDataSource, CXPhotoBrowserDelegate>

@property (nonatomic, strong) CXPhotoBrowser *browser;
@property (nonatomic, strong) CXBrowserNavBarView *navBarView;
@property (nonatomic, strong) NSMutableArray *photoDataSource;

@end

@implementation ShowPhotosManager

- (id)init {
    self = [super init];
    if (self) {
        self.photoDataSource = [NSMutableArray array];
    }
    return self;
}

#pragma mark - showPhotoViewController

+ (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView {
    ShowPhotosManager *showPhotosManager = [ShowPhotosManager new];
    for (id imageUrl in imageUrls) {
        if ([imageUrl isKindOfClass:[ImageModel class]]) {
            ImageModel *imageModel = (ImageModel *)imageUrl;
            [showPhotosManager.photoDataSource addObject:[[CXPhoto alloc] initWithURL:[NSURL URLWithString:imageModel.imageUrl]]];
        }
        else if ([imageUrl isKindOfClass:[NSString class]]){
            [showPhotosManager.photoDataSource addObject:[[CXPhoto alloc] initWithURL:[NSURL URLWithString:(NSString *)imageUrl]]];
        }
    }
    showPhotosManager.browser = [[CXPhotoBrowser alloc] initWithDataSource:showPhotosManager delegate:showPhotosManager];
    [showPhotosManager.browser setInitialPageIndex:index];
    [showPhotosManager.browser.view bk_whenTapped:^{
        [showPhotosManager.browser dismissViewControllerAnimated:NO completion:nil];
    }];
    [[UIView currentViewController] presentViewController:showPhotosManager.browser animated:NO completion:nil];
    return showPhotosManager.browser;
}

+ (UIViewController *)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index fromImageView:(UIImageView *)imageView {
    ShowPhotosManager *showPhotosManager = [ShowPhotosManager new];
    for (UIImage *image in images) {
        [showPhotosManager.photoDataSource addObject:[[CXPhoto alloc] initWithImage:image]];
    }
    showPhotosManager.browser = [[CXPhotoBrowser alloc] initWithDataSource:showPhotosManager delegate:showPhotosManager];
    [showPhotosManager.browser setInitialPageIndex:index];
    [showPhotosManager.browser.view bk_whenTapped:^{
        [showPhotosManager.browser dismissViewControllerAnimated:NO completion:nil];
    }];
    [[UIView currentViewController] presentViewController:showPhotosManager.browser animated:NO completion:nil];
    return showPhotosManager.browser;
}


#pragma mark - CXPhotoBrowserDataSource
- (NSUInteger)numberOfPhotosInPhotoBrowser:(CXPhotoBrowser *)photoBrowser {
    return [self.photoDataSource count];
}
- (id <CXPhotoProtocol>)photoBrowser:(CXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [self.photoDataSource count]) {
        return [self.photoDataSource objectAtIndex:index];
    }
    return nil;
}

- (CXBrowserNavBarView *)browserNavigationBarViewOfOfPhotoBrowser:(CXPhotoBrowser *)photoBrowser withSize:(CGSize)size {
    CGRect frame;
    frame.origin = CGPointMake(0, SCREEN_HEIGHT - size.height);
    frame.size = size;
    if (!self.navBarView) {
        self.navBarView = [[CXBrowserNavBarView alloc] initWithFrame:frame];
        [self.navBarView setBackgroundColor:[UIColor clearColor]];
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setFrame:CGRectMake((size.width - 60)/2, 0, 60, 40)];
        [titleLabel setCenter:self.navBarView.center];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:20.]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTag:BROWSER_TITLE_LBL_TAG];
        [self.navBarView addSubview:titleLabel];
    }
    
    return self.navBarView;
}

#pragma mark - CXPhotoBrowserDelegate
- (void)photoBrowser:(CXPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index {
    UILabel *titleLabel = (UILabel *)[self.navBarView viewWithTag:BROWSER_TITLE_LBL_TAG];
    if (titleLabel) {
        titleLabel.text = [NSString stringWithFormat:@"%d / %d", index + 1, photoBrowser.photoCount];
    }
}
@end
