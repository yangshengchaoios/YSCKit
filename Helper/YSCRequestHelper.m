//
//  YSCRequestHelper.m
//  KanPian
//
//  Created by 杨胜超 on 16/3/26.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import "YSCRequestHelper.h"
#import "AFNetworking.h"

@implementation YSCRequestHelper

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}
- (id)init {
    self = [super init];
    if (self) {
        self.requestQueue = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)removeRequestById:(NSString *)requestId {
    NSURLSessionTask *task = self.requestQueue[requestId];
    if (NSURLSessionTaskStateRunning == task.state) {
        [task cancel];
    }
    [self.requestQueue removeObjectForKey:requestId];
}
- (void)removeAllRequests {
    for (NSString *requestId in self.requestQueue) {
        NSURLSessionTask *task = self.requestQueue[requestId];
        if (NSURLSessionTaskStateRunning == task.state) {
            [task cancel];
        }
    }
    [self.requestQueue removeAllObjects];
}

// 解析错误信息
- (NSString *)resolveYSCErrorType:(NSString *)errorType andError:(NSError *)error {
    NSMutableString *errMsg = [NSMutableString stringWithString:@"\r>>>>>>>>>>>>>>>>>>>>ErrorType[0]>>>>>>>>>>>>>>>>>>>>\r"];//错误标记开始
    NSString *messageTitle = @"提示";
    NSString *messageDetail = errorType;
    if (OBJECT_IS_EMPTY(messageDetail)) {
        messageDetail = error.userInfo[NSLocalizedDescriptionKey];
    }
    if (OBJECT_IS_EMPTY(messageDetail)) {
        messageDetail = @"未知错误";
    }
    
    //继续组织错误日志
    [errMsg appendFormat:@"  messageTitle:%@\r  messageDetail:%@\r", messageTitle, messageDetail];//显示解析后的错误提示
    if (error) {
        [errMsg appendFormat:@"  errorCode:%ld\r  errorMessage:%@\r", (long)error.code, error];//显示error的错误内容
    }
    [errMsg appendString:@"<<<<<<<<<<<<<<<<<<<<ErrorType[0]<<<<<<<<<<<<<<<<<<<<\r\n"];//错误标记结束
    NSLog(@"error message=%@", errMsg);
    return messageDetail;
}

// 常用网络请求方法
- (NSString *)requestWithApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed {
    return [self requestFromUrl:kPathAppBaseUrl withApi:apiName params:params dataModel:dataModel type:type success:success failed:failed];
}
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed {
    return [self requestFromUrl:url withApi:apiName params:params dataModel:dataModel imageData:nil type:type success:success failed:failed];
}

// 处理YSCDataModel映射、登陆过期
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed {
    return [self requestFromUrl:url withApi:apiName params:params customModel:[YSCBaseModel class] imageData:imageData type:type success:^(id responseObject) {
        YSCBaseModel *baseModel = responseObject;
        if (baseModel && [baseModel isKindOfClass:[YSCBaseModel class]]) {
            if ([baseModel checkRequestIsSuccess]) {//接口访问成功，开始解析data模型
                NSObject *dataObject = baseModel.data;
                if (dataObject && dataModel && [[dataModel class] respondsToSelector:@selector(objectWithKeyValues:)]) {
                    dataObject = [dataModel objectWithKeyValues:dataObject];
                    if (dataObject) {//将成功映射后的data模型往上层抛
                        if (success) {
                            success(dataObject);
                        }
                    }
                    else {
                        if (failed) {
                            failed(YSCErrorTypeDataMappingFailed, nil);
                        }
                    }
                }
                else {
                    if (success) {
                        success(dataObject);
                    }
                }
            }
            else {
                [baseModel postNotificationWhenLoginExpired];
                if (failed) {
                    NSInteger state = baseModel.state;
                    NSString *message = TRIM_STRING(baseModel.message);
                    failed(YSCErrorTypeInternalServer, CREATE_NSERROR_WITH_Code(state, message));
                }
            }
        }
        else {
            if (failed) {
                failed(YSCErrorTypeDataMappingFailed, nil);
            }
        }
    } failed:failed];
}

// 处理自定义模型的映射，将映射好的自定义模型往上层抛
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                 customModel:(Class)customModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed {
    return [self requestFromUrl:url withApi:apiName params:params imageData:imageData type:type success:^(id responseObject) {
        NSObject *model = responseObject;
        if (customModel && [[customModel class] respondsToSelector:@selector(objectWithKeyValues:)]) {
            model = [customModel objectWithKeyValues:responseObject];
            if (model) {//将成功映射后的data模型往上层抛
                if (success) {
                    success(model);
                }
            }
            else {
                if (failed) {
                    failed(YSCErrorTypeDataMappingFailed, nil);
                }
            }
        }
        else {
            if (success) {
                success(model);
            }
        }
    } failed:failed];
}

// 通用的GET、POST和上传图片（返回最原始的未经过任何映射的JSON字符串）
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)requestType
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed {
    //0. url组装、判断网络状态、判断url合法性
    if (NO == YSCDataInstance.isReachable) {
        if (failed) {
            failed(YSCErrorTypeDisconnected, nil);
        }
        return @"";
    }
    url = [self _formatRequestUrl:url withApi:apiName];
    if (NO == [NSString isUrl:url]) {
        if (failed) {
            failed(YSCErrorTypeURLInvalid, nil);
        }
        return @"";
    }
    NSString *requestId = [self _createRequestIdByUrl:url withApi:apiName params:params type:requestType];
    // 自动处理重复请求
    
    if (self.requestQueue[requestId]) {
        #if kIsAutoRefuseWhenRequesting
        NSLog(@"The same requstId[%@] is still running!\rurl:%@\rapi:%@\rparams:%@\rtype:%ld",
              requestId, url, apiName, params, requestType);
        if (failed) {
            failed(YSCErrorTypeRequesting, nil);
        }
        return @"";
        #else
        [self removeRequestById:requestId];//自定停止之前的相同网络请求
        #endif
    }
    NSDictionary *formatedParams = [self _formatRequestParams:params withApi:apiName andUrl:url];//格式化所有请求的参数
    
    //1. 组装manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", @"audio/wav", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = kDefaultRequestTimeOut;
//    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];//TODO:压缩上传内容
    #if kIsUseHttpHeaderSignature
    [manager.requestSerializer setValue:[self _signatureParams:formatedParams] forHTTPHeaderField:kParamSignature];
    #endif
    
    #if kIsUseHttpHeaderToken
    [manager.requestSerializer setValue:[self _httpToken] forHTTPHeaderField:kParamHttpToken];
    #endif
    
    //2. 配置网络请求参数
    NSMutableURLRequest *mutableRequest = nil;
    NSError *serializationError = nil;
    if (YSCRequestTypeGET == requestType) {
        NSLog(@"getting data from url:\r%@?%@", url, [self _queryRequestParams:formatedParams]);
        mutableRequest = [manager.requestSerializer requestWithMethod:@"GET"
                                                            URLString:url
                                                           parameters:formatedParams
                                                                error:&serializationError];
    }
    else if (YSCRequestTypePOST == requestType) {
        NSLog(@"posting data to url:\r%@", url);
        mutableRequest = [manager.requestSerializer requestWithMethod:@"POST"
                                                            URLString:url
                                                           parameters:formatedParams
                                                                error:&serializationError];
    }
    else if (YSCRequestTypeUploadFile == requestType) {
        NSLog(@"uploading data to url:\r%@", url);
        mutableRequest = [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                         URLString:url
                                                                        parameters:formatedParams
                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"fileName" mimeType:@"application/octet-stream"];
        }
                                                                             error:&serializationError];
    }
    else if (YSCRequestTypePostBodyData == requestType) {
        NSLog(@"posting bodydata to url:\r%@", url);
        NSString *bodyParam = [NSString jsonStringWithObject:formatedParams];
        bodyParam = [self _encryptPostBodyParam:bodyParam];
        mutableRequest = [manager.requestSerializer requestWithMethod:@"POST"
                                                            URLString:url
                                                           parameters:formatedParams
                                                                error:&serializationError];
        mutableRequest.HTTPBody = [bodyParam dataUsingEncoding:manager.requestSerializer.stringEncoding];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    //3. 创建网络请求出错
    if (serializationError) {
        if (failed) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(manager.completionQueue ?: dispatch_get_main_queue(), ^{
                failed(YSCErrorTypeRequesFailed, serializationError);
            });
#pragma clang diagnostic pop
        }
        return @"";
    }
    
    //4. 开始网络请求并返回requestId
    if (mutableRequest) {
        @weakiy(self)
        NSURLSessionTask *task = [manager dataTaskWithRequest:mutableRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [weak_self.requestQueue removeObjectForKey:requestId];//移除网络请求
            if (error) {
                if (200 != ((NSHTTPURLResponse *)response).statusCode) {
                    if (failed) {
                        failed(YSCErrorTypeServerFailed, error);
                    }
                }
                else {
                    if (failed) {
                        failed(YSCErrorTypeConnectionFailed, error);
                    }
                }
            }
            else {
                NSString *resolvedString = [weak_self _resolveResponseObject:responseObject];
                if ([resolvedString length] > 0) {
                    if (success) {
                        success(resolvedString);
                    }
                }
                else {
                    if (failed) {
                        failed(YSCErrorTypeReturnEmptyData, nil);
                    }
                }
            }
        }];
        [task resume];
        self.requestQueue[requestId] = task;//加入网络请求队列
        return requestId;
    }
    else {
        return @"";
    }
}


