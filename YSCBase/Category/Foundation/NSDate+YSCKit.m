//
//  NSDate+YSCKit.m
//  YSCKit
//
//  Created by Builder on 16/6/30.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "NSDate+YSCKit.h"

#define YSC_STD_MINUTE    60
#define YSC_STD_HOUR      (60 * YSC_STD_MINUTE)
#define YSC_STD_DAY       (24 * YSC_STD_HOUR)
#define YSC_STD_WEEK      (7  * YSC_STD_DAY)

#if IOS8_OR_LATER
    #define YSC_CalendarUnitYear        NSCalendarUnitYear
#else
    #define YSC_CalendarUnitYear        NSYearCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitMonth       NSCalendarUnitMonth
#else
    #define YSC_CalendarUnitMonth       NSMonthCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitDay         NSCalendarUnitDay
#else
    #define YSC_CalendarUnitDay         NSDayCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitHour        NSCalendarUnitHour
#else
    #define YSC_CalendarUnitHour        NSHourCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitMinute      NSCalendarUnitMinute
#else
    #define YSC_CalendarUnitMinute      NSMinuteCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitSecond      NSCalendarUnitSecond
#else
    #define YSC_CalendarUnitSecond      NSSecondCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitWeekday     NSCalendarUnitWeekday
#else
    #define YSC_CalendarUnitWeekday     NSWeekdayCalendarUnit
#endif
#if IOS8_OR_LATER
    #define YSC_CalendarUnitWeekOfYear  NSCalendarUnitWeekOfYear
#else
    #define YSC_CalendarUnitWeekOfYear  NSWeekOfYearCalendarUnit
#endif

#define CALENDAR_UNITS      (YSC_CalendarUnitYear | YSC_CalendarUnitMonth | YSC_CalendarUnitDay | YSC_CalendarUnitHour | YSC_CalendarUnitMinute | YSC_CalendarUnitSecond | YSC_CalendarUnitWeekday | YSC_CalendarUnitWeekOfYear)
#define DATE_COMPONENTS     [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:self]


//==============================================================================
//
//  常用方法
//  @Author: Builder
//
//==============================================================================
@implementation NSDate (YSCKit)
- (NSInteger)ysc_hour {
    return [DATE_COMPONENTS hour];
}
- (NSInteger)ysc_minute {
    return [DATE_COMPONENTS minute];
}
- (NSInteger)ysc_seconds {
    return [DATE_COMPONENTS second];
}
- (NSInteger)ysc_day {
    return [DATE_COMPONENTS day];
}
- (NSInteger)ysc_month {
    return [DATE_COMPONENTS month];
}
- (NSInteger)ysc_weekday {
    return [DATE_COMPONENTS weekday];
}
- (NSInteger)ysc_weekOfYear {
    return [DATE_COMPONENTS weekOfYear];
}
- (NSInteger)ysc_nthWeekday {
    return [DATE_COMPONENTS weekdayOrdinal];
}
- (NSInteger)ysc_year {
    return [DATE_COMPONENTS year];
}

#pragma mark Relative Dates
+ (NSDate *)ysc_dateNow {
    return CURRENT_DATE;
}
+ (NSDate *)ysc_dateTomorrow {
    return [NSDate ysc_dateFromNowAfterDays:1];
}
+ (NSDate *)ysc_dateYesterday {
    return [NSDate ysc_dateFromNowBeforeDays:1];
}
+ (NSDate *)ysc_dateAfterTomorrow {
    return [NSDate ysc_dateFromNowAfterDays:2];
}
+ (NSDate *)ysc_dateBeforeYesterday {
    return [NSDate ysc_dateFromNowBeforeDays:2];
}
+ (NSDate *)ysc_dateFromNowAfterDays:(NSInteger)days {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:YSC_STD_DAY * days];
}
+ (NSDate *)ysc_dateFromNowBeforeDays:(NSInteger)days {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:-YSC_STD_DAY * days];
}
+ (NSDate *)ysc_dateFromNowAfterHours:(NSInteger)hours {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:YSC_STD_HOUR * hours];
}
+ (NSDate *)ysc_dateFromNowBeforeHours:(NSInteger)hours {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:-YSC_STD_HOUR * hours];
}
+ (NSDate *)ysc_dateFromNowAfterMinutes:(NSInteger)minutes {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:YSC_STD_MINUTE * minutes];
}
+ (NSDate *)ysc_dateFromNowBeforeMinutes:(NSInteger)minutes {
    return [self _ysc_dateWithSecondReference:CURRENT_DATE second:-YSC_STD_MINUTE * minutes];
}

