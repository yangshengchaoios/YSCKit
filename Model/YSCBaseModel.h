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
@class BaseDataModel, StateModel;

@interface YSCBaseModel : JSONModel
@property (assign, nonatomic) NSInteger stateInteger;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSObject<ConvertOnDemand> *data;
@property (strong, nonatomic) StateModel *stateModel;

+ (NSDictionary *)jsonToModelMapping;
- (void)formatProperties;
@end


/**
 *  公共model的基类，主要是设置所有参数都是optional的，并添加序列化和反序列化方法
 */
@interface BaseDataModel : JSONModel
@property (nonatomic, strong) NSString *sectionKey;//用于多section的TableView封装

+ (NSDictionary *)jsonToModelMapping;
+ (void)GetByMethod:(NSString *)method params:(NSDictionary *)params block:(YSCResponseErrorMessageBlock)block;
+ (void)PostByMethod:(NSString *)method params:(NSDictionary *)params block:(YSCResponseErrorMessageBlock)block;
@end

//针对基类数据模型不规则的情况
@interface StateModel : BaseDataModel
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *debugMsg;
@end

//YSCKit中用到的model
@interface YSCPhotoBrowseCellModel : BaseDataModel
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;

+ (instancetype)CreateModelByImageUrl:(NSString *)imageUrl image:(UIImage *)image;
@end