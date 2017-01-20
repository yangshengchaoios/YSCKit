//
//  YSCModel.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//


/**
 *
 * @brief  最外层的JSON对象
 *
 * 功能：判断返回状态
 *
 */
@interface YSCModel : NSObject
@property (assign, nonatomic) NSInteger state;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSObject *data;

/** json -> model */
+ (id)objectWithKeyValues:(id)keyValues;
/** 根据错误码判断返回的数据是否成功 */
- (BOOL)checkRequestIsSuccess;
@end
