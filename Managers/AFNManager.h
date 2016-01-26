//
//  AFNManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#pragma mark - block定义

typedef void (^RequestSuccessed)(id responseObject);
typedef void (^RequestFailure)(ErrorType errorType, NSError *error);



@interface AFNManager : NSObject

#pragma mark - 最常用的GET和POST
+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             dataModel:(Class)dataModel
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
              dataModel:(Class)dataModel
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure;
+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             dataModel:(Class)dataModel
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
         andDictParam:(NSDictionary *)dictParam
            dataModel:(Class)dataModel
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure;

#pragma mark - 处理YSCBaseModel和BaseDataModel映射、登陆过期(state=99)
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           dataModel:(Class)dataModel
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;




#pragma mark - 处理自定义模型的映射
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
         customModel:(Class)customModel
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;


#pragma mark - 通用的GET、POST和上传图片（返回最原始的未经过任何映射的JSON字符串）
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;

@end
