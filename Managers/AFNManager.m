//
//  AFNManager.m
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "AFNManager.h"
#import "AFNetworking.h"
#import <UIImage+Resize.h>

@implementation AFNManager

#pragma mark - 最常用的GET和POST

+ (void)getDataWithAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathAppBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postDataWithAPI:(NSString *)apiName
          andArrayParam:(NSArray *)arrayParam
           andDictParam:(NSDictionary *)dictParam
              dataModel:(NSString *)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathAppBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postBodyDataWithAPI:(NSString *)apiName
              andArrayParam:(NSArray *)arrayParam
               andDictParam:(NSDictionary *)dictParam
               andBodyParam:(NSString *)bodyParam
                  dataModel:(NSString *)modelName
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathAppBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam dataModel:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

#pragma mark - 自定义url前缀的GET和POST

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
	[self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
        andArrayParam:(NSArray *)arrayParam
         andDictParam:(NSDictionary *)dictParam
            dataModel:(NSString *)modelName
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postBodyDataToUrl:(NSString *)url
                  withAPI:(NSString *)apiName
            andArrayParam:(NSArray *)arrayParam
             andDictParam:(NSDictionary *)dictParam
             andBodyParam:(NSString *)bodyParam
                dataModel:(NSString *)modelName
         requestSuccessed:(RequestSuccessed)requestSuccessed
           requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam dataModel:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

#pragma mark - 上传文件

+ (void)uploadImage:(UIImage *)image
              toUrl:(NSString *)url
            withApi:(NSString *)apiName
      andArrayParam:(NSArray *)arrayParam
       andDictParam:(NSDictionary *)dictParam
          dataModel:(NSString *)modelName
       imageQuality:(ImageQuality)quality
   requestSuccessed:(RequestSuccessed)requestSuccessed
     requestFailure:(RequestFailure)requestFailure {
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *picturePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.jpg", timestamp]];
    UIImage *scaledImage1 = [ImageUtils adjustImage:image toQuality:quality];
    UIImage *scaledImage = [scaledImage1 resizedImage:CGSizeMake(76, 76) interpolationQuality:kCGInterpolationDefault];
    
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil imageData:UIImagePNGRepresentation(scaledImage)
           requestType:RequestTypeUploadFile
      requestSuccessed:^(id responseObject) {
          [[NSFileManager defaultManager] removeItemAtPath:picturePath error:NULL];
          BaseModel *baseModel = (BaseModel *)responseObject;
          if ([baseModel isKindOfClass:NSClassFromString(modelName)]) {
              if (1 == baseModel.State) {  //接口访问成功
                  NSLog(@"success message = %@", baseModel.Message);
                  requestSuccessed(baseModel);
              }
              else {
                  requestFailure(1101, baseModel.Message);
              }
          }
          else {
              requestFailure(1102, @"本地数据映射错误！");
          }
          
      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
          [[NSFileManager defaultManager] removeItemAtPath:picturePath error:NULL];
          requestFailure(1103, errorMessage);
      }];
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
           dataModel:(NSString *)modelName
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    [self   requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam imageData:nil requestType:requestType
	    requestSuccessed: ^(id responseObject) {
            BaseModel *baseModel = (BaseModel *)responseObject;
            if (1 == baseModel.State) {  //接口访问成功
                NSObject *dataModel = baseModel.Data;
                JSONModelError *initError = nil;
                if ([dataModel isKindOfClass:[NSArray class]]) {
                    if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[BaseDataModel class]]) {
                        dataModel = [NSClassFromString(modelName) arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                    }
                }
                else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                    if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[BaseDataModel class]]) {
                        dataModel = [[NSClassFromString(modelName) alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                    }
                }
                
                //针对转换映射后的处理
                if (initError) {
                    requestFailure(1101, initError.localizedDescription);
                }
                else {
                    requestSuccessed(dataModel);//这里dataModel可能为nil
                }
            }
//            else if (2 == baseModel.State) {//保存扩展
//            
//            }
            else {
                requestFailure(1103, baseModel.Message);
            }
        } requestFailure:requestFailure];
}


