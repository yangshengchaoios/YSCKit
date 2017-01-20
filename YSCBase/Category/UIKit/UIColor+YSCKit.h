//
//  UIColor+YSCKit.h
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@interface UIColor (YSCKit)
@property (nonatomic, readonly) CGColorSpaceModel ysc_colorSpaceModel;
@property (nonatomic, readonly) BOOL ysc_canProvideRGBComponents;

@property (nonatomic, readonly) CGFloat ysc_red;
@property (nonatomic, readonly) CGFloat ysc_green;
@property (nonatomic, readonly) CGFloat ysc_blue;
@property (nonatomic, readonly) CGFloat ysc_alpha;
@property (nonatomic, readonly) CGFloat ysc_white;

/** Color RGB string */
- (NSString *)ysc_RGBStringFromColor;

/** Color builders */
+ (UIColor *)ysc_randomColor;
/** {178,20,20} */
+ (UIColor *)ysc_colorWithRGBString:(NSString *)stringToConvert;
/** FB1238 */
+ (UIColor *)ysc_colorWithHexString:(NSString *)hexStringToConvert;
+ (UIColor *)ysc_colorWithRGBHex:(UInt32)hex;

@end
