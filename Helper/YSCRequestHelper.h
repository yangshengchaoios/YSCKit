//
//  YSCRequestHelper.h
//  KanPian
//
//  Created by 杨胜超 on 16/3/26.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YSCRequestInstance      [YSCRequestHelper sharedInstance]

// 网络请求方式
typedef NS_ENUM (NSInteger, YSCRequestType) {
    YSCRequestTypeGET = 0,
    YSCRequestTypePOST,
    YSCRequestTypePostBodyData,
    YSCRequestTypeUploadFile,
    YSCRequestTypeDownloadFile,
    YSCRequestTypeCustomResponse       //数据来源不是YSCRequestHelper
};

// 网络错误类型
typedef NS_ENUM(NSInteger, YSCErrorType) {
    //网络层错误
    YSCErrorTypeDisconnected           = 10,//网络处于断开状态(访问网络之前)
    YSCErrorTypeConnectionFailed       = 11,//网络错误(网络访问过程中statusCode != 200)
    YSCErrorTypeServerFailed           = 12,//服务器错误(statusCode == 200, 服务器不可访问)
    YSCErrorTypeInternalServer         = 13,//服务器内部错误(需要进一步解析dataModel.state 和 message)
    YSCErrorTypeRequesFailed           = 14,//创建网络请求的时候出错
    
    //合法性判断错误
    YSCErrorTypeCopyFileFailed         = 100,//拷贝文件出错
    YSCErrorTypeURLInvalid             = 101,//url非法
    YSCErrorTypeDataEmpty              = 102,//返回数据为空
    YSCErrorTypeDataMappingFailed      = 103,//数据映射出错
    
    //业务层错误
    YSCErrorTypeLoginExpired           = 200,//登录过期
};

typedef void (^YSCRequestSuccess)(id responseObject);
typedef void (^YSCRequestFailed)(YSCErrorType errorType, NSError *error);


/**
 *  网络访问类
 *  作用：控制业务json数据的获取、模型映射、取消请求
 *  TODO:上传文件、下载文件、网络访问需要解耦AFNetworking
 */
@interface YSCRequestHelper : NSObject
@property (nonatomic, strong) NSMutableDictionary *requestQueue;
// 网络请求DES加密密钥(为空则不加密)
@property (nonatomic, strong) NSString *requestSecretKey;
// httpHeader的参数signatue(请求参数的签名)的MD5加密密钥
@property (nonatomic, strong) NSString *signatureSecretKey;
// httpHeader的参数httpToken的DES加密密钥(为空则不加密)
@property (nonatomic, strong) NSString *httpTokenSecretKey;

+ (instancetype)sharedInstance;
// 移除网络请求
- (void)removeRequestById:(NSString *)requestId;
- (void)removeAllRequests;
// 解析错误信息
- (NSString *)resolveErrorType:(YSCErrorType)errorType andError:(NSError *)error;
- (NSString *)resolveErrorType:(YSCErrorType)errorType;

// 常用网络请求方法
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

// 处理YSCBaseModel和YSCDataModel映射、登陆过期
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   dataModel:(Class)dataModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

// 处理自定义模型的映射，将映射好的自定义模型往上层抛
- (NSString *)requestFromUrl:(NSString *)url
                      params:(NSDictionary *)params
                 customModel:(Class)customModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

// 通用的GET、POST和上传图片（返回最原始的未经过任何映射的JSON字符串）
- (NSString *)requestFromUrl:(NSString *)url
                      params:(NSDictionary *)params
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

@end


