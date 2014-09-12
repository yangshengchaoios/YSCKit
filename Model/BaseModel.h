//
//  BaseModel.h
//  SCSDTGO
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import <JSONModel/JSONModel.h>

@interface BaseModel : JSONModel

@property (assign, nonatomic) NSInteger State;
@property (strong, nonatomic) NSString *Message;
@property (strong, nonatomic) NSObject<ConvertOnDemand> *Data;

@end


/**
 *  公共model的基类，主要是设置所有参数都是optional的，并添加序列化和反序列化方法
 */
@interface BaseDataModel : JSONModel

@end