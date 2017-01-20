//
//  TestSwipeCellViewController.m
//  YSCKitDemo
//
//  Created by Builder on 16/10/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestSwipeCellViewController.h"
#import "YSCTableView.h"

//=================================================
//
//  cell
//
//=================================================
@interface YSCSwipeCell : YSCSwipeTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation YSCSwipeCell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(10, 5, 300, 30);
    
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
- (void)layoutObject:(NSString *)title {
    self.titleLabel.text = title;
}
+ (CGFloat)heightOfCellByObject:(NSObject *)object {
    return 50;
}
@end

@interface TestSwipeCellViewController ()
@property (nonatomic, strong) YSCTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end

@implementation TestSwipeCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupItems];
    [self setupTableView];
}
- (void)setupItems {
    self.itemArray = [NSMutableArray array];
    for (int i = 1; i < 20; i++) {
        NSString *item = [NSString stringWithFormat:@"Test Swipe Cell item_%d", i];
        [self.itemArray addObject:item];
    }
}
- (void)setupTableView {
    @weakiy(self);
    self.tableView.cellName = @"YSCSwipeCell";
    self.tableView.helper.enableTips = NO;
    self.tableView.helper.enableRefresh = NO;
    self.tableView.helper.enableLoadMore = NO;
    self.tableView.clickCellBlock = ^(NSObject *object, NSIndexPath *indexPath) {
        
    };
    self.tableView.layoutCellView = ^(UIView *view, NSObject *object, NSIndexPath *indexPath) {
        YSCSwipeCell *cell = (YSCSwipeCell *)view;
        NSString *title = cell.titleLabel.text;
        cell.actionsBlock = ^NSArray *(YSCSwipeTableViewCell *cell, YSCSwipeDirection direction) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
            [button setTitle:@"button" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor purpleColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button ysc_addSingleTapWithBlock:^{
                NSString *msg = [NSString stringWithFormat:@"button clicked on %@", title];
                [YSCHUD showHUDThenHideOnKeyWindowWithMessage:msg];
            }];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 0)];
            label.backgroundColor = [UIColor lightGrayColor];
            label.textColor = [UIColor whiteColor];
            label.text = @"more";
            label.textAlignment = NSTextAlignmentCenter;
            label.userInteractionEnabled = YES;
            [label ysc_addSingleTapWithBlock:^{
                NSString *msg = [NSString stringWithFormat:@"label clicked on %@", title];
                [YSCHUD showHUDThenHideOnKeyWindowWithMessage:msg];
            }];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.image = [UIImage imageNamed:@"icon_delete_white"];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.backgroundColor = [UIColor redColor];
            imageView.userInteractionEnabled = YES;
            [imageView ysc_addSingleTapWithBlock:^{
                NSString *msg = [NSString stringWithFormat:@"imageView clicked on %@", title];
                [YSCHUD showHUDThenHideOnKeyWindowWithMessage:msg];
            }];
           
            if (YSCSwipeDirectionLeftToRight == direction) {
                return @[button, label];
            }
            else {
                return @[imageView];
            }
        };
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
