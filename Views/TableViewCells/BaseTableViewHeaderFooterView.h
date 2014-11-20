//
//  BaseTableViewHeaderFooterView.h
//  KQ
//
//  Created by yangshengchao on 14/11/20.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIView *containerView;

+ (CGFloat)HeightOfView;

@end
