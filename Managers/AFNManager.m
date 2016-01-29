//
//  AFNManager.m
//  YSCKit
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "AFNManager.h"
#import "AFNetworking.h"
#import <UIImage+Resize.h>

@implementation AFNManager

//--------------------------------------------
//
//  最常用的GET和POST
//
//--------------------------------------------
+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             dataModel:(Class)dataModel
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:kResPathAppBaseUrl withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil dataModel:dataModel imageData:nil requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
              dataModel:(Class)dataModel
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:kResPathAppBaseUrl withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil dataModel:dataModel imageData:nil requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)RequestWithApi:(NSString *)apiName
                params:(NSDictionary *)params
           requestType:(RequestType)requestType
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    NSString *bodyParam = nil;
    if (RequestTypePostBodyData == requestType) {
        bodyParam = [NSString jsonStringWithObject:params];
    }
    [self requestByUrl:kResPathAppBaseUrl withAPI:apiName andArrayParam:nil andDictParam:params andBodyParam:bodyParam dataModel:nil imageData:nil requestType:requestType requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             dataModel:(Class)dataModel
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil dataModel:dataModel imageData:nil requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
         andDictParam:(NSDictionary *)dictParam
            dataModel:(Class)dataModel
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil dataModel:dataModel imageData:nil requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)RequestFromUrl:(NSString *)url
             withAPI:(NSString *)apiName
              params:(NSDictionary *)params
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    NSString *bodyParam = nil;
    if (RequestTypePostBodyData == requestType) {
        bodyParam = [NSString jsonStringWithObject:params];
    }
     [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:params andBodyParam:bodyParam dataModel:nil imageData:nil requestType:requestType requestSuccessed:requestSuccessed requestFailure:requestFailure];
}


//--------------------------------------------
//
//  处理BaseDataModel映射
//  将映射好的BaseDataModel.data模型往上层抛
//
//--------------------------------------------
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           dataModel:(Class)dataModel
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    //0. url组装、参数格式化
    NSString *tempUrl = [@"/" stringByAppendingPathComponent:apiName];//组装完整的url地址
    url = [url stringByAppendingString:tempUrl];
    if ([arrayParam count] > 0) {
        url = [url stringByAppendingFormat:@"/%@", [arrayParam componentsJoinedByString:@"/"]];//组装数组参数
    }
    NSDictionary *newDictParam = [AppData FormatRequestParams:dictParam];//格式化所有请求的参数
    
    //1. 调用网络访问通用方法
    [self requestByUrl:url andDictParam:newDictParam andBodyParam:bodyParam customModel:[YSCBaseModel class] imageData:imageData requestType:requestType requestSuccessed:^(id responseObject) {
        YSCBaseModel *baseModel = responseObject;
        if (baseModel && [baseModel isKindOfClass:[YSCBaseModel class]]) {
            if ([baseModel isSuccess]) {//接口访问成功，开始解析data模型
                NSObject *dataObject = baseModel.data;
                if (dataObject && dataModel && [[dataModel class] respondsToSelector:@selector(ObjectWithKeyValues:)]) {
                    dataObject = [dataModel ObjectWithKeyValues:dataObject];
                    if (dataObject) {//将成功映射后的data模型往上层抛
                        if (requestSuccessed) {
                            requestSuccessed(dataObject);
                        }
                    }
                    else {
                        if (requestFailure) {
                            requestFailure(ErrorTypeDataMappingFailed, CreateNSError(@"数据映射出错"));
                        }
                    }
                }
                else {
                    if (requestSuccessed) {
                        requestSuccessed(dataObject);
                    }
                }
            }
            else {
                if ([baseModel isLoginExpired]) {//登录过期
                    NSDictionary *param = @{kParamUserId : USERID, kParamMessage : Trim(baseModel.message)};
                    postNWithInfo(kNotificationLoginExpired, param);
                }
                if (requestFailure) {
                    requestFailure(ErrorTypeInternalServer, CreateNSErrorCode(baseModel.state, baseModel.message));
                }
            }
        }
        else {
            if (requestFailure) {
                requestFailure(ErrorTypeDataMappingFailed, CreateNSError(@"数据映射出错"));
            }
        }
    } requestFailure:requestFailure];
}


