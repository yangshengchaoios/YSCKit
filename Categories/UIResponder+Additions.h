//
//  UIResponder+Additions.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-24.
//  Copyright (c) 2014年 YSHCH_TEAM. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>

@interface UIResponder (Additions)

+ (id)currentFirstResponder;
+ (UIViewController *)createBaseViewController:(NSString *)className;
@end
