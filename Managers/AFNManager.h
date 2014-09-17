//
//  AFNManager.h
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//  FORMATED!
//

#import <JSONModel/JSONModel.h>

#pragma mark - block定义

typedef void (^RequestSuccessed)(id responseObject);
typedef void (^RequestFailure)(NSInteger errorCode, NSString *errorMessage);

typedef NS_ENUM (NSInteger, RequestType) {
	RequestTypeGET = 0,
	RequestTypePOST,
    RequestTypeUploadFile,
    RequestTypePostBodyData
};


@interface AFNManager : NSObject

#pragma mark - 最常用的GET和POST

+ (void)getDataWithAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataWithAPI:(NSString *)apiName
          andArrayParam:(NSArray *)arrayParam
           andDictParam:(NSDictionary *)dictParam
              dataModel:(NSString *)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure;
+ (void)postBodyDataWithAPI:(NSString *)apiName
              andArrayParam:(NSArray *)arrayParam
               andDictParam:(NSDictionary *)dictParam
               andBodyParam:(NSString *)bodyParam
                  dataModel:(NSString *)modelName
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure;

#pragma mark - 自定义url前缀的GET和POST

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure;
+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
        andArrayParam:(NSArray *)arrayParam
         andDictParam:(NSDictionary *)dictParam
            dataModel:(NSString *)modelName
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure;
+ (void)postBodyDataToUrl:(NSString *)url
                  withAPI:(NSString *)apiName
            andArrayParam:(NSArray *)arrayParam
             andDictParam:(NSDictionary *)dictParam
             andBodyParam:(NSString *)bodyParam
                dataModel:(NSString *)modelName
         requestSuccessed:(RequestSuccessed)requestSuccessed
           requestFailure:(RequestFailure)requestFailure;

#pragma mark - 上传文件

+ (void)uploadImage:(UIImage *)image
              toUrl:(NSString *)url
            withApi:(NSString *)apiName
      andArrayParam:(NSArray *)arrayParam
       andDictParam:(NSDictionary *)dictParam
          dataModel:(NSString *)modelName
       imageQuality:(ImageQuality)quality
   requestSuccessed:(RequestSuccessed)requestSuccessed
     requestFailure:(RequestFailure)requestFailure;

#pragma mark - 通用的GET和POST（只返回BaseModel的Data内容）

+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           dataModel:(NSString *)modelName
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;

#pragma mark - 通用的GET、POST和上传图片（返回BaseModel的所有内容）

+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure;


//TODO:测试参数加密字符串
+ (NSString *)signatureWithParam:(NSDictionary *)param;

@end
