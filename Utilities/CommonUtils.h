//
//  CommonUtils.h
//  KQ
//
//  Created by yangshengchao on 14-10-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  全局通用静态类
 *  作用：主要是公用可以独立执行的方法集合
 */
@interface CommonUtils : NSObject

+ (void)checkNewVersion;
+ (void)configUmeng;
+ (void)initAppDefaultUI;
+ (UIView *)createSearchBar:(NSInteger)textFieldTag;
@end
