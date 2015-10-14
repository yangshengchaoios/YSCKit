//
//  AFNManager.h
//  YSCKit
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <JSONModel/JSONModel.h>

#pragma mark - block定义

typedef void (^RequestSuccessed)(id responseObject);
typedef void (^RequestFailure)(NSInteger errorCode, NSString *errorMessage);

@interface AFNManager : NSObject

#pragma mark - 最常用的GET和POST

+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             modelName:(Class)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
              modelName:(Class)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure;

#pragma mark - 自定义url前缀的GET和POST

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             modelName:(Class)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
         andDictParam:(NSDictionary *)dictParam
            modelName:(Class)modelName
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure;


#pragma mark - 通用的GET和POST（只返回BaseModel的Data内容）

+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           modelName:(Class)modelName
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;

#pragma mark - 上传文件

+ (void)uploadImageDataParam:(NSDictionary *)imageDataParam
                       toUrl:(NSString *)url
                     withApi:(NSString *)apiName
                andDictParam:(NSDictionary *)dictParam
                imageQuality:(ImageQuality)quality
            requestSuccessed:(RequestSuccessed)requestSuccessed
              requestFailure:(RequestFailure)requestFailure;

#pragma mark - 通用的GET、POST和上传图片（返回JSONModel的所有内容）

+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
      customModelClass:(Class)modelClass
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
       customModelClass:(Class)modelClass
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure;
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
        andDictParam:(NSDictionary *)dictParam
    customModelClass:(Class)modelClass
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;

// 发起get & post & 上传图片 请求
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
   andImageDataParam:(NSDictionary *)imageDataParam
    customModelClass:(Class)modelClass
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;


//下载文件
+ (void)downloadFileFromUrl:(NSString *)url
                 saveToPath:(NSString *)destPath
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure;

@end