#pragma mark - Convert with format
+ (NSDate *)ysc_dateFromTimeStamp:(NSString *)timeStamp {
    return [self ysc_dateFromTimeInterval:[timeStamp longLongValue]];
}
+ (NSDate *)ysc_dateFromTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        timeInterval = timeInterval / 1000.0f;
    }
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}
+ (NSDate *)ysc_dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}
+ (NSString *)ysc_stringFromTimeStamp:(NSString *)timeStamp withFormat:(NSString *)format {
    return [[self ysc_dateFromTimeStamp:timeStamp] ysc_stringWithFormat:format];
}
+ (NSString *)ysc_convertDateString:(NSString *)dataString fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat {
    NSDate *date = [NSDate ysc_dateFromString:dataString withFormat:fromFormat];
    return [date ysc_stringWithFormat:toFormat];
}
- (NSString *)ysc_stringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

#pragma mark Comparing Dates
- (BOOL)ysc_isEqualToDateIgnoringTime:(NSDate *)date {
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:date];
    return (([components1 year] == [components2 year]) &&
            ([components1 month] == [components2 month]) &&
            ([components1 day] == [components2 day]));
}
- (BOOL)ysc_isToday {
    return [self ysc_isEqualToDateIgnoringTime:CURRENT_DATE];
}
- (BOOL)ysc_isTomorrow {
    return [self ysc_isEqualToDateIgnoringTime:[NSDate ysc_dateTomorrow]];
}
- (BOOL)ysc_isYesterday {
    return [self ysc_isEqualToDateIgnoringTime:[NSDate ysc_dateYesterday]];
}
- (BOOL)ysc_isAfterTomorrow {
    return [self ysc_isEqualToDateIgnoringTime:[NSDate ysc_dateAfterTomorrow]];
}
- (BOOL)ysc_isBeforeYesterday {
    return [self ysc_isEqualToDateIgnoringTime:[NSDate ysc_dateBeforeYesterday]];
}
- (BOOL)ysc_isSameWeekAsDate:(NSDate *)date {
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:date];
    if ([components1 weekOfYear] != [components2 weekOfYear]) {
        return NO;
    }
    return (fabs([self timeIntervalSinceDate:date]) < YSC_STD_WEEK);
}
- (BOOL)ysc_isThisWeek {
    return [self ysc_isSameWeekAsDate:CURRENT_DATE];
}
- (BOOL)ysc_isNextWeek {
    NSDate *newDate = [NSDate _ysc_dateWithSecondReference:self second:YSC_STD_WEEK];
    return [self ysc_isSameWeekAsDate:newDate];
}
- (BOOL)ysc_isLastWeek {
    NSDate *newDate = [NSDate _ysc_dateWithSecondReference:self second:-YSC_STD_WEEK];
    return [self ysc_isSameWeekAsDate:newDate];
}
- (BOOL)ysc_isSameYearAsDate:(NSDate *)date {
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:date];
    return ([components1 year] == [components2 year]);
}
- (BOOL)ysc_isThisYear {
    return [self ysc_isSameYearAsDate:CURRENT_DATE];
}
- (BOOL)ysc_isNextYear {
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:CURRENT_DATE];
    
    return ([components1 year] == ([components2 year] + 1));
}
- (BOOL)ysc_isLastYear {
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:YSC_CalendarUnitYear fromDate:CURRENT_DATE];
    
    return ([components1 year] == ([components2 year] - 1));
}
- (BOOL)ysc_isEarlierThanDate:(NSDate *)date {
    return ([self earlierDate:date] == self);
}
- (BOOL)ysc_isLaterThanDate:(NSDate *)date {
    return ([self laterDate:date] == self);
}

