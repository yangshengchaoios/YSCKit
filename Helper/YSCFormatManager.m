//
//  YSCFormatManager.m
//  KanPian
//
//  Created by 杨胜超 on 16/3/25.
//  Copyright © 2016年 SMIT. All rights reserved.
//

#import "YSCFormatManager.h"

@implementation YSCFormatManager
+ (NSString *)formatPrice:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:NO];
}
+ (NSString *)formatPriceWithUnit:(NSNumber *)price {
    return [self formatPrice:price showMoneyTag:YES showDecimalPoint:YES useUnit:YES];
}
+ (NSString *)formatPrice:(NSNumber *)price showMoneyTag:(BOOL)isTagUsed showDecimalPoint:(BOOL) isDecimal useUnit:(BOOL)isUnitUsed {
    NSString *formatedPrice = @"";
    //是否保留2位小数
    if (isDecimal) {
        formatedPrice = [NSString stringWithFormat:@"%0.2f", [price doubleValue]];
    }
    else {
        formatedPrice = [NSString stringWithFormat:@"%ld", (long)[price integerValue]];
    }
    
    //是否添加前缀 ￥
    if (isTagUsed) {
        formatedPrice = [NSString stringWithFormat:@"￥%@", formatedPrice];
    }
    
    //是否添加后缀 元
    if(isUnitUsed) {
        formatedPrice = [NSString stringWithFormat:@"%@元", formatedPrice];
    }
    
    return formatedPrice;
}
+ (NSString *)formatNumberValue:(NSNumber *)value {
    return [self formatFloatValue:value.floatValue];
}
+ (NSString *)formatFloatValue:(CGFloat)value {
    if (value == floorf(value)) {
        return [NSString stringWithFormat:@"%.0f", value];
    }
    else {
        return [NSString stringWithFormat:@"%.2f", value];
    }
}
+ (NSString *)formatMacAddress:(NSString *)macAddress {
    NSMutableString *newMacAddress = [NSMutableString string];
    NSArray *array = [NSString splitString:macAddress byRegex:@":"];
    for (NSString *str in array) {
        NSScanner *scanner = [NSScanner scannerWithString:str];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [newMacAddress appendFormat:@"%02x:", intValue];
    }
    if ([newMacAddress length] > 0) {
        return [newMacAddress removeLastChar];//移除最后一个冒号`:`
    }
    else {
        return macAddress;
    }
}
+ (NSString *)formatPrintJsonStringOnConsole:(NSString *)jsonString {
    if (OBJECT_ISNOT_EMPTY(jsonString)) {
        NSError *error = nil;
        id data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:0
                                                    error:&error];
        if (nil == error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if (nil == error) {
                return (jsonData) ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : @"";
            }
            else {
                return @"";
            }
        }
        else {
            return @"";
        }
    }
    else {
        return @"";
    }
}
@end
