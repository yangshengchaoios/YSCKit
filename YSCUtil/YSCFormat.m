//
//  YSCFormat.m
//  YSCKit
//
//  Created by Builder on 16/7/1.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "YSCFormat.h"


//====================================
//
//  格式化数据
//  @Author: Builder
//
//====================================
@implementation YSCFormat
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
    NSArray *array = [NSString ysc_splitString:macAddress byRegex:@":"];
    for (NSString *str in array) {
        NSScanner *scanner = [NSScanner scannerWithString:str];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [newMacAddress appendFormat:@"%02x:", intValue];
    }
    if ([newMacAddress length] > 0) {
        return [newMacAddress ysc_removeLastChar];//移除最后一个冒号`:`
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
        if ( ! error) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted
                                                                 error:&error];
            if ( ! error) {
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
+ (NSString *)formatByteData:(unsigned long long)byte {
    if (byte < 1024.0) {
        return [NSString stringWithFormat:@"%llu byte%@", byte, byte > 1 ? @"s" : @""];
    }
    else if (byte < (1024.0 * 1024.0)) {
        return [NSString stringWithFormat:@"%.1f K", byte / 1024.0f];
    }
    else if (byte < (1024.0 * 1024.0 * 1024.0)) {
        return [NSString stringWithFormat:@"%.1f M", byte / 1024.0f / 1024.0f];
    }
    else if (byte < (1024.0 * 1024.0 * 1024.0 * 1024.0)) {
        return [NSString stringWithFormat:@"%.1f G", byte / 1024.0f / 1024.0f / 1024.0f];
    }
    else {
        return [NSString stringWithFormat:@"%.1f T", byte / 1024.0f / 1024.0f / 1024.0f / 1024.0f];
    }
}
+ (NSString *)formatDurationWithSecond:(long)second {
    return [self formatDurationWithMS:second * 1000];
}
+ (NSString *)formatDurationWithMS:(unsigned long)ms {
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    
    seconds = ms / 1000;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    if (ms <= 0) {
        return @"00:00:00";
    }
    else {
        return [[NSString alloc] initWithCString:buff encoding:NSUTF8StringEncoding];
    }
}
@end
