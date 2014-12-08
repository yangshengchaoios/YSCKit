//
//  NSObject+Addition.h
//  KQ
//
//  Created by  YangShengchao on 14-7-2.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <Foundation/Foundation.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  针对NSObject扩展
//
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSObject (Addition)

#pragma mark -  check empty
+ (BOOL)isEmpty:(id)object;
+ (BOOL)isNotEmpty:(id)object;

@end
