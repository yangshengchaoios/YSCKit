//
//  EZGMessageCenterViewController.h
//  B_EZGoal
//
//  Created by yangshengchao on 15/9/6.
//  Copyright (c) 2015年 YingChuangKeXun. All rights reserved.
//

#import "YSCBaseViewController.h"

@interface EZGMessageCenterViewController : YSCBaseViewController

@property (nonatomic, weak) IBOutlet YSCTableView *tableView;

- (void)refreshWhenDataIsEmpty;

@end
