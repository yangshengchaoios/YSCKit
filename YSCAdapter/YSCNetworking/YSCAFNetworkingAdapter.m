//
//  YSCAFNetworkingAdapter.m
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCAFNetworkingAdapter.h"
#import "AFNetworking.h"

@implementation YSCAFNetworkingAdapter

- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url
                             normalParams:(NSDictionary *)params
                         httpHeaderParams:(NSDictionary *)httpHeaderParams
                                imageData:(NSData *)imageData
                              requestType:(YSCRequestType)requestType
                        completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler {
    //1. 组装manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", @"audio/wav", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    manager.requestSerializer.timeoutInterval = YSCConfigManagerInstance.defaultRequestTimeOut;
    [manager.requestSerializer setValue:[self _signatureParams:params] forHTTPHeaderField:@"signature"];
    [manager.requestSerializer setValue:[self _httpToken] forHTTPHeaderField:@"httpToken"];
    if (OBJECT_ISNOT_EMPTY(httpHeaderParams)) {
        for (NSString *key in [httpHeaderParams allKeys]) {
            NSString *value = httpHeaderParams[key];
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    
    //2. 配置网络请求参数
    NSError *serializationError = nil;
    NSMutableURLRequest *mutableRequest = nil;
    if (YSCRequestTypeGET == requestType) {
        mutableRequest = [manager.requestSerializer requestWithMethod:@"GET"
                                                            URLString:url
                                                           parameters:params
                                                                error:&serializationError];
    }
    else if (YSCRequestTypePOST == requestType) {
        mutableRequest = [manager.requestSerializer requestWithMethod:@"POST"
                                                            URLString:url
                                                           parameters:params
                                                                error:&serializationError];
    }
    else if (YSCRequestTypeUploadFile == requestType) {
        mutableRequest = [manager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                         URLString:url
                                                                        parameters:params
                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                             [formData appendPartWithFileData:imageData name:@"file" fileName:@"fileName" mimeType:@"application/octet-stream"];
                                                         }
                                                                             error:&serializationError];
    }
    else if (YSCRequestTypePostBodyData == requestType) {
        NSString *bodyParam = [NSString ysc_jsonStringWithObject:params];
        bodyParam = [self _encryptPostBodyParam:bodyParam];
        mutableRequest = [manager.requestSerializer requestWithMethod:@"POST"
                                                            URLString:url
                                                           parameters:nil
                                                                error:&serializationError];
        mutableRequest.HTTPBody = [bodyParam dataUsingEncoding:manager.requestSerializer.stringEncoding];
    }
    //3. 开始网络请求
    if ( ! serializationError && mutableRequest) {
        return [manager dataTaskWithRequest:mutableRequest completionHandler:completionHandler];
    }
    return nil;
}

#pragma mark - Private Methods
// 计算请求参数的签名
- (NSString *)_signatureParams:(NSDictionary *)params {
    return @"";
}
// 计算httpToken参数值
- (NSString *)_httpToken {
    return @"";
}
// 计算post body的参数值
- (NSString *)_encryptPostBodyParam:(NSString *)bodyParam {
    return bodyParam;
}

@end
