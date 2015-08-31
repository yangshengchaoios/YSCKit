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
typedef void (^YSCStringResultBlock)(NSString *string, NSError *error);
typedef void (^YSCBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^YSCFloatBlock)(CGFloat percentDone);
typedef void (^YSCIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^YSCIdResultBlock)(id object, NSError *error);
typedef void (^YSCObjectResultBlock)(NSObject *object, NSError *error);
typedef void (^YSCArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^YSCSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^YSCDataResultBlock)(NSData *data, NSError *error);
typedef void (^YSCImageResultBlock)(UIImage * image, NSError *error);
typedef void (^YSCDictionaryResultBlock)(NSDictionary * dict, NSError *error);

//常量
#ifndef kLogManageType
    #define kLogManageType              @"1"
#endif
#ifndef kDefaultTipsEmptyText
    #define kDefaultTipsEmptyText       @"暂无数据"
#endif
#ifndef kDefaultTipsEmptyIcon
    #define kDefaultTipsEmptyIcon       @"icon_empty"//列表为空时的默认icon名称
#endif
#ifndef kDefaultTipsFailedIcon
    #define kDefaultTipsFailedIcon      @"icon_failed"//列表加载失败时的默认icon名称
#endif
#ifndef kDefaultTipsButtonTitle
    #define kDefaultTipsButtonTitle     @"重新加载"//列表加载失败、为空时的按钮名称
#endif

//方法或属性过期标志
//#define YSCDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
#define YSCDeprecated(explain) __attribute__((deprecated(explain)))


/**
 *  重新定义NSLog
 */
//控制调试信息的输出
#define DEBUGMODEL      [GetObject(@"DEBUG") boolValue]

#define __NSLog(s, ...) do { \
NSString *logString = [NSString stringWithFormat:@"[%@(%d)] %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],__LINE__,[NSString stringWithFormat:(s), ##__VA_ARGS__]]; \
if ( DEBUGMODEL ) { \
NSLog(@"%@", logString);\
[LogManager saveLog:logString];\
} \
else { \
NSLog(@"%@", logString); \
if ([@"1" isEqualToString:kLogManageType]) { \
[LogManager saveLog:logString]; \
} \
} \
} while (0)

#define NSLog(...) __NSLog(__VA_ARGS__)

/**
 *  定义单例
 */
#pragma mark - Singleton

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject;


//设置默认颜色
#ifndef kDefaultViewColor
    #define kDefaultViewColor               RGB(238, 238, 238)      //self.view的默认背景颜色
#endif
#ifndef kDefaultColor
    #define kDefaultColor                   RGB(47, 152, 233)       //app默认主色(普通按钮+文本)
#endif
#ifndef kDefaultBorderColor
    #define kDefaultBorderColor             RGB(218, 218, 218)      //默认边框颜色
#endif
#ifndef kDefaultPlaceholderColor
    #define kDefaultPlaceholderColor        RGB(218, 218, 218)      //默认占位字符颜色
#endif
#ifndef kDefaultTipViewButtonColor
    #define kDefaultTipViewButtonColor      [UIColor redColor]      //默认【重新加载】按钮背景色
#endif
#ifndef kDefaultImageBackColor
    #define kDefaultImageBackColor          RGB(240, 240, 240)      //默认图片背景色
#endif
#ifndef kDefaultNaviBarTintColor
    #define kDefaultNaviBarTintColor        RGB(47, 152, 233)       //导航栏默认文字、icon的颜色
#endif
#ifndef kDefaultNaviBarTitleColor
    #define kDefaultNaviBarTitleColor       RGB(10, 10, 10)         //导航栏标题颜色
#endif
#ifndef kDefaultNaviBarItemColor
    #define kDefaultNaviBarItemColor        kDefaultNaviBarTintColor//导航栏左右文字颜色
#endif
#ifndef kDefaultNaviTintColor
    #define kDefaultNaviTintColor           RGBA(255, 255, 255, 1)    //系统导航栏背景颜色(包括了StatusBar)
#endif
#ifndef kDefaultCustomNaviTintColor
    #define kDefaultCustomNaviTintColor     RGB(234, 106, 84)       //自定义导航栏背景颜色(包括了StatusBar)
#endif
#ifndef kDefaultNaviBarTitleFont
    #define kDefaultNaviBarTitleFont        [UIFont boldSystemFontOfSize:AUTOLAYOUT_LENGTH(34)]    //导航栏标题字体大小
#endif
#ifndef kDefaultNaviBarItemFont
    #define kDefaultNaviBarItemFont         AUTOLAYOUT_FONT(26)     //导航栏左右文字大小
#endif
#ifndef kDefaultNaviBarSubTitleFont
    #define kDefaultNaviBarSubTitleFont     AUTOLAYOUT_FONT(26)    //导航栏副标题字体大小
#endif
#ifndef kDefaultNaviBarSubTitleColor
    #define kDefaultNaviBarSubTitleColor    kDefaultNaviBarTitleColor     //导航栏副标题字体颜色
#endif

//代码段简写
#ifndef isEmpty
    #define isEmpty(object) (object == nil \
    || [object isKindOfClass:[NSNull class]] \
    || ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0) \
    || ([object respondsToSelector:@selector(count)]  && [(NSArray *)object count] == 0))
