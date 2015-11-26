//
//  EZGAccidentPhotoListViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/16.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGAccidentPhotoListViewController.h"

@interface EZGAccidentPhotoListViewController ()
@property (nonatomic, weak) IBOutlet YSCTableView *tableView;
@property (nonatomic, strong) NSMutableArray *sceneImageArray;
@end

@implementation EZGAccidentPhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
}
- (void)initTableView {
    NSMutableArray *imageUrlArray = [NSMutableArray array];
    WEAKSELF
    self.tableView.cellName = @"EZGAccidentPhotoListCell";
    self.tableView.methodName = kResPathAccidentDetail;
    self.tableView.enableLoadMore = NO;
    self.tableView.tipsEmptyText = @"亲，暂无您的现场照片数据哟！";
    self.tableView.dictParamBlock = ^NSDictionary *(NSInteger page) {
        return @{kParamAccidentId : Trim(self.params[kParamAccidentId])};
    };
    self.tableView.preProcessBlock = ^NSArray *(NSArray *array) {
        [imageUrlArray removeAllObjects];
        NSString *urlString = array[0];
        NSArray *tempArray = [NSString splitString:urlString byRegex:@","];
        NSMutableArray *retArray = [NSMutableArray array];
        for (NSString *imageUrl in tempArray) {
            ImageModel *imageModel = [ImageModel new];
            imageModel.imageUrl = imageUrl;
            [retArray addObject:imageModel];
            [imageUrlArray addObject:Trim(imageUrl)];
        }
        return retArray;
    };
    self.tableView.cellHeightBlock = ^CGFloat(NSIndexPath *indexPath) {
        if ([weakSelf.tableView isLastCellByIndexPath:indexPath]) {
            return AUTOLAYOUT_LENGTH(360);
        }
        else {
            return AUTOLAYOUT_LENGTH(360 + 20);
        }
    };
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        [ShowPhotosManager showPhotosWithImageUrls:imageUrlArray atIndex:indexPath.row fromImageView:nil];
    };
    [self.tableView beginRefreshing];
}
@end
