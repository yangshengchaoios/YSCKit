//
//  YSCRequestManager.h
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCNetworkingAdapterManager.h"

#define YSCRequestManagerInstance       [YSCRequestManager sharedInstance]

typedef void (^YSCRequestSuccess)(id responseObject);
typedef void (^YSCRequestFailed)(NSString *YSCErrorType, NSError *error);


/**
 *  网络访问类
 *  功能：json数据的获取、模型映射、取消请求、解析错误信息
 */
@interface YSCRequestManager : NSObject
@property (nonatomic, strong) NSMutableDictionary *requestQueue;
@property (nonatomic, strong) NSString *pathDomain;     // 接口域名/IP
@property (nonatomic, strong) NSString *pathAppBaseUrl; // 接口地址url前缀
@property (nonatomic, strong) NSString *pathAppResUrl;  // 资源文件url前缀

+ (instancetype)sharedInstance;
/** 取消单个网络请求 */
- (void)cancelRequestById:(NSString *)requestId;
/** 取消所有网络请求 */
- (void)cancelAllRequests;

/** 解析错误信息 */
- (NSString *)resolveYSCErrorType:(NSString *)errorType andError:(NSError *)error;

/** 常用网络请求方法 */
- (NSString *)requestWithApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

/** 处理YSCModel和YSCDataBaseModel映射 */
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

/** 处理自定义模型的映射，将映射好的自定义模型往上层抛 */
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                 customModel:(Class)customModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

/** 通用的GET、POST和上传（返回最原始的未经过任何映射的JSON字符串） */
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
            httpHeaderParams:(NSDictionary *)httpHeaderParams
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;


@end
