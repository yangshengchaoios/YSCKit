//
//  NSDate+Utilities.m
//  Additions
//
//  Created by Erica Sadun, http://ericasadun.com
//  iPhone Developer's Cookbook, 3.x and beyond
//  BSD License, Use at your own risk
/*
   #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
   ----
   General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej
 */

#import "NSDate+Additions.h"

#define DATE_COMPONENTS (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Additions)


#pragma mark Decomposing Dates

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)nearestHour {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
	return [components hour];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)hour {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components hour];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)minute {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components minute];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)seconds {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components second];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)day {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components day];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)month {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components month];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)week {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components week];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)weekday {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekday];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)nthWeekday  // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components weekdayOrdinal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)year {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return [components year];
}

#pragma mark Relative Dates

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithDaysFromNow:(NSUInteger)days {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger)days {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_DAY * days;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateNow {
    return [NSDate date];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateTomorrow {
	return [NSDate dateWithDaysFromNow:1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateYesterday {
	return [NSDate dateWithDaysBeforeNow:1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateBeforeYesterday {
    return [NSDate dateWithDaysBeforeNow:2];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithHoursFromNow:(NSUInteger)dHours {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger)dHours {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithMinutesFromNow:(NSUInteger)dMinutes {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger)dMinutes {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}


#pragma mark convert to date
+ (NSDate *)dateFromTimeStamp:(NSString *)timeStamp {
	return [self dateFromTimeInterval:[timeStamp longLongValue]];
}

+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        timeInterval = timeInterval / 1000.0f;
    }
	return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	return [dateFormatter dateFromString:string];
}

#pragma mark Comparing Dates

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return (([components1 year] == [components2 year]) &&
	        ([components1 month] == [components2 month]) &&
	        ([components1 day] == [components2 day]));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isToday {
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isTomorrow {
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isYesterday {
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isBeforeYesterday {
    return [self isEqualToDateIgnoringTime:[NSDate dateBeforeYesterday]];
}

// This hard codes the assumption that a week is 7 days
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isSameWeekAsDate:(NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];

	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if ([components1 week] != [components2 week]) return NO;

	// Must have a time interval under 1 week. Thanks @aclark
	return (abs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isThisWeek {
	return [self isSameWeekAsDate:[NSDate date]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isNextWeek {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLastWeek {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameYearAsDate:newDate];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isSameYearAsDate:(NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
	return ([components1 year] == [components2 year]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isThisYear {
	return [self isSameWeekAsDate:[NSDate date]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isNextYear {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

	return ([components1 year] == ([components2 year] + 1));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLastYear {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];

	return ([components1 year] == ([components2 year] - 1));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isEarlierThanDate:(NSDate *)aDate {
	return ([self earlierDate:aDate] == self);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLaterThanDate:(NSDate *)aDate {
	return ([self laterDate:aDate] == self);
}

#pragma mark Adjusting Dates

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateByAddingDays:(NSUInteger)dDays {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays {
	return [self dateByAddingDays:(dDays * -1)];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateByAddingHours:(NSUInteger)dHours {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours {
	return [self dateByAddingHours:(dHours * -1)];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes {
	return [self dateByAddingMinutes:(dMinutes * -1)];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateAtStartOfDay {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	return [CURRENT_CALENDAR dateFromComponents:components];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate {
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark Retrieving Intervals

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)minutesAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_MINUTE);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)minutesBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_MINUTE);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)hoursAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_HOUR);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)hoursBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_HOUR);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)daysAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger)(ti / D_DAY);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)daysBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger)(ti / D_DAY);
}


#pragma mark - format the date to string
///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)timeStamp {
    return [NSString stringWithFormat:@"%.0f", [self timeIntervalSince1970]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	return [dateFormatter stringFromDate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)chineseMonth {
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

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)constellation {
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
	/*
	   摩羯座 12月22日------1月19日
	   水瓶座 1月20日-------2月18日
	   双鱼座 2月19日-------3月20日
	   白羊座 3月21日-------4月19日
	   金牛座 4月20日-------5月20日
	   双子座 5月21日-------6月21日
	   巨蟹座 6月22日-------7月22日
	   狮子座 7月23日-------8月22日
	   处女座 8月23日-------9月22日
	   天秤座 9月23日------10月23日
	   天蝎座 10月24日-----11月21日
	   射手座 11月22日-----12月21日
	 */
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

+ (NSString *)StringFromTimeStamp:(NSString *)timeStamp withFormat:(NSString *)format {
    return [[self dateFromTimeStamp:timeStamp] stringWithFormat:format];
}

#pragma mark - private methods

@end
