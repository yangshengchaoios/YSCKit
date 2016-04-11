//
//  YSCKitMacro.h
//  YSCKit
//
//  Created by 杨胜超 on 16/3/22.
//  Copyright (c) 2015年 Builder. All rights reserved.
//

#import <sys/time.h>

#ifndef YSCKitMacro_h
#define YSCKitMacro_h

// 定义通用的block
typedef void (^YSCBlock)();
typedef void (^YSCObjectBlock)(NSObject *object);
typedef void (^YSCObjectErrorBlock)(NSObject *object, NSError *error);
typedef void (^YSCObjectErrorMessageBlock)(NSObject *object, NSString *errorMessage);
typedef void (^YSCIdErrorBlock)(id object, NSError *error);
typedef void (^YSCIdErrorMessageBlock)(id object, NSString *errorMessage);
typedef void (^YSCIntegerErrorBlock)(NSInteger, NSError *);


#ifndef APP_CHANNEL
    #define APP_CHANNEL     @"AppStore"
#endif

#ifndef CURRENT_DATE
    #define CURRENT_DATE    [YSCDataInstance currentDate]
#endif

#ifndef USER_ID
    #define USER_ID  @""//TODO:
#endif

#ifndef DEBUG_MODEL
    #define DEBUG_MODEL @""//TODO:
#endif

#ifndef LOGIN_TOKEN
    #define LOGIN_TOKEN   @""//TODO:
#endif




// 方法或属性过期标志
#define YSCDeprecated(explain) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, explain)

// 定义NSLog
#define __NSLog(s, ...) do { \
        NSString *logString = [NSString stringWithFormat:@"[%@(%d)] %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],__LINE__,[NSString stringWithFormat:(s), ##__VA_ARGS__]]; \
        NSLog(@"%@", logString); \
        [YSCLogManager saveLog:logString]; \
    } while (0)
#define NSLog(...) __NSLog(__VA_ARGS__)

#define LOG_POINT(point)    NSLog(@"%s =\r { x:%f, y:%f }", #point, point.x, point.y)
#define LOG_SIZE(size)      NSLog(@"%s =\r { w:%f, h:%f }", #size, size.width, size.height)
#define LOG_RECT(rect)      NSLog(@"%s =\r { x:%f, y:%f, w:%f, h:%f }", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

// 定义weakSelf
#ifndef WEAKSELF
    #define WEAKSELF __weak __typeof(&*self) weakSelf = self;
#endif


/**
 *  对象判空
 */
#define OBJECT_IS_EMPTY(_object) (_object == nil \
        || [_object isKindOfClass:[NSNull class]] \
        || ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
        || ([_object respondsToSelector:@selector(count)]  && [(NSArray *)_object count] == 0))
#define OBJECT_ISNOT_EMPTY(_object) (NO == OBJECT_IS_EMPTY(_object))
#define RETURN_WHEN_OBJECT_IS_EMPTY(_object)        if (OBJECT_IS_EMPTY(_object)) { return ;    }
#define RETURN_NIL_WHEN_OBJECT_IS_EMPTY(_object)    if (OBJECT_IS_EMPTY(_object)) { return nil; }
#define RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(_object)  if (OBJECT_IS_EMPTY(_object)) { return @""; }
#define RETURN_YES_WHEN_OBJECT_IS_EMPTY(_object)    if (OBJECT_IS_EMPTY(_object)) { return YES; }
#define RETURN_NO_WHEN_OBJECT_IS_EMPTY(_object)     if (OBJECT_IS_EMPTY(_object)) { return NO; }
#define RETURN_ZERO_WHEN_OBJECT_IS_EMPTY(_object)   if (OBJECT_IS_EMPTY(_object)) { return 0; }
// 去掉字符串的头尾空格
#define TRIM_STRING(_string) (\
        (OBJECT_IS_EMPTY(_string) || NO == [_string isKindOfClass:[NSString class]]) ? \
        @"" : [_string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] \
        )


/**
 *  创建单例
 */
#ifndef DEFINE_SHARED_INSTANCE_USING_BLOCK
    #define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
        static dispatch_once_t pred = 0; \
        __strong static id _sharedObject = nil; \
        dispatch_once(&pred, ^{ \
            _sharedObject = block(); \
        }); \
        return _sharedObject;
#endif


/**
 *  代码段简写
 */
