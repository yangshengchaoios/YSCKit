//
//  YSCDataModel.m
//  B_EZGoal
//
//  Created by yangshengchao on 16/1/26.
//  Copyright © 2016年 YingChuangKeXun. All rights reserved.
//

#import "YSCDataModel.h"
#import <MJExtension/MJExtension.h>

@implementation BaseDataModel
MJExtensionCodingImplementation
MJExtensionLogAllProperties
-(instancetype)copyWithZone:(NSZone *)zone {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}
+ (id)ObjectWithKeyValues:(id)keyValues {
    if ([keyValues isKindOfClass:[NSArray class]]) {
        return [self mj_objectArrayWithKeyValuesArray:keyValues];
    }
    else {
        return [self mj_objectWithKeyValues:keyValues];
    }
}
+ (void)GetByMethod:(NSString *)method params:(NSDictionary *)params block:(YSCResponseErrorMessageBlock)block {
    [AFNManager getDataWithAPI:method
                  andDictParam:params
                     dataModel:[self class]
              requestSuccessed:^(id responseObject) {
                  if (block) {
                      block(responseObject, nil);
                  }
              }
                requestFailure:^(ErrorType errorType, NSError *error) {
                    NSString *errMsg = [YSCCommonUtils ResolveErrorType:errorType andError:error];
                    if (block) {
                        block(nil, errMsg);
                    }
                }];
}
+ (void)PostByMethod:(NSString *)method params:(NSDictionary *)params block:(YSCResponseErrorMessageBlock)block {
    [AFNManager postDataWithAPI:method
                   andDictParam:params
                      dataModel:[self class]
               requestSuccessed:^(id responseObject) {
                   if (block) {
                       block(responseObject, nil);
                   }
               }
                 requestFailure:^(ErrorType errorType, NSError *error) {
                     NSString *errMsg = [YSCCommonUtils ResolveErrorType:errorType andError:error];
                     if (block) {
                         block(nil, errMsg);
                     }
                 }];
}
//统一规范参数的提交方式：加密的json字符串写入httpBody
+ (void)RequestByMethod:(NSString *)method params:(NSDictionary *)params block:(YSCResponseErrorMessageBlock)block {
    [AFNManager requestByUrl:kResPathAppBaseUrl
                     withAPI:method
               andArrayParam:nil
                andDictParam:nil
                andBodyParam:[NSString jsonStringWithObject:params]
                   dataModel:[self class]
                   imageData:nil
                 requestType:RequestTypePostBodyData
            requestSuccessed:^(id responseObject) {
                if (block) {
                    block(responseObject, nil);
                }
            }
              requestFailure:^(ErrorType errorType, NSError *error) {
                  NSString *errMsg = [YSCCommonUtils ResolveErrorType:errorType andError:error];
                  if (block) {
                      block(nil, errMsg);
                  }
              }];
}

- (NSString *)toJSONString {
    return [self mj_JSONString];
}
@end


@implementation YSCPhotoBrowseCellModel
+ (instancetype)CreateModelByImageUrl:(NSString *)imageUrl image:(UIImage *)image {
    YSCPhotoBrowseCellModel *model = [YSCPhotoBrowseCellModel new];
    model.imageUrl = imageUrl;
    model.image = image;
    return model;
}
@end
