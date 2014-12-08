//
//  BaseCollectionHeaderFooterView.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/24.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCollectionHeaderFooterView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *containerView;

+ (CGSize)SizeOfView;

+ (UINib *)NibNameOfView;

@end