#pragma mark - private methods
// 格式化请求的url地址
- (NSString *)_formatRequestUrl:(NSString *)url withApi:(NSString *)apiName {
    NSString *tempApiName = [@"/" stringByAppendingPathComponent:apiName];//组装完整的url地址
    return [url stringByAppendingString:tempApiName];
}
// 格式化请求参数
- (NSDictionary *)_formatRequestParams:(NSDictionary *)params
                               withApi:(NSString *)apiName
                                andUrl:(NSString *)url {
    NSMutableDictionary *newDictParam = [NSMutableDictionary dictionary];
    for (NSString *key in params.allKeys) {
        NSObject *value = params[key];
        NSString *newKey = TRIM_STRING(key);
        NSString *newValue = [NSString stringWithFormat:@"%@", OBJECT_IS_EMPTY(value) ? @"" : value];
        newDictParam[newKey] = TRIM_STRING(newValue);
    }
    NSLog(@"request params:\r%@", newDictParam);
    return newDictParam;
}
// 计算请求参数的签名
- (NSString *)_signatureParams:(NSDictionary *)params {
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    //0. 按照字典顺序拼接url字符串
    NSMutableString *joinedString = [NSMutableString string];
    for (NSString *key in keys) {
        if ([kParamSignature isEqualToString:key]) {//不对signature进行加密(如果有的话)
            continue;
        }
        [joinedString appendFormat:@"%@%@", TRIM_STRING(key), TRIM_STRING(params[key])];
    }
    
    //1. 对参数进行md5加密
    NSString *newString = [NSString stringWithFormat:@"%@%@", joinedString, TRIM_STRING(self.signatureSecretKey)];
    NSString *signature = [[NSString MD5Encrypt:newString] lowercaseString];
    return signature;
}
// 将请求参数拼接成url字符串
- (NSString *)_queryRequestParams:(NSDictionary *)params {
    return AFQueryStringFromParameters(params);
}
// 计算httpToken参数值
- (NSString *)_httpToken {
    NSDictionary *param = @{kParamAppId : APP_BUNDLE_IDENTIFIER,
                            kParamAppVersion : APP_VERSION,
                            kParamAppChannel : APP_CHANNEL,
                            kParamFrom : @"1",//1-ios 2-android 3-wap
                            kParamLoginToken : LOGIN_TOKEN,
                            kParamLongitude : [NSString stringWithFormat:@"%f", YSCDataInstance.currentLongitude],
                            kParamLatitude : [NSString stringWithFormat:@"%f", YSCDataInstance.currentLatitude],
                            kParamUdid : YSCDataInstance.udid,
                            kParamDeviceToken : YSCDataInstance.deviceToken
                            };
    NSLog(@"httpToken param=\r%@", param);
    NSString *httpToken = [NSString jsonStringWithObject:param];
    if (OBJECT_ISNOT_EMPTY(self.httpTokenSecretKey)) {
        httpToken = [NSString DESEncrypt:httpToken byKey:self.httpTokenSecretKey];
    }
    NSLog(@"httpToken string=\r%@", httpToken);
    return httpToken;
}
// 计算post body的参数值
- (NSString *)_encryptPostBodyParam:(NSString *)bodyParam {
    NSLog(@"post body params=\r%@", bodyParam);
    if (OBJECT_ISNOT_EMPTY(self.requestSecretKey)) {
        return [NSString DESEncrypt:bodyParam byKey:self.requestSecretKey];
    }
    else {
        return bodyParam;
    }
}
// 解析返回结果并格式化输出
- (NSString *)_resolveResponseObject:(id)responseObject {
    NSString *resolvedString = @"";
    if ([responseObject isKindOfClass:[NSData class]]) {
        resolvedString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    }
    else if ([responseObject isKindOfClass:[NSDictionary class]] ||
             [responseObject isKindOfClass:[NSArray class]]) {
        resolvedString = [NSString jsonStringWithObject:responseObject];
    }
    
    if (OBJECT_ISNOT_EMPTY(resolvedString) &&
        OBJECT_ISNOT_EMPTY(self.requestSecretKey) &&
        NO == [resolvedString isContains:@"{"]) {//这里兼容了返回内容没有加密的情况
        resolvedString = [NSString DESDecrypt:resolvedString byKey:self.requestSecretKey];
    }
    NSString *formatedJsonString = [YSCFormatManager formatPrintJsonStringOnConsole:resolvedString];
    formatedJsonString = OBJECT_IS_EMPTY(formatedJsonString) ? resolvedString : formatedJsonString;
    NSLog(@"resolvedString=\r%@", formatedJsonString);
    return resolvedString;
}
// 计算请求任务的唯一编号
- (NSString *)_createRequestIdByUrl:(NSString *)url
                            withApi:(NSString *)apiName
                             params:(NSDictionary *)params
                               type:(YSCRequestType)requestType {
    NSString *paramsStr = [NSString jsonStringWithObject:params];
    NSString *tempStr = [NSString stringWithFormat:@"%@_%@_%@_%ld", url, apiName, paramsStr, requestType];
    return [tempStr MD5EncryptString];
}
@end




