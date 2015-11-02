//
//  EZGManager.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/2.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGManager.h"

@implementation EZGManager

//格式化车牌号
+ (NSString *)formatCarNumber:(NSString *)carNumber {
    if ([NSString isMatchRegex:kRegexCarNumber withString:carNumber]) {
        NSMutableString *str = [NSMutableString stringWithString:carNumber];
        [str insertString:@" " atIndex:2];
        return str;
    }
    else {
        return @"";
    }
}

//格式化救援耗时
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate {
    return [self formatRescueTimePassed:startDate endDate:[NSDate date]];
}
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSDateComponents *dateComponents = [NSDate ComponentsBetweenStartDate:startDate withEndDate:endDate];
    if (dateComponents.day > 0) {
        return [NSString stringWithFormat:@"%ld天 %02ld:%02ld:%02ld", (long)dateComponents.day,
                (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    }
    else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    }
}

//获取推送证书名称
+ (NSString *)deviceProfile {
    NSString *profile = kAppId;
    if (NO == [@"AppStore" isEqualToString:kAppChannel]) {
        profile = [profile stringByAppendingFormat:@"_InHouse"];
    }
    if ([self isDevelopmentApp]) {
        profile = [profile stringByAppendingFormat:@"_Dev"];
    }
    else {
        profile = [profile stringByAppendingFormat:@"_Dis"];
    }
    NSLog(@"profile=%@", profile);
    return profile;
}

//检测是否用测试证书打包
+ (BOOL)isDevelopmentApp {
    // Special case of simulator
    if ([UIDevice isRunningOnSimulator]) {
        return YES;
    }
    
    // There is no provisioning profile in AppStore Apps
    NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    
    // Check provisioning profile existence
    if (profilePath) {
        // Get hex representation
        NSData *profileData = [NSData dataWithContentsOfFile:profilePath];
        NSString *profileString = [NSString stringWithFormat:@"%@", profileData];
        
        // Remove brackets at beginning and end
        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        profileString = [profileString stringByReplacingCharactersInRange:NSMakeRange(profileString.length - 1, 1) withString:@""];
        
        // Remove spaces
        profileString = [profileString stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        // Convert hex values to readable characters
        NSMutableString *profileText = [NSMutableString new];
        for (int i = 0; i < profileString.length; i += 2) {
            NSString *hexChar = [profileString substringWithRange:NSMakeRange(i, 2)];
            int value = 0;
            sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
            [profileText appendFormat:@"%c", (char)value];
        }
        
        // Remove whitespaces and new lines characters
        NSArray *profileWords = [profileText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *profileClearText = [profileWords componentsJoinedByString:@""];
        
        // Look for debug value
        NSRange debugRange = [profileClearText rangeOfString:@"<key>get-task-allow</key><true/>"];
        if (debugRange.location != NSNotFound) {
            return YES;
        }
    }
    
    // Return NO by default to avoid security leaks
    return NO;
}

@end
