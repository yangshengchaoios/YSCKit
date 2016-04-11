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
static NSString * const YSCErrorTypeDisconnected        = @"网络未连接";//网络处于断开状态(访问网络之前)
static NSString * const YSCErrorTypeConnectionFailed    = @"网络连接失败";//网络错误(网络访问过程中statusCode != 200)
static NSString * const YSCErrorTypeServerFailed        = @"服务器连接失败";//服务器错误(statusCode == 200, 服务器不可访问)
static NSString * const YSCErrorTypeInternalServer      = @"";//服务器内部错误(需要进一步解析dataModel.state 和 message)
static NSString * const YSCErrorTypeRequesFailed        = @"创建网络请求失败";
static NSString * const YSCErrorTypeCopyFileFailed      = @"拷贝文件失败";
static NSString * const YSCErrorTypeURLInvalid          = @"网络请求的URL不合法";
static NSString * const YSCErrorTypeReturnEmptyData     = @"返回数据为空";
static NSString * const YSCErrorTypeDataMappingFailed   = @"数据映射本地模型失败";
static NSString * const YSCErrorTypeLoginExpired        = @"登录过期";
static NSString * const YSCErrorTypeRequesting          = @"数据获取中";

typedef void (^YSCRequestSuccess)(id responseObject);
typedef void (^YSCRequestFailed)(NSString *YSCErrorType, NSError *error);


/**
 *  网络访问类
 *  作用：控制业务json数据的获取、模型映射、取消请求、
 *       上一次相同的请求未完成之前不能重复请求
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
- (NSString *)resolveYSCErrorType:(NSString *)errorType andError:(NSError *)error;

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
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                 customModel:(Class)customModel
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

// 通用的GET、POST和上传图片（返回最原始的未经过任何映射的JSON字符串）
- (NSString *)requestFromUrl:(NSString *)url
                     withApi:(NSString *)apiName
                      params:(NSDictionary *)params
                   imageData:(NSData *)imageData
                        type:(YSCRequestType)type
                     success:(YSCRequestSuccess)success
                      failed:(YSCRequestFailed)failed;

@end


