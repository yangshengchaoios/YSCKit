//
//  YSCBaseViewController.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

// 定义返回按钮的箭头样式
typedef NS_ENUM(NSInteger, BackArrowType) {
    BackArrowTypeDefault = 0,       //默认用箭头图片代替返回按钮
    BackArrowTypeSystemWithNoText,  //用系统自带的返回箭头(去掉文字)
};

// 默认返回按钮图片名称
static NSString * const kDefaultBackArrowImageName = @"arrow_left_default";

/**
 *  作用：
 *      1. 统一设置返回按钮的箭头图片
 *      2. 等比例调整约束值
 *      3. 监控APP恢复运行、用户按下home键
 */
@interface YSCBaseViewController : UIViewController
@property (nonatomic, assign) BackArrowType backArrowType;
@property (nonatomic, assign) BOOL isAppeared;      //当前viewcontroller是否已经显示
@property (nonatomic, copy) YSCObjectBlock block;   //回调上一级的block

- (void)didAppBecomeActive;                         //APP恢复运行
- (void)didAppEnterBackground;                      //用户按下Home键APP进入后台
- (IBAction)backButtonClicked:(id)sender;
@end