//--------------------------------------------
//
//  处理自定义模型的映射
//  将映射好的自定义模型往上层抛
//
//--------------------------------------------
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
         customModel:(Class)customModel
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url andDictParam:dictParam andBodyParam:bodyParam imageData:imageData requestType:requestType requestSuccessed:^(id responseObject) {
        NSObject *model = responseObject;
        if (customModel && [[customModel class] respondsToSelector:@selector(ObjectWithKeyValues:)]) {
            model = [customModel ObjectWithKeyValues:responseObject];
            if (model) {//将成功映射后的data模型往上层抛
                if (requestSuccessed) {
                    requestSuccessed(model);
                }
            }
            else {
                if (requestFailure) {
                    requestFailure(ErrorTypeDataMappingFailed, CreateNSError(@"数据映射出错"));
                }
            }
        }
        else {
            if (requestSuccessed) {
                requestSuccessed(model);
            }
        }
    } requestFailure:requestFailure];
}

/**
 *  发起get & post & 上传图片 请求
 *
 *  @param url              接口前缀 最后的'/'可有可无
 *  @param dictParam        字典参数，key-value
 *  @param imageData        图片资源
 *  @param requestType      RequestTypeGET、RequestTypePOST
 *  @param requestSuccessed 请求成功的回调
 *  @param requestFailure   请求失败的回调
 */
+ (void)requestByUrl:(NSString *)url
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    //0. 判断网络状态、判断url合法性
    if (NO == [ReachabilityManager sharedInstance].reachable) {
        if (requestFailure) {
            requestFailure(ErrorTypeDisconnected, CreateNSError(@"网络断开"));
        }
        return;
    }
    if (NO == [NSString isUrl:url]) {
        if (requestFailure) {
            requestFailure(ErrorTypeURLInvalid, CreateNSError(@"url不合法"));
        }
        return;
    }
    
    //1. 定义返回成功的block
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *resolvedString = [AppData ResolveResponseObject:responseObject];
        if ([resolvedString length] > 0) {
            if (requestSuccessed) {
                requestSuccessed(resolvedString);
            }
        }
        else {
            if (requestFailure) {
                requestFailure(ErrorTypeDataEmpty, CreateNSError(@"返回数据为空"));
            }
        }
    };
    
    //2. 定义返回失败的block
    void (^failed)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (200 != operation.response.statusCode) {
            if (401 == operation.response.statusCode) {
                NSDictionary *param = @{kParamUserId : USERID, kParamMessage : @"登录过期"};
                postNWithInfo(kNotificationLoginExpired, param);
                if (requestFailure) {
                    requestFailure(ErrorTypeLoginExpired, error);
                }
            }
            else {
                if (requestFailure) {
                    requestFailure(ErrorTypeServerFailed, error);
                }
            }
        }
        else {
            if (requestFailure) {
                requestFailure(ErrorTypeConnectionFailed, error);
            }
        }
    };
    
    //3. 发起网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = kDefaultAFNTimeOut;//设置POST和GET的超时时间
    //解决返回的Content-Type始终是application/xml问题！
    [manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];//TODO:压缩上传内容
    [manager.requestSerializer setValue:AppVersion forHTTPHeaderField:kParamVersion];
    [manager.requestSerializer setValue:kParamFromValue forHTTPHeaderField:kParamFrom];
    [manager.requestSerializer setValue:[AppData SignatureWithParams:dictParam] forHTTPHeaderField:kParamSignature];
    [manager.requestSerializer setValue:[AppData EncryptHttpHeaderToken] forHTTPHeaderField:kAppHTTPTokenName];
	if (RequestTypeGET == requestType) {
		NSLog(@"getting data from url[%@]", url);
		[manager   GET:url
		    parameters:dictParam
		       success:success
		       failure:failed];
	}
	else if (RequestTypePOST == requestType) {
        NSLog(@"posting data to url[%@]", url);
		[manager  POST:url
		    parameters:dictParam
		       success:success
		       failure:failed];
	}
	else if (RequestTypeUploadFile == requestType) {
        NSLog(@"uploading data to url[%@]", url);
		[manager       POST:url
                 parameters:dictParam
  constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
      if (imageData) {
          [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"application/octet-stream"];
      }
  }
                    success:success
                    failure:failed];
	}
    else if (RequestTypePostBodyData == requestType) {
        NSLog(@"posting bodydata to url[%@]", url);
        NSMutableURLRequest *mutableRequest = [manager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
        mutableRequest.HTTPBody = [[AppData EncryptPostBodyParam:bodyParam] dataUsingEncoding:manager.requestSerializer.stringEncoding];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:mutableRequest success:success failure:failed];
        [manager.operationQueue addOperation:operation];
    }
}

@end