#define RGBA(r, g, b, a)                [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a]
#define RGB(r, g, b)                    RGBA(r,g,b,1.0f)
#define RGB_GRAY(c)                     RGBA(c,c,c,1.0f)
#define RANDOM_INT(from,to)             ((int)((from) + arc4random() % ((to)-(from) + 1)))  //随机数 [from,to] 之间
#define VIEW_IN_XIB(x, i)               [[[NSBundle mainBundle] loadNibNamed:(x) owner:nil options:nil] objectAtIndex:(i)]
#define FIRST_VIEW_IN_XIB(x)            VIEW_IN_XIB(x, 0)
#define CREATE_VIEW_CONTROLLER(x)              [[NSClassFromString(x) alloc] initWithNibName:x bundle:nil]
#define CREATE_NAVIGATION_VIEW_CONTROLLER(x)   [[UINavigationController alloc]initWithRootViewController:CREATE_VIEW_CONTROLLER(x)]
#define CREATE_NSERROR_WITH_Code(c,m)   [NSError errorWithDomain:@"YSCKit" code:c userInfo:@{NSLocalizedDescriptionKey : m}]
#define CREATE_NSERROR(m)               CREATE_NSERROR_WITH_Code(0,m)
#define GET_NSERROR_MESSAGE(e)          ((NSError *)e).userInfo[NSLocalizedDescriptionKey]  //=e.localizedDescription
#define KEY_WINDOW                      [UIApplication sharedApplication].keyWindow


/**
 *  版本相关
 */
#define APP_SHORT_VERSION               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]//app的版本号(三位数如1.0.1)
#define APP_BUNDLE_VERSION              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]        //内部小版本号(一位数如3)
#define APP_VERSION                     [NSString stringWithFormat:@"%@ (%@)", APP_SHORT_VERSION, APP_BUNDLE_VERSION]   //产品版本(1.0.1 (15))
#define APP_DISPLAYED_VERSION           [NSString stringWithFormat:@"APP_DISPLAYED_VERSION_%@.%@", APP_SHORT_VERSION, APP_BUNDLE_VERSION]
#define APP_SKIP_VERSION(v)             [NSString stringWithFormat:@"APP_SKIP_VERSION_%@", v]
#define APP_BUNDLE_IDENTIFIER           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]     //com.builder.app
/**
 * 1. if (NSOrderedAscending != COMPARE_VERSION(v1,v2))  { //v1 >= v2 }
 * 2. if (NSOrderedDescending == COMPARE_VERSION(v1,v2)) { //v1 > v2 }
 * 3. if (NSOrderedAscending == COMPARE_VERSION(v1,v2))  { //v1 < v2 }
 */
#define COMPARE_VERSION(v1,v2)          [v1 compare:v2 options:NSNumericSearch]
#define COMPARE_CURRENT_VERSION(v)      COMPARE_VERSION(APP_SHORT_VERSION,v)


/**
 *  判断设备的相关参数
 */
#ifndef IOS_VERSION
    #define IOS_VERSION                 ([[[UIDevice currentDevice] systemVersion] floatValue])
#endif
#ifndef SCREEN_WIDTH
    #define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width) //屏幕的宽度(point)
#endif
#ifndef SCREEN_HEIGHT
    #define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)//屏幕的高度(point)
#endif
#ifndef IOS7_OR_LATER
    #define IOS7_OR_LATER               __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#endif

/**
 *  自动布局相关代码段简写
 */
#ifndef XIB_WIDTH
    #define XIB_WIDTH                   640.0f      //xib布局时的宽度(point)，主要用于计算缩放比例
#endif
#define AUTOLAYOUT_SCALE                (SCREEN_WIDTH / XIB_WIDTH)          //缩放比例 (当前屏幕的真实宽度point / xib布局的宽度point)
#define AUTOLAYOUT_LENGTH(x)            ((x) * AUTOLAYOUT_SCALE)            //计算缩放后的大小point
#define AUTOLAYOUT_LENGTH_W(x,w)        ((x) * (SCREEN_WIDTH / (w)))        //计算任意布局的真实大小point
#define AUTOLAYOUT_SIZE_WH(w,h)         CGSizeMake(AUTOLAYOUT_LENGTH(w), AUTOLAYOUT_LENGTH(h))
#define AUTOLAYOUT_SIZE(size)           CGSizeMake(AUTOLAYOUT_LENGTH(size.width), AUTOLAYOUT_LENGTH(size.height))//计算自动布局后的size
#define AUTOLAYOUT_EDGEINSETS(t,l,b,r)  UIEdgeInsetsMake(AUTOLAYOUT_LENGTH(t), AUTOLAYOUT_LENGTH(l), AUTOLAYOUT_LENGTH(b), AUTOLAYOUT_LENGTH(r))
#define AUTOLAYOUT_CGRECT(x,y,w,h)      CGRectMake(AUTOLAYOUT_LENGTH(x),AUTOLAYOUT_LENGTH(y),AUTOLAYOUT_LENGTH(w),AUTOLAYOUT_LENGTH(h))
#define AUTOLAYOUT_FONT(f)              ([UIFont systemFontOfSize:((f) * AUTOLAYOUT_SCALE)])
#define SCREEN_WIDTH_SCALE              (SCREEN_WIDTH / AUTOLAYOUT_SCALE)
#define SCREEN_HEIGHT_SCALE             (SCREEN_HEIGHT / AUTOLAYOUT_SCALE)


/**
 *  注册通知与发送通知
 */
