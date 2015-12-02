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

#pragma mark - 最常用的GET和POST

+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             modelName:(Class)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    NSString *url = kResPathAppBaseUrl;
    [self getDataFromUrl:url withAPI:apiName andDictParam:dictParam modelName:modelName requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
              modelName:(Class)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure {
    NSString *url = kResPathAppBaseUrl;
    [self postDataToUrl:url withAPI:apiName andDictParam:dictParam modelName:modelName requestSuccessed:requestSuccessed requestFailure:requestFailure];
}


#pragma mark - 自定义url前缀的GET和POST

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
             modelName:(Class)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil modelName:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
         andDictParam:(NSDictionary *)dictParam
            modelName:(Class)modelName
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil modelName:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}


#pragma mark - 通用的GET和POST（只返回BaseModel的Data内容）

/**
 *  发起get & post网络请求
 *
 *  @param url              接口前缀 最后的'/'可有可无
 *  @param apiName          方法名称 前面不能有'/'
 *  @param arrayParam       数组参数，用来组装url/param1/param2/param3，参数的顺序很重要
 *  @param dictParam        字典参数，key-value
 *  @param modelName        模型名称字符串
 *  @param requestType      RequestTypeGET 和 RequestTypePOST
 *  @param requestSuccessed 请求成功的回调
 *  @param requestFailure   请求失败的回调
 */
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           modelName:(Class)modelName
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    [self   requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam imageData:nil customModelClass:[YSCBaseModel class] requestType:requestType
	    requestSuccessed: ^(id responseObject) {
            YSCBaseModel *baseModel = (YSCBaseModel *)responseObject;
            [baseModel formatProperties];
            if (1 == baseModel.stateInteger) {  //接口访问成功
                NSObject *dataModel = baseModel.data;
                JSONModelError *initError = nil;
                if ( [NSObject isNotEmpty:modelName] && [modelName isSubclassOfClass:[BaseDataModel class]]) {
                    if ([dataModel isKindOfClass:[NSArray class]]) {
                        dataModel = [modelName arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                    }
                    else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                        dataModel = [[modelName alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                    }
                }
                
                //针对转换映射后的处理
                if (isEmpty(initError)) {
                    if (requestSuccessed) {
                        requestSuccessed(dataModel);//注意：这里dataModel为nil也让它返回
                    }
                }
                else {
                    if (requestFailure) {
                        requestFailure(ErrorTypeDataMappingFailed, initError);
                    }
                }
            }
            else {
                if (99 == baseModel.stateInteger) {//登录过期
                    NSDictionary *param = @{kParamUserId : USERID, kParamMessage : Trim(baseModel.message)};
                    postNWithInfo(kNotificationLoginExpired, param);
                }
                if (requestFailure) {
                    requestFailure(ErrorTypeInternalServer, CreateNSErrorCode(baseModel.stateInteger, baseModel.message));
                }
            }
        } requestFailure:requestFailure];
}


#pragma mark - 上传文件

+ (void)uploadImage:(UIImage *)image
              toUrl:(NSString *)url
            withApi:(NSString *)apiName
       andDictParam:(NSDictionary *)dictParam
       imageQuality:(ImageQuality)quality
   requestSuccessed:(RequestSuccessed)requestSuccessed
     requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url
               withAPI:apiName
         andArrayParam:nil
          andDictParam:dictParam
          andBodyParam:nil
             imageData:UIImagePNGRepresentation(image)
      customModelClass:[YSCBaseModel class]
           requestType:RequestTypeUploadFile
      requestSuccessed:^(id responseObject) {
          YSCBaseModel *baseModel = (YSCBaseModel *)responseObject;
          [baseModel formatProperties];
          if ([baseModel isKindOfClass:[YSCBaseModel class]]) {
              if (1 == baseModel.stateInteger) {  //接口访问成功
                  if (requestSuccessed) {
                      requestSuccessed(baseModel);
                  }
              }
              else {
                  if (99 == baseModel.stateInteger) {//登录过期
                      NSDictionary *param = @{kParamUserId : USERID, kParamMessage : Trim(baseModel.message)};
                      postNWithInfo(kNotificationLoginExpired, param);
                  }
                  if (requestFailure) {
                      requestFailure(ErrorTypeInternalServer, CreateNSErrorCode(baseModel.stateInteger, baseModel.message));
                  }
              }
          }
          else {
              if (requestFailure) {
                  requestFailure(ErrorTypeDataMappingFailed, CreateNSError(@"数据映射出错"));
              }
          }
          
      } requestFailure:^(ErrorType errorType, NSError *error) {
          if (requestFailure) {
              requestFailure(errorType, error);
          }
      }];
}