#endif

#ifndef isNotEmpty
    #define isNotEmpty(object) (! isEmpty(object))
#endif

#ifndef WeakSelfType
    #define WeakSelfType __weak __typeof(&*self)
    #define WEAKSELF  WeakSelfType weakSelf = self;
#endif

/**
 *  代码段简写
 *
 */
#define RGB(r, g, b)                                [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f]
#define RGBA(r, g, b, a)                            [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a]
#define RGBHEX(hexstring)                           [UIColor colorWithHexString:[NSString replaceString:hexstring byRegex:@"[#]" to:@""]]
#define ViewInXib(_xibName, _index)                 [[[NSBundle mainBundle] loadNibNamed:(_xibName) owner:nil options:nil] objectAtIndex:(_index)]
#define FirstViewInXib(_xibName)                    ViewInXib(_xibName, 0)
#define NavigationViewController(x)                 [[UINavigationController alloc]initWithRootViewController:[[NSClassFromString(x) alloc] initWithNibName:nil bundle:nil]]
#define ViewController(x)                           [[NSClassFromString(x) alloc] initWithNibName:x bundle:nil]
#define KeyWindow                                   [UIApplication sharedApplication].keyWindow
#define FileDefaultManager                          [NSFileManager defaultManager]
#define AppProgramPath(x)                           [[YSCFileUtils DirectoryPathOfBundle] stringByAppendingPathComponent:x]
#define ReturnWhenObjectIsEmpty(object)             if ([NSObject isEmpty:object]) { return ;    }
#define ReturnNilWhenObjectIsEmpty(object)          if ([NSObject isEmpty:object]) { return nil; }
#define ReturnEmptyWhenObjectIsEmpty(object)        if ([NSObject isEmpty:object]) { return @""; }
#define ReturnYESWhenObjectIsEmpty(object)          if ([NSObject isEmpty:object]) { return YES; }
#define ReturnNOWhenObjectIsEmpty(object)           if ([NSObject isEmpty:object]) { return NO;  }
#define ReturnZeroWhenObjectIsEmpty(object)         if ([NSObject isEmpty:object]) { return 0;  }
#define Trim(x)                                     [NSString trimString:x]
#define RandomInt(from,to)                          ((int)((from) + arc4random() % ((to)-(from) + 1)))  //随机数 [from,to] 之间
#define CreateNSError(errMsg)                       [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : Trim(errMsg)}]
#define CreateNSErrorCode(code,errMsg)                   [NSError errorWithDomain:@"" code:Code userInfo:@{NSLocalizedDescriptionKey : Trim(errMsg)}]
#define GetNSErrorMsg(error)                        ((NSError *)error).userInfo[NSLocalizedDescriptionKey]  //=error.localizedDescription
#define STORAGEMANAGER                              [StorageManager sharedInstance]

/**
 *  版本相关
 *
 */
#define AppVersion                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]//app的版本号(三位数如1.0.1)
#define BundleVersion                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]    //内部小版本号(一位数如3)
#define ProductVersion                  [NSString stringWithFormat:@"%@ (%@)", AppVersion, BundleVersion]           //产品版本(1.0.1 (15))
#define BundleIdentifier                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define WelcomeVersion                  [NSString stringWithFormat:@"Welcome_V%@.%@", AppVersion, BundleVersion]
#define SkipVersion                     [NSString stringWithFormat:@"SkipVersion_V%@.%@", AppVersion, BundleVersion]


/**
 *  自动布局相关代码段简写
 *
 */
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
#pragma mark - Notification

#define addNObserver(_selector,_name)               ([[NSNotificationCenter defaultCenter] addObserver:self selector:_selector name:_name object:nil])
#define addNObserverWithObj(_selector,_name,_obj)   ([[NSNotificationCenter defaultCenter] addObserver:self selector:_selector name:_name object:_obj])
#define removeNObserver(_name)                      ([[NSNotificationCenter defaultCenter] removeObserver:self name:_name object:nil])
#define removeAllObservers(_self)                   ([[NSNotificationCenter defaultCenter] removeObserver:_self])
#define postN(_name)                                ([[NSNotificationCenter defaultCenter] postNotificationName:_name object:nil userInfo:nil])
#define postNWithObj(_name,_obj)                    ([[NSNotificationCenter defaultCenter] postNotificationName:_name object:(_obj) userInfo:nil])
#define postNWithInfo(_name,_info)                  ([[NSNotificationCenter defaultCenter] postNotificationName:_name object:nil userInfo:(_info)])

#endif