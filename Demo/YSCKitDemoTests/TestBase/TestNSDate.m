//
//  TestNSDate.m
//  YSCKitDemo
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+YSCKit.h"

@interface TestNSDate : XCTestCase

@end

@implementation TestNSDate

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// 测试一年中所有日期的星座
- (void)test_ysc_constellation {
    NSMutableArray *constellationStandardArray = [NSMutableArray array];
    [constellationStandardArray addObject:@{@"摩羯座" : @[@"12月22日",@"1月19日"]}];
    [constellationStandardArray addObject:@{@"水瓶座" : @[@"1月20日",@"2月18日"]}];
    [constellationStandardArray addObject:@{@"双鱼座" : @[@"2月19日",@"3月20日"]}];
    [constellationStandardArray addObject:@{@"白羊座" : @[@"3月21日",@"4月19日"]}];
    [constellationStandardArray addObject:@{@"金牛座" : @[@"4月20日",@"5月20日"]}];
    [constellationStandardArray addObject:@{@"双子座" : @[@"5月21日",@"6月21日"]}];
    [constellationStandardArray addObject:@{@"巨蟹座" : @[@"6月22日",@"7月22日"]}];
    [constellationStandardArray addObject:@{@"狮子座" : @[@"7月23日",@"8月22日"]}];
    [constellationStandardArray addObject:@{@"处女座" : @[@"8月23日",@"9月22日"]}];
    [constellationStandardArray addObject:@{@"天秤座" : @[@"9月23日",@"10月23日"]}];
    [constellationStandardArray addObject:@{@"天蝎座" : @[@"10月24日",@"11月21日"]}];
    [constellationStandardArray addObject:@{@"射手座" : @[@"11月22日",@"12月21日"]}];
    
    for (NSDictionary *item in constellationStandardArray) {
        NSString *name = item.allKeys[0];
        NSArray *values = item[name];
        NSDate *startDate = [NSDate ysc_dateFromString:values[0] withFormat:kDateFormat8];
        NSDate *endDate = [NSDate ysc_dateFromString:values[1] withFormat:kDateFormat8];
        NSDate *tempDate = startDate;
        while ( ! [tempDate ysc_isLaterThanDate:endDate]) {
            NSString *constellation = [tempDate ysc_constellation];
            XCTAssert([name isEqualToString:constellation], @"");
            tempDate = [tempDate ysc_dateAfterDays:1];
        }
    }
}
// 测试一年所有日期的星期几
- (void)test_ysc_chineseWeekDay {
    NSDate *startDate = [NSDate ysc_dateFromString:@"2016-01-01" withFormat:kDateFormat3];
    NSDate *endDate = [NSDate ysc_dateFromString:@"2016-12-31" withFormat:kDateFormat3];
    NSInteger i = 0;
    NSArray *weekDayArray = @[@"星期五", @"星期六", @"星期日", @"星期一", @"星期二", @"星期三", @"星期四"];
    while ( ! [startDate ysc_isLaterThanDate:endDate]) {
        NSString *weekDay = weekDayArray[i % 7];
        XCTAssert([weekDay isEqualToString:[startDate ysc_chineseWeekDay]], @"");
        startDate = [startDate ysc_dateAfterDays:1];
        i++;
    }
}
// 测试两个时间点之间的间隔
- (void)test_ysc_componentsBetweenDates {
    NSDate *startDate = [NSDate ysc_dateFromString:@"2016-05-01 12:09:56" withFormat:kDateFormat1];
    NSDate *endDate = [NSDate ysc_dateFromString:@"2017-03-29 23:59:59" withFormat:kDateFormat1];
    NSDateComponents *component1 = [NSDate ysc_componentsFromDate:startDate toDate:endDate];
    NSDateComponents *component2 = [NSDate ysc_componentsFromDate1:startDate toDate:endDate];
    XCTAssert(component1.day == component2.day &&
              component1.hour == component2.hour &&
              component1.minute == component2.minute &&
              component1.second == component2.second,
              @"");
}
// 测试过去了多长时间
- (void)test_ysc_timePassed {
    // test ysc_timePassedByStartDate
    for (int i = 0; i < 60; i++) {
        XCTAssert([@"刚刚" isEqualToString:[NSDate ysc_timePassedByStartDate:[NSDate dateWithTimeIntervalSinceNow:-i]]], @"");
    }
    for (int i = 1; i < 60; i++) {
        NSString *text = [NSString stringWithFormat:@"%d分钟前", i];
        XCTAssert([text isEqualToString:[NSDate ysc_timePassedByStartDate:[NSDate dateWithTimeIntervalSinceNow:-i * 60]]], @"");
    }
    for (int i = 1; i < 24; i++) {
        NSString *text = [NSString stringWithFormat:@"%d小时前", i];
        XCTAssert([text isEqualToString:[NSDate ysc_timePassedByStartDate:[NSDate dateWithTimeIntervalSinceNow:-i * 60 * 60]]], @"");
    }
    for (int i = 1; i < 30; i++) {
        NSString *text = [NSString stringWithFormat:@"%d天前", i];
        XCTAssert([text isEqualToString:[NSDate ysc_timePassedByStartDate:[NSDate dateWithTimeIntervalSinceNow:-i * 60 * 60 * 24]]], @"");
    }
    
    // test ysc_timePassedByStartDate1
    NSDate *startDate = [NSDate ysc_dateFromString:@"2015-05-01 12:09:56" withFormat:kDateFormat1];
    NSDate *endDate = [NSDate ysc_dateFromString:@"2017-03-29 23:59:59" withFormat:kDateFormat1];
    while ( ! [startDate ysc_isLaterThanDate:endDate]) {
        NSString *passed = [NSDate ysc_timePassedByStartDate1:startDate];
        if ( ! [startDate ysc_isThisYear]) {
            XCTAssert([passed isEqualToString:[startDate ysc_stringWithFormat:kDateFormat7]], @"");
        }
        else {
            NSString *temp = @"";
            if ([startDate ysc_isToday]) {
                temp = [NSString stringWithFormat:@"今天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
            }
            else if ([startDate ysc_isYesterday]) {
                temp = [NSString stringWithFormat:@"昨天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
            }
            else if ([startDate ysc_isBeforeYesterday]) {
                temp = [NSString stringWithFormat:@"前天 %@", [startDate ysc_stringWithFormat:kDateFormat13]];
            }
            else {
                temp = [startDate ysc_stringWithFormat:kDateFormat15];
            }
            XCTAssert([passed isEqualToString:temp], @"");
        }
        startDate = [startDate ysc_dateAfterDays:1];
    }
}
// 测试基本方法
- (void)test_ysc_baseDate {
    NSDate *nowDate = CURRENT_DATE;
    NSDate *twoDaysAfterNow = [nowDate ysc_dateAfterDays:2];
    XCTAssert([twoDaysAfterNow ysc_isAfterTomorrow], @"");
    
}

@end