#pragma mark - 通用的GET和POST（返回JSONModel的所有内容）

+ (void)getDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
      customModelClass:(Class)modelClass
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
     [self requestByUrl:kResPathAppBaseUrl withAPI:apiName andDictParam:dictParam customModelClass:modelClass requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)postDataWithAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
      customModelClass:(Class)modelClass
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:kResPathAppBaseUrl withAPI:apiName andDictParam:dictParam customModelClass:modelClass requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
          andDictParam:(NSDictionary *)dictParam
      customModelClass:(Class)modelClass
           requestType:(RequestType)requestType
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil imageData:nil customModelClass:modelClass requestType:requestType requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

/**
 *  发起get & post & 上传图片 请求
 *
 *  @param url              接口前缀 最后的'/'可有可无
 *  @param apiName          方法名称 前面不能有'/'
 *  @param arrayParam       数组参数，用来组装url/param1/param2/param3，参数的顺序很重要
 *  @param dictParam        字典参数，key-value
 *  @param imageData        图片资源
 *  @param requestType      RequestTypeGET 和 RequestTypePOST
 *  @param requestSuccessed 请求成功的回调
 *  @param requestFailure   请求失败的回调
 */
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
    customModelClass:(Class)modelClass
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    if (NO == [ReachabilityManager sharedInstance].reachable) {
        requestFailure(ErrorTypeDisconnected, CreateNSError(@"网络断开"));
        return;
    }
    
	//1. url合法性判断
	if (NO == [NSString isUrl:url]) {
		requestFailure(ErrorTypeURLInvalid, CreateNSError(@"url不合法"));
		return;
	}
    
    //2. 组装完整的url地址(去掉url最后的'/'字符,去掉apiName前面的'/'字符     )
    NSString *urlString = [[NSString replaceString:url byRegex:@"/+$" to:@""] stringByAppendingFormat:@"/%@",
                           [NSString replaceString:apiName byRegex:@"^/+" to:@""]];
    
	//3. 组装数组参数
	NSMutableString *newUrlString = [NSMutableString stringWithString:urlString];
	for (NSObject *param in arrayParam) {
		[newUrlString appendFormat:@"/%@",param];
	}
    
    //4. 格式化所有请求的参数
    NSDictionary *newDictParam = [AppData FormatRequestParams:dictParam];
    NSLog(@"request params=%@", newDictParam);
    
	//5. 发起网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = kDefaultAFNTimeOut;//设置POST和GET的超时时间
    //解决返回的Content-Type始终是application/xml问题！
    [manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];//TODO:压缩上传内容
    [manager.requestSerializer setValue:AppVersion forHTTPHeaderField:kParamVersion];
    [manager.requestSerializer setValue:kParamFromValue forHTTPHeaderField:kParamFrom];
    [manager.requestSerializer setValue:[AppData SignatureWithParams:newDictParam] forHTTPHeaderField:kParamSignature];
    [manager.requestSerializer setValue:[AppData EncryptHttpHeaderToken] forHTTPHeaderField:kAppHTTPTokenName];
    
    //   定义返回成功的block
    void (^requestSuccessed1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        //如果返回的数据是编过码的，则需要转换成字符串，方便输出调试
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        if ([responseObject isKindOfClass:[NSString class]]) {
            responseObject = [NSString replaceString:responseObject byRegex:@"[\r\n\t]" to:@""];
        }
        NSLog(@"request success! \r\noperation=%@\r\nresponseObject=%@", operation, responseObject);
        JSONModelError *initError = nil;
        id jsonModel = nil;
        if ([NSObject isNotEmpty:modelClass] && [modelClass isSubclassOfClass:[JSONModel class]]) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                jsonModel = [[modelClass alloc] initWithDictionary:responseObject error:&initError];
            }
            else if ([responseObject isKindOfClass:[NSString class]]) {
                jsonModel = [[modelClass alloc] initWithString:responseObject error:&initError];
            }
        }
        
        if (isEmpty(initError)) {
            if (requestSuccessed) {
                requestSuccessed(jsonModel);
            }
        }
        else {
            if (requestFailure) {
                requestFailure(ErrorTypeDataMappingFailed, initError);
            }
        }
    };
    //   定义返回失败的block
    void (^requestFailure1)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [YSCCommonUtils SaveNSError:error];//自动记录错误日志
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
    //   定义post的加密回调
    //    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
    //        NSMutableArray *mutablePairs = [NSMutableArray array];
    //        for (AFQueryStringPair *pair in AFQueryStringPairsFromDictionary(parameters)) {
    //            [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    //        }
    //
    //        return [mutablePairs componentsJoinedByString:@"&"];
    //    }];
	if (RequestTypeGET == requestType) {
		NSLog(@"getting data from url[%@]", newUrlString);
		[manager   GET:newUrlString
		    parameters:newDictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypePOST == requestType) {
        NSLog(@"posting data to url[%@]", newUrlString);
		[manager  POST:newUrlString
		    parameters:newDictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypeUploadFile == requestType) {
        NSLog(@"uploading data to url[%@]", newUrlString);
		[manager       POST:newUrlString
                 parameters:newDictParam
  constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
      if (imageData) {
          [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"application/octet-stream"];
      }
  }
                    success:requestSuccessed1
                    failure:requestFailure1];
	}
    else if (RequestTypePostBodyData == requestType) {
        NSLog(@"posting bodydata to url[%@]", newUrlString);
        NSMutableURLRequest *mutableRequest = [manager.requestSerializer requestWithMethod:@"POST" URLString:newUrlString parameters:nil error:nil];
        mutableRequest.HTTPBody = [bodyParam dataUsingEncoding:manager.requestSerializer.stringEncoding];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:mutableRequest success:requestSuccessed1 failure:requestFailure1];
        [manager.operationQueue addOperation:operation];
    }
}

+ (void)downloadFileFromUrl:(NSString *)url
                 saveToPath:(NSString *)destPath
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *fileName = [NSString stringWithFormat:@"%@.tempfile", [[NSUUID UUID] UUIDString]];
    NSString *downloadToFilePath = [[YSCFileUtils DirectoryPathOfDocuments] stringByAppendingPathComponent:fileName];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:fileName];//放在临时目录里的文件
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            if (error) {
                if (requestFailure) {
                    requestFailure(ErrorTypeConnectionFailed, error);
                }
            }
            else {
                BOOL isSuccess = [YSCFileUtils copyFileFromPath:downloadToFilePath toPath:destPath];
                if (isSuccess) {
                    [YSCFileUtils deleteFileOrDirectory:downloadToFilePath];
                    if (requestSuccessed) {
                        requestSuccessed(@"下载成功");
                    }
                }
                else {
                    if (requestFailure) {
                        requestFailure(ErrorTypeCopyFileFailed, CreateNSError(@"复制文件出错"));
                    }
                }
            }
        }];
        [downloadTask resume];
}

@end