#pragma mark - 通用的GET和POST（返回BaseModel的所有内容）

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
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
	//1. url合法性判断
	if (![NSString isUrl:url]) {
		requestFailure(1005, [NSString stringWithFormat:@"传递的url[%@]不合法！", url]);
		return;
	}
    
	//2. apiName简单判断
    apiName = [NSString trimString:apiName];
    
	//3. 组装完整的url地址
	NSString *urlString = [url stringByAppendingFormat:@"%@%@",
	                       ([url hasSuffix:@"/"] ? @"" : @"/"),
	                       ([apiName hasPrefix:@"/"] ? [apiName substringFromIndex:1] : apiName)
                           ];                                                         //组装后的完整url地址
    
	//4. 组装数组参数
	NSMutableString *newUrlString = [NSMutableString stringWithString:urlString];
	for (NSObject *param in arrayParam) {
		[newUrlString appendString:@"/"];
		[newUrlString appendFormat:@"%@",param];
	}
    
	//5. 发起网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];   //create new AFHTTPRequestOperationManager
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = 15.0f;//设置POST和GET的超时时间
    [manager.requestSerializer setValue:kDefaultAppType forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:[[Login sharedInstance] authorization] forHTTPHeaderField:@"Authorization"];
    //解决返回的Content-Type始终是application/xml问题！
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //   定义返回成功的block
    void (^requestSuccessed1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"get success! operation = %@\r\nresponseObject = %@", operation, responseObject);
        
        JSONModelError *initError;
        BaseModel *baseModel = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            baseModel = [[BaseModel alloc] initWithDictionary:responseObject error:&initError];
        }
        else if ([responseObject isKindOfClass:[NSString class]]) {
            baseModel = [[BaseModel alloc] initWithString:responseObject error:&initError];
        }
        
        if ([NSObject isNotEmpty:baseModel]) {
            requestSuccessed(baseModel);
        }
        else {
            if (initError) {
                requestFailure(1001, initError.localizedDescription);
            }
            else {
                requestFailure(1002, @"本地对象映射出错！");
            }
        }
    };
    //   定义返回失败的block
    void (^requestFailure1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"post failure! operation = %@\r\nerror = %@", operation, error);
        
        if (200 != operation.response.statusCode) {
            [LogManager saveLog:[NSString stringWithFormat:@"请求参数%@", dictParam]];
            [LogManager saveLog:error.localizedDescription];
            if (401 == operation.response.statusCode) {
                requestFailure(1003, @"您还未登录呢！");
                [[Login sharedInstance] clearLoginData];
            }
            else {
                requestFailure(1004, @"网络错误！");
            }
        }
        else {
            requestFailure(operation.response.statusCode, error.localizedDescription);
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
    
	NSLog(@"requestType = %d, dictParam = %@", requestType, dictParam);
	if (RequestTypeGET == requestType) {
		NSLog(@"getting data...");
		[manager   GET:newUrlString
		    parameters:dictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypePOST == requestType) {
		NSLog(@"posting data...");
		[manager  POST:newUrlString
		    parameters:dictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypeUploadFile == requestType) {
		NSLog(@"uploading data...");
        
		[manager       POST:newUrlString
                 parameters:dictParam
  constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
      [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"application/octet-stream"];
  }
                    success:requestSuccessed1
                    failure:requestFailure1];
	}
    else if (RequestTypePostBodyData == requestType) {
        NSLog(@"posting bodydata...");
        NSMutableURLRequest *mutableRequest = [manager.requestSerializer requestWithMethod:@"POST" URLString:newUrlString parameters:nil error:nil];
        mutableRequest.HTTPBody = [bodyParam dataUsingEncoding:manager.requestSerializer.stringEncoding];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:mutableRequest success:requestSuccessed1 failure:requestFailure1];
        [manager.operationQueue addOperation:operation];
    }
}
@end
