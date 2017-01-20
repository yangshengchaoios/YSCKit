//
//  TestPullToRefreshViewController.m
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestPullToRefreshViewController.h"
#import "YSCTableView.h"
#import "YSCCollectionView.h"
#import "TestPullToRefreshPromptTableViewCell.h"
#import "TestPullToRefreshResultTableViewCell1.h"
#import "TestPullToRefreshResultTableViewCell2.h"
#import "TestPullToRefreshCollectionViewCell.h"

@interface TestPullToRefreshViewController ()
@property (nonatomic, weak) IBOutlet YSCTextField *searchTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet YSCTableView *promptTableView;
@property (nonatomic, weak) IBOutlet YSCTableView *resultTableView;
@property (nonatomic, strong) YSCCollectionView *collectionView;
@property (nonatomic, strong) NSString *doSearchingRequestKey;
@end

@implementation TestPullToRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableViews];
    [self setupCollectionView];
    [self setBlocks];
}
- (void)setupTableViews {
    @weakiy(self);
    
    // promptTableView
    self.promptTableView.backgroundColor = RGB_GRAY(200);
    self.promptTableView.cellName = @"TestPullToRefreshPromptTableViewCell";
    self.promptTableView.cellSeperatorLeft = 10;
    self.promptTableView.cellSeperatorRight = 10;
    self.promptTableView.separatorColor = kDefaultGrayColor;
    self.promptTableView.helper.tipsEmptyText = @"没有提示数据";
    self.promptTableView.helper.enableLoadMore = NO;
    self.promptTableView.helper.customRefreshBlock = ^(NSInteger pageIndex) {
        // build call data array
    };
    self.promptTableView.helper.startLoadingBlock = ^(NSObject *object) {
        [weak_self addRequestId:(NSString *)object forKey:@"promptTableView"];
    };
    self.promptTableView.helper.finishLoadingBlock = ^(NSObject *object) {
        [weak_self removeRequestIdByKey:@"promptTableView"];
    };
    self.promptTableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        SearchPromptModel *model = (SearchPromptModel *)object;
        [weak_self.searchTextField setText:TRIM_STRING(model.promptName) notify:NO];
        [weak_self.resultTableView.helper beginRefreshing];
    };
    
    // resultTableView
    self.resultTableView.backgroundColor = RGB_GRAY(220);
    [self.resultTableView registerCellName:@"TestPullToRefreshResultTableViewCell1"];
    [self.resultTableView registerCellName:@"TestPullToRefreshResultTableViewCell2"];
    self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.resultTableView.separatorColor = kDefaultGrayColor;
    self.resultTableView.helper.tipsEmptyText = @"没有结果数据";
    self.resultTableView.helper.enableLoadMore = NO;
    self.resultTableView.helper.customRefreshBlock = ^(NSInteger pageIndex) {
        // build call data array
    };
    self.resultTableView.helper.preProcessBlock = ^NSArray *(NSArray *array) {
        SearchResultListModel *listModel = array[0];
        NSMutableArray *retArray = [NSMutableArray array];
        NSMutableArray *itemArray = [NSMutableArray array];
        for (SearchResultModel *model in listModel.movieList) {
            if (model.isBest) {
                [retArray addObject:model];
            }
            else {
                if ([itemArray count] >= 3) {
                    itemArray = [NSMutableArray array];
                }
                [itemArray addObject:model];
                
                if ( ! [retArray containsObject:itemArray]) {
                    [retArray addObject:itemArray];
                }
            }
        }
        return retArray;
    };
    self.resultTableView.cellNameBlock = ^NSString *(NSObject *object, NSIndexPath *indexPath) {
        if ([object isKindOfClass:[SearchResultModel class]]) {
            return @"TestPullToRefreshResultTableViewCell1";
        }
        else {
            return @"TestPullToRefreshResultTableViewCell2";
        }
    };
    self.resultTableView.layoutCellView = ^(UIView *view, NSObject *object, NSIndexPath *indexPath) {
        if ([object isKindOfClass:[SearchResultModel class]]) {
            SearchResultModel *model = (SearchResultModel *)object;
            TestPullToRefreshResultTableViewCell1 *cell = (TestPullToRefreshResultTableViewCell1 *)view;
            [cell.playButton ysc_reAddTouchUpInsideEventBlock:^(id sender) {
                NSLog(@"播放：%@", model.title);
            }];
        }
    };
    self.resultTableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        if ([object isKindOfClass:[SearchResultModel class]]) {
            SearchResultModel *model = (SearchResultModel *)object;
            NSLog(@"进入详情页面：%@", model.title);
        }
    };
}
- (NSString *)searchType {
    return 0 == self.segmentedControl.selectedSegmentIndex ? @"10" : @"20";
}
- (void)setupCollectionView {
    self.collectionView.cellName = @"TestPullToRefreshCollectionViewCell";
    self.collectionView.helper.tipsEmptyText = @"没有结果数据";
    self.collectionView.cellEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5);
    self.collectionView.helper.enableLoadMore = NO;
    self.collectionView.helper.customRefreshBlock = ^(NSInteger pageIndex) {
        // build call data array
    };
    self.collectionView.minimumInteritemSpacingBlock = ^CGFloat (NSInteger section) {
        return 5;
    };
    self.collectionView.helper.preProcessBlock = ^NSArray *(NSArray *array) {
        SearchResultListModel *listModel = array[0];
        return [[NSMutableArray alloc] initWithArray:listModel.movieList];
    };
    self.collectionView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        SearchResultModel *model = (SearchResultModel *)object;
        NSLog(@"进入详情页面：%@", model.title);
    };
}
- (void)setBlocks {
    @weakiy(self);
    // search textfield
    self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.searchTextField.placeholderColor = kDefaultGrayColor;
    self.searchTextField.keyboardReturnBlock = ^(NSObject *object) {
        [weak_self doSearching];
    };
    self.searchTextField.didChangedBlock = ^(NSObject *object) {
        if (OBJECT_IS_EMPTY(weak_self.searchTextField.textString)) {
            [weak_self.promptTableView.helper layoutObjectAtFirstPage:nil errorMessage:nil];
        }
        else {
            [weak_self.promptTableView.helper beginRefreshingByAnimation:NO];
        }
    };
    
    // search button
    [self.searchButton ysc_addCornerWithRadius:3];
    [self.searchButton ysc_addTouchUpInsideEventBlock:^(id sender) {
        [weak_self doSearching];
    }];
    
    // segmented control
    [self.segmentedControl ysc_addBlock:^(id sender) {
        weak_self.collectionView.hidden = 0 == weak_self.segmentedControl.selectedSegmentIndex;
    } forControlEvents:UIControlEventValueChanged];
}
- (void)doSearching {
    if (OBJECT_IS_EMPTY(self.searchTextField.textString)) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入搜索关键字" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (self.collectionView.hidden) {
        [self.resultTableView.helper beginRefreshing];
    }
    else {
        [self.collectionView.helper beginRefreshing];
    }
}
- (YSCCollectionView *)collectionView {
    if ( ! _collectionView) {
        UICollectionViewFlowLayout *flayout = [UICollectionViewFlowLayout new];
        _collectionView = [[YSCCollectionView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT - 50 - 64) collectionViewLayout:flayout];
        _collectionView.backgroundColor = kDefaultBlueColor2;
        [self.view addSubview:_collectionView];
        _collectionView.hidden = YES;
    }
    return _collectionView;
}
@end