#pragma mark Adjusting Dates
- (NSDate *)ysc_dateAfterDays:(NSInteger)days {
    return [NSDate _ysc_dateWithSecondReference:self second:YSC_STD_DAY * days];
}
- (NSDate *)ysc_dateBeforeDays:(NSInteger)days {
    return [NSDate _ysc_dateWithSecondReference:self second:-YSC_STD_DAY * days];
}
- (NSDate *)ysc_dateAfterHours:(NSInteger)hours {
    return [NSDate _ysc_dateWithSecondReference:self second:YSC_STD_HOUR * hours];
}
- (NSDate *)ysc_dateBeforeHours:(NSInteger)hours {
    return [NSDate _ysc_dateWithSecondReference:self second:-YSC_STD_HOUR * hours];
}
- (NSDate *)ysc_dateAfterMinutes:(NSInteger)minutes {
    return [NSDate _ysc_dateWithSecondReference:self second:YSC_STD_MINUTE * minutes];
}
- (NSDate *)ysc_dateBeforeMinutes:(NSInteger)minutes {
    return [NSDate _ysc_dateWithSecondReference:self second:-YSC_STD_MINUTE * minutes];
}
- (NSDate *)ysc_dateAtStartOfDay {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:CALENDAR_UNITS fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

#pragma mark Retrieving Intervals
- (NSInteger)ysc_minutesAfterDate:(NSDate *)date {
    NSTimeInterval ti = [self timeIntervalSinceDate:date];
    return (NSInteger)(ti / YSC_STD_MINUTE);
}
- (NSInteger)ysc_minutesBeforeDate:(NSDate *)date {
    NSTimeInterval ti = [date timeIntervalSinceDate:self];
    return (NSInteger)(ti / YSC_STD_MINUTE);
}
- (NSInteger)ysc_hoursAfterDate:(NSDate *)date {
    NSTimeInterval ti = [self timeIntervalSinceDate:date];
    return (NSInteger)(ti / YSC_STD_HOUR);
}
- (NSInteger)ysc_hoursBeforeDate:(NSDate *)date {
    NSTimeInterval ti = [date timeIntervalSinceDate:self];
    return (NSInteger)(ti / YSC_STD_HOUR);
}
- (NSInteger)ysc_daysAfterDate:(NSDate *)date {
    NSTimeInterval ti = [self timeIntervalSinceDate:date];
    return (NSInteger)(ti / YSC_STD_DAY);
}
- (NSInteger)ysc_daysBeforeDate:(NSDate *)date {
    NSTimeInterval ti = [date timeIntervalSinceDate:self];
    return (NSInteger)(ti / YSC_STD_DAY);
}

#pragma mark - format the date to string
- (NSString *)ysc_chineseWeekDay {
    NSString *weekDay = @"";
    NSInteger day = self.ysc_weekday;
    if (1 == day) {
        weekDay = @"星期日";
    }
    else if (2 == day) {
        weekDay = @"星期一";
    }
    else if (3 == day) {
        weekDay = @"星期二";
    }
    else if (4 == day) {
        weekDay = @"星期三";
    }
    else if (5 == day) {
        weekDay = @"星期四";
    }
    else if (6 == day) {
        weekDay = @"星期五";
    }
    else {
        weekDay = @"星期六";
    }
    return weekDay;
}
- (NSString *)ysc_timeStamp {
    return [NSString stringWithFormat:@"%.0f", [self timeIntervalSince1970]];
}
- (NSString *)ysc_chineseMonth {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    int i_month = 0;
    NSString *theMonth = [dateFormatter stringFromDate:self];
    if ([[theMonth substringToIndex:0] isEqualToString:@"0"]) {
        i_month = [[theMonth substringFromIndex:1] intValue];
    }
    else {
        i_month = [theMonth intValue];
    }
    
    if (i_month == 1) {
        return @"一";
    }
    else if (i_month == 2) {
        return @"二";
    }
    else if (i_month == 3) {
        return @"三";
    }
    else if (i_month == 4) {
        return @"四";
    }
    else if (i_month == 5) {
        return @"五";
    }
    else if (i_month == 6) {
        return @"六";
    }
    else if (i_month == 7) {
        return @"七";
    }
    else if (i_month == 8) {
        return @"八";
    }
    else if (i_month == 9) {
        return @"九";
    }
    else if (i_month == 10) {
        return @"十";
    }
    else if (i_month == 11) {
        return @"十一";
    }
    else if (i_month == 12) {
        return @"十二";
    }
    else {
        return @"";
    }
}
- (NSString *)ysc_constellation {
    NSString *retStr = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    int i_month = 0;
    NSString *theMonth = [dateFormatter stringFromDate:self];
    if ([[theMonth substringToIndex:0] isEqualToString:@"0"]) {
        i_month = [[theMonth substringFromIndex:1] intValue];
    }
    else {
        i_month = [theMonth intValue];
    }
    
    [dateFormatter setDateFormat:@"dd"];
    int i_day = 0;
    NSString *theDay = [dateFormatter stringFromDate:self];
    if ([[theDay substringToIndex:0] isEqualToString:@"0"]) {
        i_day = [[theDay substringFromIndex:1] intValue];
    }
    else {
        i_day = [theDay intValue];
    }
    switch (i_month) {
        case 1:
            if (i_day >= 20 && i_day <= 31) {
                retStr = @"水瓶座";
            }
            if (i_day >= 1 && i_day <= 19) {
                retStr = @"摩羯座";
            }
            break;
            
        case 2:
            if (i_day >= 1 && i_day <= 18) {
                retStr = @"水瓶座";
            }
            if (i_day >= 19 && i_day <= 31) {
                retStr = @"双鱼座";
            }
            break;
            
        case 3:
            if (i_day >= 1 && i_day <= 20) {
                retStr = @"双鱼座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"白羊座";
            }
            break;
            
        case 4:
            if (i_day >= 1 && i_day <= 19) {
                retStr = @"白羊座";
            }
            if (i_day >= 20 && i_day <= 31) {
                retStr = @"金牛座";
            }
            break;
            
        case 5:
            if (i_day >= 1 && i_day <= 20) {
                retStr = @"金牛座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"双子座";
            }
            break;
            
        case 6:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"双子座";
            }
            if (i_day >= 22 && i_day <= 31) {
                retStr = @"巨蟹座";
            }
            break;
            
        case 7:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"巨蟹座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"狮子座";
            }
            break;
            
        case 8:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"狮子座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"处女座";
            }
            break;
            
        case 9:
            if (i_day >= 1 && i_day <= 22) {
                retStr = @"处女座";
            }
            if (i_day >= 23 && i_day <= 31) {
                retStr = @"天秤座";
            }
            break;
            
        case 10:
            if (i_day >= 1 && i_day <= 23) {
                retStr = @"天秤座";
            }
            if (i_day >= 24 && i_day <= 31) {
                retStr = @"天蝎座";
            }
            break;
            
        case 11:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"天蝎座";
            }
            if (i_day >= 22 && i_day <= 31) {
                retStr = @"射手座";
            }
            break;
            
        case 12:
            if (i_day >= 1 && i_day <= 21) {
                retStr = @"射手座";
            }
            if (i_day >= 21 && i_day <= 31) {
                retStr = @"摩羯座";
            }
            break;
    }
    return retStr;
}

