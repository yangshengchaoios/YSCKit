//
//  YSCConstants.h
//  YSCKit
//
//  Created by yangshengchao on 15/8/13.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#ifndef EZGoal_YSCConstants_h
#define EZGoal_YSCConstants_h

typedef void (^YSCBlock)();
typedef void (^YSCResultBlock)(NSError *error);
typedef void (^YSCBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^YSCIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^YSCArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^YSCObjectResultBlock)(NSObject *object, NSError *error);
typedef void (^YSCSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^YSCDataResultBlock)(NSData *data, NSError *error);
typedef void (^YSCImageResultBlock)(UIImage * image, NSError *error);
typedef void (^YSCStringResultBlock)(NSString *string, NSError *error);
typedef void (^YSCIdResultBlock)(id object, NSError *error);
typedef void (^YSCProgressBlock)(CGFloat percentDone);
typedef void (^YSCDictionaryResultBlock)(NSDictionary * dict, NSError *error);


//设置默认颜色
#define DefaultBorderColor          RGB(216, 216, 216)
#define DefaultPlaceholderColor     RGB(216, 216, 216)


//代码段简写
#define isEmpty(object) (object == nil \
|| [object isKindOfClass:[NSNull class]] \
|| ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0) \
|| ([object respondsToSelector:@selector(count)]  && [(NSArray *)object count] == 0))

#endif
