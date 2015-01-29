//
//  NSDate+Additions.h
//  Additions
//
//  Created by Erica Sadun, http://ericasadun.com
//  iPhone Developer's Cookbook, 3.x and beyond
//  BSD License, Use at your own risk
//  FORMATED!
//


#import <Foundation/Foundation.h>

#define DateFormat1 @"yyyy-MM-dd HH:mm:ss"
#define DateFormat2 @"yyyy.MM.dd HH:mm"
#define DateFormat3 @"yyyy-MM-dd"
#define DateFormat4 @"yyyy.MM.dd"

#define D_MINUTE    60
#define D_HOUR      3600
#define D_DAY       86400
#define D_WEEK      604800
#define D_YEAR      31556926

@interface NSDate (Additions)

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

// Relative dates from the current date
+ (NSDate *)dateNow;
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateBeforeYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSUInteger)days;
+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger)days;
+ (NSDate *)dateWithHoursFromNow:(NSUInteger)dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger)dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSUInteger)dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger)dMinutes;

// convert to date
+ (NSDate *)dateFromTimeStamp:(NSString *)timeStamp;
+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;
- (BOOL)isBeforeYesterday;
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;
- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

// Adjusting dates
- (NSDate *)dateByAddingDays:(NSUInteger)dDays;
- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays;
- (NSDate *)dateByAddingHours:(NSUInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateAtStartOfDay;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;

// format the date to string
- (NSString *)timeStamp;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)chineseMonth; //汉语月份
- (NSString *)constellation;//星座
+ (NSString *)StringFromTimeStamp:(NSString *)timeStamp withFormat:(NSString *)format;

@end
