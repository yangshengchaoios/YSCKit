//
//  BaseModel.h
//  YSCKit
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <JSONModel/JSONModel.h>

#define RegionDbPath       AppProgramPath(@"region.sqlite")

@interface BaseModel : JSONModel

@property (assign, nonatomic) NSInteger state;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSObject<ConvertOnDemand> *data;

@end


/**
 *  公共model的基类，主要是设置所有参数都是optional的，并添加序列化和反序列化方法
 */
@interface BaseDataModel : JSONModel

@end