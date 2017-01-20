//
//  YSCDataBaseModel.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

/**
 *
 * @brief  YSCModel.data模型的基类
 * 
 * 功能：序列化、简单网络请求、与json互转、分组标记
 *
 */
@interface YSCDataBaseModel : NSObject <NSCopying>

/** 单独转换属性名称(一般用于改变头字母大小写) */
+ (NSString *)jsonKeyFromPropertyName:(NSString *)propertyName;
/** 属性名称对应json中的key名称 */
+ (NSDictionary *)propertyNameToJsonKey;
/** 属性名称对应的class名称 */
+ (NSDictionary *)propertyNameToClassName;
/** json -> model */
+ (id)objectWithKeyValues:(id)keyValues;
/** model -> json */
- (NSString *)toJSONString;

/** 接口访问方法GET */
+ (NSString *)getByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block;
/** 接口访问方法POST */
+ (NSString *)postByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block;
/** 接口访问方法post body data */
+ (NSString *)requestByApi:(NSString *)apiName params:(NSDictionary *)params block:(YSCObjectErrorMessageBlock)block;
@end
