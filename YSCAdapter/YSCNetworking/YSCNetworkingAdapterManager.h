//
//  YSCNetworkingAdapterManager.h
//  YSCKit
//
//  Created by Builder on 16/7/5.
//  Copyright © 2016年 Builder. All rights reserved.
//

/** 定义网络请求方式 */
typedef NS_ENUM (NSInteger, YSCRequestType) {
    YSCRequestTypeGET = 0,          // default
    YSCRequestTypePOST,
    YSCRequestTypePostBodyData,
    YSCRequestTypeUploadFile
};


/** NetworkingAdapter必须实现的协议 */
@protocol YSCNetworkingAdapterDelegate <NSObject>
@required
- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url
                             normalParams:(NSDictionary *)params
                         httpHeaderParams:(NSDictionary *)httpHeaderParams
                                imageData:(NSData *)imageData
                              requestType:(YSCRequestType)requestType
                        completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler;
@end


/**
 *
 * @brief 统一返回特定解决方案的适配器
 *
 * 扩展建议：
 *      采用category重写本类的方法 + (id<YSCNetworkingAdapterDelegate>)adapter，
 *      返回一个实现协议YSCNetworkingAdapterDelegate的对象即可
 *
 */
@interface YSCNetworkingAdapterManager : NSObject

+ (id<YSCNetworkingAdapterDelegate>)adapter;

@end
