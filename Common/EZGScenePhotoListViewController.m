//
//  EZGScenePhotoListViewController.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/16.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGScenePhotoListViewController.h"

@interface EZGScenePhotoListViewController ()
@property (nonatomic, weak) IBOutlet YSCTableView *tableView;
@property (nonatomic, strong) NSMutableArray *sceneImageArray;
@end

@implementation EZGScenePhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.params[kParamEdit] boolValue]) {//上传现场照片
        [self initTableViewForEdit];
        WEAKSELF
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"确定上传" style:UIBarButtonItemStylePlain handler:^(id sender) {
            if (weakSelf.block) {
                weakSelf.block(weakSelf.sceneImageArray);
            }
        }];
    }
    else {
        [self initTableViewForView];
    }
}
//初始化查看列表
- (void)initTableViewForView {
    NSMutableArray *imageUrlArray = [NSMutableArray array];
    WEAKSELF
    self.tableView.cellName = @"EZGScenePhotoListCell";
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
//初始化编辑列表
- (void)initTableViewForEdit {
    WEAKSELF
    self.sceneImageArray = [NSMutableArray array];
    if ([self.params[kParamIsSingleCar] boolValue]) {
        NSArray *imageDesArray = @[@"事故侧前方", @"事故侧后方", @"碰撞部位"];
        for (int i = 1; i <= 3; i++) {
            NSString *imageName = [NSString stringWithFormat:@"tipimage_singlecar_%d", i];
            ImageModel *imageModel = [ImageModel new];
            imageModel.imageUrl = imageName;
            imageModel.imageDescription = imageDesArray[i - 1];
            [self.sceneImageArray addObject:imageModel];
        }
    }
    else {
        NSArray *imageDesArray = @[@"事故侧前方", @"事故侧后方", @"己方车辆全景", @"对方车辆全景", @"碰撞部位"];
        for (int i = 1; i <= 5; i++) {
            NSString *imageName = [NSString stringWithFormat:@"tipimage_multicar_%d", i];
            ImageModel *imageModel = [ImageModel new];
            imageModel.imageUrl = imageName;
            imageModel.imageDescription = imageDesArray[i - 1];
            [self.sceneImageArray addObject:imageModel];
        }
    }
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.enableRefresh = NO;
    self.tableView.enableLoadMore = NO;
    self.tableView.requestType = RequestTypeCustomResponse;
    self.tableView.cellName = @"EZGScenePhotoListCell";
    self.tableView.cellHeightBlock = ^CGFloat(NSIndexPath *indexPath) {
        if ([weakSelf.tableView isLastCellByIndexPath:indexPath]) {
            return AUTOLAYOUT_LENGTH(360);
        }
        else {
            return AUTOLAYOUT_LENGTH(360 + 20);
        }
    };
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        ImageModel *imageModel = (ImageModel *)object;
        //TODO:重新拍照
    };
    self.tableView.cellDataArray = @[self.sceneImageArray];
    [self.tableView reloadData];
}
@end
