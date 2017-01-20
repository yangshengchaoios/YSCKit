//
//  UIColor+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "UIColor+YSCKit.h"

//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation UIColor (YSCKit)
- (CGColorSpaceModel)ysc_colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}
- (BOOL)ysc_canProvideRGBComponents {
    switch (self.ysc_colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

- (CGFloat)ysc_red {
    NSAssert(self.ysc_canProvideRGBComponents, @"Must be an RGB color to use -red");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}
- (CGFloat)ysc_green {
    NSAssert(self.ysc_canProvideRGBComponents, @"Must be an RGB color to use -green");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.ysc_colorSpaceModel == kCGColorSpaceModelMonochrome) {
        return c[0];
    }
    return c[1];
}
- (CGFloat)ysc_blue {
    NSAssert(self.ysc_canProvideRGBComponents, @"Must be an RGB color to use -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.ysc_colorSpaceModel == kCGColorSpaceModelMonochrome) {
        return c[0];
    }
    return c[2];
}
- (CGFloat)ysc_alpha {
    return CGColorGetAlpha(self.CGColor);
}
- (CGFloat)ysc_white {
    NSAssert(self.ysc_colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

/** Color RGB string */
- (NSString *)ysc_RGBStringFromColor {
    return [NSString stringWithFormat:@"{%.0f, %.0f, %0.0f}",
            self.ysc_red * 255,
            self.ysc_green * 255,
            self.ysc_blue * 255];
}

/** Color builders */
+ (UIColor *)ysc_randomColor {
    return [UIColor colorWithRed:random() / (CGFloat)RAND_MAX
                           green:random() / (CGFloat)RAND_MAX
                            blue:random() / (CGFloat)RAND_MAX
                           alpha:1.0f];
}
+ (UIColor *)ysc_colorWithRGBString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    if (![scanner scanString:@"{" intoString:NULL]) return nil;
    const NSUInteger kMaxComponents = 4;
    float c[kMaxComponents];
    NSUInteger i = 0;
    if (![scanner scanFloat:&c[i++]]) return nil;
    while (1) {
        if ([scanner scanString:@"}" intoString:NULL]) {
            break;
        }
        if (i >= kMaxComponents) {
            return nil;
        }
        if ([scanner scanString:@"," intoString:NULL]) {
            if (![scanner scanFloat:&c[i++]]) {
                return nil;
            }
        }
        else {
            return nil;
        }
    }
    if ( ! [scanner isAtEnd]) {
        return nil;
    }
    UIColor *color;
    switch (i) {
        case 2: // monochrome
            color = [UIColor colorWithWhite:c[0] alpha:c[1]];
            break;
        case 3: // RGB
            color = [UIColor colorWithRed:c[0] / 255.0f green:c[1] / 255.0f blue:c[2] / 255.0f alpha:1.0f];
            break;
        default:
            color = nil;
    }
    return color;
}
+ (UIColor *)ysc_colorWithHexString:(NSString *)hexStringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:hexStringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor ysc_colorWithRGBHex:hexNum];
}
+ (UIColor *)ysc_colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

@end
