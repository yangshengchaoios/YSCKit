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
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil modelName:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postDataWithAPI:(NSString *)apiName
           andDictParam:(NSDictionary *)dictParam
              modelName:(Class)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathAppBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:nil modelName:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postBodyDataWithAPI:(NSString *)apiName
               andDictParam:(NSDictionary *)dictParam
               andBodyParam:(NSString *)bodyParam
                  modelName:(Class)modelName
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathAppBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:bodyParam modelName:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
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

+ (void)postBodyDataToUrl:(NSString *)url
                  withAPI:(NSString *)apiName
             andDictParam:(NSDictionary *)dictParam
             andBodyParam:(NSString *)bodyParam
                modelName:(Class)modelName
         requestSuccessed:(RequestSuccessed)requestSuccessed
           requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:nil andDictParam:dictParam andBodyParam:bodyParam modelName:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
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
    [self   requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam imageData:nil requestType:requestType
	    requestSuccessed: ^(id responseObject) {
            BaseModel *baseModel = (BaseModel *)responseObject;
            if (1 == baseModel.state) {  //接口访问成功
                NSObject *dataModel = baseModel.data;
                JSONModelError *initError = nil;
                if ( [NSString isNotEmpty:modelName] && [modelName isSubclassOfClass:[BaseDataModel class]]) {
                    if ([dataModel isKindOfClass:[NSArray class]]) {
                        dataModel = [modelName arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                    }
                    else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                        dataModel = [[modelName alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                    }
                }
                
                //针对转换映射后的处理
                if (initError) {
                    requestFailure(1101, initError.localizedDescription);
                }
                else {
                    requestSuccessed(dataModel);//注意：这里dataModel为nil也让它返回
                }
            }
//            else if (2 == baseModel.State) {//扩展
//            
//            }
            else {
                NSLog(@"message=%@", baseModel.message);
                requestFailure(1103, baseModel.message);
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
    //TODO:resize
    [self requestByUrl:url
               withAPI:apiName
         andArrayParam:nil
          andDictParam:dictParam
          andBodyParam:nil
             imageData:UIImagePNGRepresentation(image)
           requestType:RequestTypeUploadFile
      requestSuccessed:^(id responseObject) {
          BaseModel *baseModel = (BaseModel *)responseObject;
          if ([baseModel isKindOfClass:[BaseModel class]]) {
              if (1 == baseModel.state) {  //接口访问成功
                  NSLog(@"success message = %@", baseModel.message);
                  requestSuccessed(baseModel);
              }
              else {
                  requestFailure(1101, baseModel.message);
              }
          }
          else {
              requestFailure(1102, @"本地数据映射错误！");
          }
          
      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
          requestFailure(1103, errorMessage);
      }];
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
    
    //2. 组装完整的url地址(去掉url最后的'/'字符,去掉apiName前面的'/'字符     )
    NSString *urlString = [[NSString replaceString:url byRegex:@"/+$" to:@""] stringByAppendingFormat:@"/%@",
                           [NSString replaceString:apiName byRegex:@"^/+" to:@""]];
    
	//3. 组装数组参数
	NSMutableString *newUrlString = [NSMutableString stringWithString:urlString];
	for (NSObject *param in arrayParam) {
		[newUrlString appendString:@"/"];
		[newUrlString appendFormat:@"%@",param];
	}
    
    //4. 对提交的dict添加一个加密的参数'signature'
    NSMutableDictionary *newDictParam = [NSMutableDictionary dictionaryWithDictionary:dictParam];
#if IsNeedSignParams
    NSString *signature = [self signatureWithParam:newDictParam];
    if ([NSString isNotEmpty:signature]) {//当加密字符串不为空的时候就新增一个参数'signature'
        [newDictParam setValue:signature forKey:kParamSignature];
    }
#endif
    
	//5. 发起网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];   //create new AFHTTPRequestOperationManager
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//TODO:针对返回数据不规范的情况
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = kDefaultAFNTimeOut;//设置POST和GET的超时时间
    //解决返回的Content-Type始终是application/xml问题！
    [manager.requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:kParamVersionValue forHTTPHeaderField:kParamVersion];
    [manager.requestSerializer setValue:@"default udid of ios" forHTTPHeaderField:kParamUdid];
    [manager.requestSerializer setValue:kParamFromValue forHTTPHeaderField:kParamFrom];
    
    //   定义返回成功的block
    void (^requestSuccessed1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        //如果返回的数据是编过码的，则需要转换成字符串，方便输出调试
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        NSLog(@"request success! \r\noperation=%@\r\nresponseObject=%@", operation, responseObject);
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
    void (^requestFailure1)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request failed! \r\noperation=%@\r\nerror=%@", operation, error);
        if (200 != operation.response.statusCode) {
            [LogManager saveLog:[NSString stringWithFormat:@"请求参数%@", newDictParam]];
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
    
	NSLog(@"requestType = %ld, newDictParam = %@", requestType, newDictParam);
	if (RequestTypeGET == requestType) {
		NSLog(@"getting data...");
		[manager   GET:newUrlString
		    parameters:newDictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypePOST == requestType) {
		NSLog(@"posting data...");
		[manager  POST:newUrlString
		    parameters:newDictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (RequestTypeUploadFile == requestType) {
		NSLog(@"uploading data...");
        
		[manager       POST:newUrlString
                 parameters:newDictParam
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

/**
 *  对参数进行签名
 *
 *  @param param oldDict
 *
 *  @return signature
 */
+ (NSString *)signatureWithParam:(NSMutableDictionary *)param {
//    //1. 默认参数:version, udid, from
//    if ([NSString isEmpty:param[kParamVersion]]) {
//        [param setValue:kParamVersionValue forKey:kParamVersion];
//    }
//    if ([NSString isEmpty:param[kParamUdid]]) {
//        [param setValue:@"default udid of ios" forKey:kParamUdid];//TODO:获取设备唯一编号
//    }
//    if ([NSString isEmpty:param[kParamFrom]]) {
//        [param setValue:kParamFromValue forKey:kParamFrom];
//    }
    
    NSArray *keys = [[param allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    //2. 按照字典顺序拼接url字符串
    NSLog(@"param = %@", param);
    NSMutableString *joinedString = [NSMutableString string];
    for (NSString *key in keys) {
        NSObject *value = param[key];
        if ([kParamSignature isEqualToString:key]) {//不对signature进行加密
            continue;
        }
        //去掉key和value的前后空格字符
        NSString *newKey = [NSString trimString:key];
        NSString *newValue = [NSString stringWithFormat:@"%@", [NSObject isEmpty:value] ? @"" : value];
        NSString *newUTF8Value = [NSString UTF8Encoded:[NSString trimString:newValue]];
        //对value进行UTF8编码
        [joinedString appendFormat:@"%@=%@", newKey, newUTF8Value];
//        [param setValue:newUTF8Value forKey:newKey];
    }
    
    //3. 对参数进行md5加密
    NSString *newString = [NSString stringWithFormat:@"%@%@", joinedString, kParamSecretKey];
    NSLog(@"newString = %@", newString);
    return [[NSString MD5Encrypt:newString] lowercaseString];
}

@end
