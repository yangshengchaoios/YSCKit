//
//  BasePullToRefreshView.h
//  HYTCosmetic
//
//  Created by yangshengchao on 15/1/4.
//  Copyright (c) 2015年 ZhongDaYunKe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PullToRefreshSuccessed)(void);
typedef void(^PullToRefreshFailed)(void);

@interface BasePullToRefreshView : UIView

@property (nonatomic, strong) UIView *segmentedControlView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end