#pragma mark - 过去了多长时间
+ (NSString *)ysc_timePassedByStartTimeStamp:(NSString *)timeStamp {
    if ( ! timeStamp || ! [timeStamp isKindOfClass:[NSString class]] || ! [timeStamp longLongValue]) {
        return @"";
    }
    NSDate *startDate= [NSDate ysc_dateFromTimeStamp:timeStamp];
    return [self ysc_timePassedByStartDate:startDate];
}
+ (NSString *)ysc_timePassedByStartDate:(NSDate *)startDate {
    RETURN_EMPTY_WHEN_OBJECT_IS_EMPTY(startDate);
    NSDate *endDate = CURRENT_DATE;
    //异常时间处理
    if ([startDate ysc_isLaterThanDate:endDate]) {
        return [startDate ysc_stringWithFormat:kDateFormat1];
    }
    NSDateComponents *dateComponents = [NSDate ysc_componentsFromDate1:startDate toDate:endDate];
    //如果>=365d
    if (dateComponents.day >= 365) {
        return [startDate ysc_stringWithFormat:kDateFormat5];
    }
    //如果>=30d && <365d
    if (dateComponents.day >= 30 && dateComponents.day < 365) {
        return [startDate ysc_stringWithFormat:@"M月d日"];
    }
    //如果>=1d  && <30d
    if (dateComponents.day >= 1 && dateComponents.day < 30) {
        return [NSString stringWithFormat:@"%ld天前", (long)dateComponents.day];
    }
    //如果>=1h  && <24h
    if (dateComponents.hour >= 1 && dateComponents.hour < 24) {
        return [NSString stringWithFormat:@"%ld小时前", (long)dateComponents.hour];
    }
    //如果>=1m  && <60m
    if (dateComponents.minute >= 1 && dateComponents.minute < 60) {
        return [NSString stringWithFormat:@"%ld分钟前", (long)dateComponents.minute];
    }
    return @"刚刚";//1分钟以内
}
+ (NSString *)ysc_timePassedByStartDate1:(NSDate *)startDate {
    if ([startDate ysc_isThisYear]) {
        if ([startDate ysc_isToday]) {
            return [NSString stringWithFormat:@"今天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
        }
        else if ([startDate ysc_isYesterday]) {
            return [NSString stringWithFormat:@"昨天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
        }
        else if ([startDate ysc_isBeforeYesterday]) {
            return [NSString stringWithFormat:@"前天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
        }
        else {
            return [startDate ysc_stringWithFormat:kDateFormat15];
        }
    }
    else {
        return [startDate ysc_stringWithFormat:kDateFormat7];
    }
}
+ (NSString *)ysc_timePassedByStartDate2:(NSDate *)startDate {
    NSDateComponents *dateComponents = [NSDate ysc_componentsFromDate:startDate toDate:CURRENT_DATE];
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


#pragma mark - 计算两个时间点之间的距离
+ (NSDateComponents *)ysc_componentsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    return [self ysc_componentsFromDate:startDate
                                 toDate:endDate
                         withComponents:YSC_CalendarUnitDay | YSC_CalendarUnitHour | YSC_CalendarUnitMinute | YSC_CalendarUnitSecond];
}
+ (NSDateComponents *)ysc_componentsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate withComponents:(NSCalendarUnit)unitFlags {
    if ([startDate ysc_isLaterThanDate:endDate]) {
        return nil;
    }
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate toDate:endDate options:0];
}
+ (NSDateComponents *)ysc_componentsFromDate1:(NSDate *)startDate toDate:(NSDate *)endDate {
    if ([startDate ysc_isLaterThanDate:endDate]) {
        return nil;
    }
    NSTimeInterval remainInterval = [endDate timeIntervalSinceDate:startDate];
    NSCalendarUnit unitFlags = YSC_CalendarUnitDay | YSC_CalendarUnitHour | YSC_CalendarUnitMinute | YSC_CalendarUnitSecond;
    NSDateComponents *components = [NSDateComponents new];
    components.year = 0;
    components.month = 0;
    components.day = 0;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    //方法一：计算间隔时间是根据从零时间点(1970-01-01)开始的NSDate对象(效率最低！)
    //    NSDate *sinceDate = [NSDate dateFromString:@"1970-01-01" withFormat:@"yyyy-MM-dd"];
    //    NSDate *tempDate = [NSDate dateWithTimeInterval:remainTimeInterval sinceDate:sinceDate];//NOTE:dateWithTimeIntervalSince1970会有时差问题
    //    NSInteger day = [tempDate daysAfterDate:sinceDate];//NOTE:这里不能用tempDate.day
    //    NSInteger hour = tempDate.hour;
    //    NSInteger minute = tempDate.minute;
    //    NSInteger second = tempDate.seconds;
    
    //方法二：最直接的方法(效率最高！)
    NSInteger day = (NSInteger)(remainInterval / YSC_STD_DAY);
    NSInteger hour = (NSInteger)(remainInterval / YSC_STD_HOUR) - 24 * day;
    NSInteger minute = (NSInteger)(remainInterval / YSC_STD_MINUTE) - 60 * hour - 24 * 60 * day;
    NSInteger second = (NSInteger)remainInterval - 60 * minute - 60 * 60 * hour - 24 * 60 * 60 * day;
    
    //--------------------设置components START----------------------------------------
    
    //设置day
    if (YSC_CalendarUnitDay == (YSC_CalendarUnitDay & unitFlags)) {
        [components setDay:day];
    }
    else {
        [components setDay:0];
    }
    //设置hour
    if (YSC_CalendarUnitHour == (YSC_CalendarUnitHour & unitFlags)) {
        NSInteger tempHour = hour;
        if (YSC_CalendarUnitDay != (YSC_CalendarUnitDay & unitFlags)) {
            tempHour += 24 * day;
        }
        [components setHour:tempHour];
    }
    else {
        [components setHour:0];
    }
    //设置minute
    if (YSC_CalendarUnitMinute == (YSC_CalendarUnitMinute & unitFlags)) {
        NSInteger tempMinute = minute;
        if (YSC_CalendarUnitHour != (YSC_CalendarUnitHour & unitFlags)) {
            tempMinute += 60 * hour;
            if (YSC_CalendarUnitDay != (YSC_CalendarUnitDay & unitFlags)) {//只有当hour不存在，才有判断day的必要，下面类似
                tempMinute += 24 * 60 * day;
            }
        }
        [components setMinute:tempMinute];
    }
    else {
        [components setMinute:0];
    }
    //设置second
    if (YSC_CalendarUnitSecond == (YSC_CalendarUnitSecond & unitFlags)) {
        NSInteger tempSecond = second;
        if (YSC_CalendarUnitMinute != (YSC_CalendarUnitMinute & unitFlags)) {
            tempSecond += 60 * minute;
            if (YSC_CalendarUnitHour != (YSC_CalendarUnitHour & unitFlags)) {
                tempSecond += 60 * 60 * hour;
                if (YSC_CalendarUnitDay != (YSC_CalendarUnitDay & unitFlags)) {
                    tempSecond += 24 * 60 * 60 * day;
                }
            }
        }
        [components setSecond:tempSecond];
    }
    else {
        [components setSecond:0];
    }
    //--------------------设置components END----------------------------------------
    
    return components;
}

#pragma mark - Private Methods
/**
 * 以date为基准，计算前推或后移seconds秒后的date
 */
+ (NSDate *)_ysc_dateWithSecondReference:(NSDate *)date second:(long)seconds {
    NSTimeInterval aTimeInterval = [date timeIntervalSinceReferenceDate] + seconds;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
}

@end
