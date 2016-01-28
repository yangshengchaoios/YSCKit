//
//  YSCRequestManager.h
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/28.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//

/**
 *  网络访问类
 *  作用：控制所有网络请求相关的业务
 *       包括业务数据的获取、上传文件、下载文件
 */


typedef void (^RequestSuccessed)(id responseObject);
typedef void (^RequestFailure)(ErrorType errorType, NSError *error);


//--------------------------------------
//  请求业务数据
//--------------------------------------
@interface YSCRequestManager : NSObject

// 最常用的GET和POST
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


// 处理YSCBaseModel和BaseDataModel映射、登陆过期(state=99)
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


// 处理自定义模型的映射
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
         customModel:(Class)customModel
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;


// 通用的GET、POST和上传图片（返回最原始的未经过任何映射的JSON字符串）
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;
@end



//--------------------------------------
//  上传大文件
//--------------------------------------
@interface YSCRequestManager (Upload)

@end


//--------------------------------------
//  下载大文件
//--------------------------------------
@interface YSCRequestManager (Download)

@end