//注册通知
#define ADD_OBSERVER_WITH_OBJECT(_selector, _name, _object) \
        ([[NSNotificationCenter defaultCenter] addObserver:self selector:_selector name:_name object:_object])
#define ADD_OBSERVER(_selector,_name) \
        ADD_OBSERVER_WITH_OBJECT(_selector, _name, nil)
//发送通知
#define POST_NOTIFICATION_WITH_OBJECT_AND_INFO(_name, _object, _info) \
        ([[NSNotificationCenter defaultCenter] postNotificationName:_name object:_object userInfo:(_info)])
#define POST_NOTIFICATION(_name) \
        POST_NOTIFICATION_WITH_OBJECT_AND_INFO(_name, nil, nil)
#define POST_NOTIFICATION_WITH_OBJECT(_name, _object) \
        POST_NOTIFICATION_WITH_OBJECT_AND_INFO(_name, _object, nil)
#define POST_NOTIFICATION_WITH_INFO(_name, _info) \
        POST_NOTIFICATION_WITH_OBJECT_AND_INFO(_name, nil, _info)
//移除通知
#define REMOVE_OBSERVER(_name) \
    ([[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:nil])
#define REMOVE_ALL_OBSERVERS(_self) \
    ([[NSNotificationCenter defaultCenter] removeObserver:_self])


/**
 * usage:
 *   @interface NSObject (MyAdd)
 *       @property (nonatomic, assign) BOOL isError;
 *   @end
 *
 *   #import <objc/runtime.h>
 *   @implementation NSObject (MyAdd)
 *       YSC_DYNAMIC_PROPERTY_BOOL(isError, setIsError)
 *   @end
 */
#ifndef YSC_DYNAMIC_PROPERTY_BOOL
    #define YSC_DYNAMIC_PROPERTY_BOOL(_getter_, _setter_) \
            - (void)_setter_ : (BOOL)value { \
                NSNumber *number = [NSNumber numberWithBool:value]; \
                [self willChangeValueForKey:@#_getter_]; \
                objc_setAssociatedObject(self, _cmd, number, OBJC_ASSOCIATION_RETAIN); \
                [self didChangeValueForKey:@#_getter_]; \
            } \
            - (BOOL)_getter_ { \
                NSNumber *number = objc_getAssociatedObject(self, @selector(_setter_:)); \
                return [number boolValue]; \
            }
#endif


//----------------------------------------------------------------------------//
//
//  以下宏定义参考了YYKitMacro.h
//  https://github.com/ibireme/YYKit/blob/master/YYKit/Base/YYKitMacro.h
//
//----------------------------------------------------------------------------//

/**
 Profile time cost.
 @param ^block     code to benchmark
 @param ^complete  code time cost (millisecond)
 
 Usage:
 YYBenchmark(^{
     // code
 }, ^(double ms) {
     NSLog(@"time cost: %.2f ms",ms);
 });
 */
static inline void YYBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
     extern double CACurrentMediaTime (void);
     double begin, end, ms;
     begin = CACurrentMediaTime();
     block();
     end = CACurrentMediaTime();
     ms = (end - begin) * 1000.0;
     complete(ms);
     */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}


/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 More info: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 Example:
 YYSYNTH_DUMMY_CLASS(NSString_YYAdd)
 */
#ifndef YYSYNTH_DUMMY_CLASS
    #define YYSYNTH_DUMMY_CLASS(_name_) \
            @interface YYSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
            @implementation YYSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


/**
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
     @property (nonatomic, retain) UIColor *myColor;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
     YYSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
 @end
 */
#ifndef YYSYNTH_DYNAMIC_PROPERTY_OBJECT
    #define YYSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
            - (void)_setter_ : (_type_)object { \
                [self willChangeValueForKey:@#_getter_]; \
                objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
                [self didChangeValueForKey:@#_getter_]; \
            } \
            - (_type_)_getter_ { \
                return objc_getAssociatedObject(self, @selector(_setter_:)); \
            }
#endif


/**
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
 @interface NSObject (MyAdd)
 @property (nonatomic, retain) CGPoint myPoint;
 @end
 
 #import <objc/runtime.h>
 @implementation NSObject (MyAdd)
 YYSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
 @end
 */
#ifndef YYSYNTH_DYNAMIC_PROPERTY_CTYPE
    #define YYSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
    - (void)_setter_ : (_type_)object { \
        [self willChangeValueForKey:@#_getter_]; \
        NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
        objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
        [self didChangeValueForKey:@#_getter_]; \
    } \
    - (_type_)_getter_ { \
        _type_ cValue = { 0 }; \
        NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
        [value getValue:&cValue]; \
        return cValue; \
    }
#endif

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakiy(self)
 [self doSomething^{
     @strongiy(self)
     if (!self) return;
     ...
 }];
 
 */
#ifndef weakiy
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakiy(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakiy(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakiy(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakiy(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongiy
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongiy(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongiy(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongiy(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongiy(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


#endif /* YSCKitMacro_h */
