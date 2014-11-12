//
//  BasePullToRefreshTableViewController.h
//  TGO2
//
//  Created by  YangShengchao on 14-4-18.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import "BasePullToRefreshViewController.h"

@interface BasePullToRefreshTableViewController : BasePullToRefreshViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * tableView;

#pragma mark - UITableView特有的方法 (如果cell的高度与object无关的话，可以不用重写该方法了)

- (CGFloat)tableViewCellHeightForData:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end
