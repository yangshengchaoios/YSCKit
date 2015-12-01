//
//  EZGManager.m
//  EZGoal
//
//  Created by yangshengchao on 15/11/2.
//  Copyright © 2015年 Builder. All rights reserved.
//

#import "EZGManager.h"
#import "ServerTimeSynchronizer.h"

@implementation EZGManager

//格式化图片url
+ (NSString *)FormatImageUrl:(NSString *)imageUrl width:(CGFloat)width {
    if ([NSString isUrl:imageUrl] && NO == [NSString isContains:@"?imageView2/2" inString:imageUrl]) {
        return [NSString stringWithFormat:@"%@?imageView2/2/q/100/h/%.0f", imageUrl, width];
    }
    else {
        return imageUrl;
    }
}
//格式化评分
+ (float)FormatStaffScore:(NSNumber *)score {
    float tempValue = score.floatValue / 5.0f;
    if (tempValue > 0.8f && tempValue < 1.0f) {
        tempValue = 0.9f;
    }
    else if (tempValue > 0.6f && tempValue < 0.8f) {
        tempValue = 0.7f;
    }
    else if (tempValue > 0.4f && tempValue < 0.6f) {
        tempValue = 0.5f;
    }
    else if (tempValue > 0.2f && tempValue < 0.4f) {
        tempValue = 0.3f;
    }
    else if (tempValue > 0.0f && tempValue < 0.2f) {
        tempValue = 0.1f;
    }
    return tempValue;
}
//判断救援状态是否还在处理中
+ (BOOL)checkRescueStatusIsProcessing:(RescueStatusType)rescueStatus {
    return (RescueStatusTypeUnProcess == rescueStatus ||
            RescueStatusTypeProcessing == rescueStatus ||
            RescueStatusTypeCancelByC0 == rescueStatus ||
            RescueStatusTypeCancelByC1 == rescueStatus);
}
//判断救援状态是否结束
+ (BOOL)checkRescueStatusIsOver:(RescueStatusType)rescueStatus {
    return (RescueStatusTypeConfirm == rescueStatus ||
            RescueStatusTypeGiveUpByB == rescueStatus ||
            RescueStatusTypeCancelByB == rescueStatus);
}
#pragma mark - 车牌号相关
//今日限号
+ (NSArray *)TodayLimitedNumbers {
    NSMutableArray *limitedArray = [NSMutableArray array];
    NSInteger weekDay = [NSDate date].weekday - 1;
    if (weekDay == 1) {
        [limitedArray addObjectsFromArray:@[@"1", @"6"]];
    }
    else if (weekDay == 2) {
        [limitedArray addObjectsFromArray:@[@"2", @"7"]];
    }
    else if (weekDay == 3) {
        [limitedArray addObjectsFromArray:@[@"3", @"8"]];
    }
    else if (weekDay == 4) {
        [limitedArray addObjectsFromArray:@[@"4", @"9"]];
    }
    else if (weekDay == 5) {
        [limitedArray addObjectsFromArray:@[@"5", @"0"]];
    }
    return limitedArray;
}
+ (BOOL)CheckIfLimitedByCarNumber:(NSString *)carNumber {
    ReturnNOWhenObjectIsEmpty(carNumber)
    BOOL isLimited = NO;
    NSArray *numberArray = [EZGManager TodayLimitedNumbers];
    for (NSInteger i = [carNumber length] - 1; i > 0; i--) {
        NSString *number = [carNumber substringWithRange:NSMakeRange(i, 1)];
        if ([NSString isMatchRegex:@"^[0-9]\\d*$" withString:number]) {
            if ([numberArray containsObject:number]) {
                isLimited = YES;
            }
            break;
        }
    }
    return isLimited;
}
+ (NSArray *)carNumberIndexes:(NSString *)carNumber {
    NSMutableArray *indexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < MIN([EZGDATA.carNumberArray count], [carNumber length]); i++) {
        NSString *number = [carNumber substringWithRange:NSMakeRange(i, 1)];
        NSArray *tempArray = EZGDATA.carNumberArray[i];
        [indexArray addObject:@([tempArray indexOfObject:number])];
    }
    return indexArray;
}
//车牌号最后一位数字，-1表示没数字
+ (NSInteger)lastNumberOfCarNumber:(NSString *)carNumber {
    NSInteger lastNumber = -1;
    for (NSInteger i = [carNumber length] - 1; i > 0; i--) {
        NSString *number = [carNumber substringWithRange:NSMakeRange(i, 1)];
        if ([NSString isMatchRegex:@"^[0-9]\\d*$" withString:number]) {
            lastNumber = [number integerValue];
            break;
        }
    }
    return lastNumber;
}
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


#pragma mark - 格式化救援耗时
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate {
    NSDate *endDate = [NSDate dateFromTimeStamp:[ServerTimeSynchronizer sharedInstance].currentTimeInterval];
    return [self formatRescueTimePassed:startDate endDate:endDate];
}
+ (NSString *)formatRescueTimePassed:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSDateComponents *dateComponents = [NSDate ComponentsBetweenStartDate:startDate withEndDate:endDate];
    if (dateComponents.day > 0) {
        return [NSString stringWithFormat:@"%ld天 %02ld:%02ld:%02ld", (long)dateComponents.day,
                (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    }
    else if (dateComponents.hour > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                (long)dateComponents.hour, (long)dateComponents.minute, (long)dateComponents.second];
    }
    else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)dateComponents.minute, (long)dateComponents.second];
    }
}
//计算时间过了多少
+ (NSString *)timePassedByStartDate:(NSDate *)startDate {
    return [self timePassedByStartDate:startDate flag:NO];
}
+ (NSString *)timePassedByStartDate:(NSDate *)startDate flag:(BOOL)flag {
    NSDate *endDate = [NSDate dateFromTimeStamp:[ServerTimeSynchronizer sharedInstance].currentTimeInterval];
    //异常时间处理
    if ([startDate isLaterThanDate:endDate]) {
        return @"开始时间有误";
    }
    
    NSDateComponents *dateComponents = [NSDate ComponentsBetweenStartDate1:startDate withEndDate:endDate];
    //如果>=365d
    if (dateComponents.day >= 365) {
        return @"超过1年";
    }
    else {
        NSMutableString *timePassed = [NSMutableString string];
        if (dateComponents.day > 0) {
            [timePassed appendFormat:@"%ld天", dateComponents.day];
            if (flag && dateComponents.hour > 0) {
                [timePassed appendFormat:@"%ld小时", dateComponents.hour];
            }
            return timePassed;
        }
        if (dateComponents.hour > 0) {
            [timePassed appendFormat:@"%ld小时", dateComponents.hour];
            if (flag && dateComponents.minute > 0) {
                [timePassed appendFormat:@"%ld分钟", dateComponents.minute];
            }
            return timePassed;
        }
        if (dateComponents.minute > 0) {
            [timePassed appendFormat:@"%ld分钟", dateComponents.minute];
            return timePassed;
        }
        return @"少于1分钟";
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
