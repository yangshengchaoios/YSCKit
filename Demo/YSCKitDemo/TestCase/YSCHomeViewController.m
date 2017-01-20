//
//  YSCHomeViewController.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCHomeViewController.h"
#import "YSCTableView.h"

//=================================================
//
//  header
//
//=================================================
@interface YSCHomeHeaderView : YSCBaseTableHeaderFooterView
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation YSCHomeHeaderView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    self.titleLabel.ysc_left = 10;
}
- (UILabel *)titleLabel {
    if ( ! _titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (void)layoutObject:(CommonItemModel *)model {
    self.titleLabel.text = model.sectionTitle;
}
+ (CGFloat)heightOfViewByObject:(NSObject *)object {
    return 20;
}
@end

//=================================================
//
//  cell
//
//=================================================
@interface YSCHomeCell : YSCBaseTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation YSCHomeCell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(10, 5, 200, 30);
    
}
- (UILabel *)titleLabel {
    if ( ! _titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (void)layoutObject:(CommonItemModel *)model {
    self.titleLabel.text = model.title;
}
+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 40;
}
@end


//=================================================
//
//  tableView
//
//=================================================
@interface YSCHomeViewController ()
@property (nonatomic, strong) YSCTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end
@implementation YSCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YSCKitDemo";
    [self setupItems];
    [self setupTableView];
}
/** 初始化测试模块数据源 */
- (void)setupItems {
    self.itemArray = [NSMutableArray array];
    // test base
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSArray" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSData" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSDate" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSDictionary" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSFileManager" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestBase" title:@"NSString" viewController:@""]];
    
    // test adapter
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestAdapter" title:@"YSCHUD" viewController:@"TestAdapterViewController"]];
    
    // test singleton
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestSingleton" title:@"YSCManager" viewController:@"TestSingletonViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestSingleton" title:@"YSCConfigManager" viewController:@"TestSingletonViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestSingleton" title:@"YSCRequestManager" viewController:@"TestSingletonViewController"]];
    
    // test utils
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestUtils" title:@"YSCFormat" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestUtils" title:@"YSCStorage" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestUtils" title:@"YSCLog" viewController:@""]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestUtils" title:@"YSCGeneral" viewController:@""]];
    
    // test view
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCCustomAlertView" viewController:@"TestCustomAlertViewViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCSwipeCell" viewController:@"TestSwipeCellViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCGridBrowseView" viewController:@"TestGridBrowseViewViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCPhotoBrowseView" viewController:@"TestPhotoBrowseViewViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCInfiniteLoopView" viewController:@"TestInfiniteLoopViewViewController"]];
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestView" title:@"YSCZoomScrollView" viewController:@"TestZoomScrollViewViewController"]];
    
    // test view controller
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestViewController" title:@"YSCBaseViewController" viewController:@"TestUtilsViewController"]];
    
    // solution
    [self.itemArray addObject:[CommonItemModel createItemBySectionTitle:@"TestSolution" title:@"PullToRefresh" viewController:@"TestPullToRefreshViewController"]];
}
/** 初始化tableview */
- (void)setupTableView {
    @weakiy(self);
    self.tableView.headerName = @"YSCHomeHeaderView";
    self.tableView.cellName = @"YSCHomeCell";
    self.tableView.helper.enableTips = NO;
    self.tableView.helper.enableRefresh = NO;
    self.tableView.helper.enableLoadMore = NO;
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        CommonItemModel *item = (CommonItemModel *)object;
        if (OBJECT_ISNOT_EMPTY(item.viewController)) {
            [weak_self ysc_pushViewController:item.viewController withParams:@{kParamTitle : TRIM_STRING(item.title)}];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"请查看项目YSCKitDemoTests下的Test%@.m", item.title];
            YSCAlert *alertUtil = [YSCAlert alertWithTitle:@"提示" message:message style:YSCAlertControllerStyleAlert];
            [alertUtil addCancelActionWithTitle:@"好的" handler:^{
                NSLog(@"好的");
            }];
            [alertUtil addTextFieldWithHandler:^(UITextField *textField) {
                textField.placeholder = @"first";
            }];
            [alertUtil addTextFieldWithHandler:^(UITextField *textField) {
                textField.placeholder = @"second";
            }];
            [alertUtil addTextFieldWithHandler:^(UITextField *textField) {
                textField.placeholder = @"third";
            }];
            [alertUtil showOnViewController:weak_self];
        }
    };
    [self.tableView.helper layoutObjectAtFirstPage:self.itemArray errorMessage:nil];
}

- (YSCTableView *)tableView {
    if ( ! _tableView) {
        _tableView = [[YSCTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    NSLog(@"self.tableView.frame=%@", NSStringFromCGRect(self.tableView.frame));
}

@end
