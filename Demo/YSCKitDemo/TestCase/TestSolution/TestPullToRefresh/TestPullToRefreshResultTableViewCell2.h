//
//  TestPullToRefreshResultTableViewCell2.h
//  YSCKit
//
//  Created by Builder on 16/7/14.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPullToRefreshResultTableViewCell2 : YSCBaseTableViewCell
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *containerViewCollection;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabelCollection;
@end
