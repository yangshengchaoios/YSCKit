//
//  YSCHUDAdapterManager.h
//  YSCKit
//
//  Created by Builder on 16/7/22.
//  Copyright © 2016年 Builder. All rights reserved.
//

/** HUDAdapter必须实现的协议 */
@protocol YSCHUDAdapterDelegate <NSObject>
@required
- (void)showHUDOnView:(UIView *)view
              message:(NSString *)message
           edgeInsets:(UIEdgeInsets)edgeInsets
      backgroundColor:(UIColor *)backgroundColor;
- (void)hideHUDOnView:(UIView *)view;
- (void)showHUDThenHideOnView:(UIView *)view message:(NSString *)message afterDelay:(NSTimeInterval)delay;
- (void)showHUDOnView:(UIView *)view imageName:(NSString *)imageName message:(NSString *)message afterDelay:(NSTimeInterval)delay;
@end


/**
 *
 * @brief 统一返回特定解决方案的适配器
 *
 * 扩展建议：
 *      采用category重写本类的方法 + (id<YSCHUDAdapterDelegate>)adapter，返回一个实现协议
 *      YSCHUDAdapterDelegate的对象即可
 *
 */
@interface YSCHUDAdapterManager : NSObject

+ (id<YSCHUDAdapterDelegate>)adapter;

@end
