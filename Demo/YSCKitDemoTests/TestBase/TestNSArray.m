//
//  TestNSArray.m
//  YSCKitDemo
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+YSCKit.h"

#define TEST_PERFORMANCE_NSARRAY    0

@interface TestNSArray : XCTestCase
@property (nonatomic, strong) NSArray *array1;
@property (nonatomic, strong) NSArray *array2;
@property (nonatomic, strong) NSArray *array3;
@property (nonatomic, strong) NSArray *array4;
@property (nonatomic, strong) NSArray *array5;
@property (nonatomic, strong) NSArray *array6;
@property (nonatomic, strong) NSArray *array7;
@property (nonatomic, strong) NSMutableArray *array10;
@property (nonatomic, strong) NSMutableArray *array20;
@end

@implementation TestNSArray

#pragma mark - 数据准备
- (void)setUp {
    [super setUp];
    self.array1 = nil;
    self.array2 = @[];
    self.array3 = @[@"1", @2, @(3)];
    self.array4 = @[@"1", @1, @(1)];
    self.array5 = @[@"1", @"1", @"1"];
    self.array6 = @[@1, @1, @1];
    self.array7 = @[@"Abda", @"B324", @"a90890", @"b", @"1232", @"22234adf", @""];
    
    self.array10 = [NSMutableArray array];
    for (int i = 0; i < 500; i++) {
        [self.array10 addObject:@(i)];
    }
    
    self.array20 = [NSMutableArray array];
    for (int i = 0; i < 600; i++) {
        [self.array20 addObject:@(i)];
    }
}
- (void)tearDown {
    self.array1 = nil;
    self.array2 = nil;
    self.array3 = nil;
    self.array4 = nil;
    self.array5 = nil;
    self.array6 = nil;
    self.array7 = nil;
    self.array10 = nil;
    self.array20 = nil;
    [super tearDown];
}


#pragma mark - 基本功能测试
- (void)test_ysc_isEquals {
    // 判空检测
    XCTAssert([NSArray ysc_isEquals:nil with:self.array1], @"two nil - not passed!");
    XCTAssert( ! [NSArray ysc_isEquals:nil with:self.array2], @"one nil, another empty - not passed!");
    XCTAssert( ! [NSArray ysc_isEquals:nil with:self.array3], @"one nil，another not emtpy - not passed!");
    XCTAssert([NSArray ysc_isEquals:@[] with:self.array2], @"two empty - not passed!");
    XCTAssert( ! [NSArray ysc_isEquals:@[] with:self.array3], @"one empty, another not empty - not passed!");
    
    // 基本数据类型
    NSArray *temp_array1 = @[@"1",@2,@(3)];
    XCTAssert([NSArray ysc_isEquals:temp_array1 with:self.array3], @"");
    NSArray *temp_array2 = @[@2,@"1",@(3)];
    XCTAssert([NSArray ysc_isEquals:temp_array2 with:self.array3], @"");
    NSArray *temp_array4 = @[@2.587654,@(3),@"1"];
    XCTAssert( ! [NSArray ysc_isEquals:temp_array4 with:self.array3], @"");
    NSArray *temp_array5 = @[@1,@(1),@"1"];
    XCTAssert([NSArray ysc_isEquals:temp_array5 with:self.array4], @"");
    XCTAssert( ! [NSArray ysc_isEquals:self.array4 with:self.array5], @"");
    XCTAssert( ! [NSArray ysc_isEquals:self.array5 with:self.array6], @"");
    XCTAssert( ! [NSArray ysc_isEquals:self.array4 with:self.array6], @"");
}
- (void)test_ysc_intersectionArrayBetween {
    XCTAssert( ! [NSArray ysc_intersectionArrayBetween:self.array1 and:nil], @"");
    XCTAssert( ! [NSArray ysc_intersectionArrayBetween:self.array1 and:self.array2], @"");
    XCTAssert( ! [NSArray ysc_intersectionArrayBetween:self.array1 and:self.array3], @"");
    
    NSArray *temp_array1 = @[@"1"];
    NSArray *temp_array2 = @[@"1", @1];
    NSArray *temp_array3 = @[@"", @"a90890"];
    NSArray *common_array1 = [NSArray ysc_intersectionArrayBetween:self.array3 and:self.array4];
    NSArray *common_array2 = [NSArray ysc_intersectionArrayBetween:@[@"1", @1, @(2)] and:self.array4];
    NSArray *common_array3 = [NSArray ysc_intersectionArrayBetween:@[@"",@"a90890", @"234"] and:self.array7];
 
    XCTAssert([NSArray ysc_isEquals:temp_array1 with:common_array1], @"");
    XCTAssert([NSArray ysc_isEquals:temp_array2 with:common_array2], @"");
    XCTAssert([NSArray ysc_isEquals:temp_array3 with:common_array3], @"");
}
- (void)test_ysc_reverseArray {
    XCTAssert( ! [NSArray ysc_reverseArray:self.array1], @"");
    XCTAssert(0 == [NSArray ysc_reverseArray:self.array2].count, @"");
    NSArray *temp_array1 = @[@(3), @(2), @"1"];
    NSArray *temp_array2 = @[@1, @(1), @"1"];
    NSArray *reverse_array1 = [NSArray ysc_reverseArray:self.array3];
    NSArray *reverse_array2 = [NSArray ysc_reverseArray:self.array4];
    XCTAssert([NSArray ysc_isEquals:temp_array1 with:reverse_array1], @"");
    XCTAssert([NSArray ysc_isEquals:temp_array2 with:reverse_array2], @"");
}


#pragma mark - 性能测试
#if TEST_PERFORMANCE_NSARRAY
- (void)test_arrayEquals1 {
    [self measureBlock:^{
        NSSet *set1 = [NSSet setWithArray:self.array10];
        NSSet *set2 = [NSSet setWithArray:self.array20];
        BOOL isSuccess = [set1 isEqualToSet:set2];
    }];
}
/**
 *  数据量大的时候比较费时
 */
//- (void)test_arrayEquals2 {
//    [self measureBlock:^{
//        BOOL isSuccess = YES;
//        for (id item in self.array10) {
//            if ( ! [self.array20 containsObject:item]) {
//                isSuccess = NO;
//                break;
//            }
//        }
//    }];
//}

- (void)test_arrayReverse1 {
    [self measureBlock:^{
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self.array10 count]];
        for (NSInteger i = [self.array10 count] - 1; i >= 0; i--) {
            [resultArray addObject:self.array10[i]];
        }
    }];
}
- (void)test_arrayReverse2 {
    [self measureBlock:^{
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[self.array10 count]];
        [self.array10 enumerateObjectsWithOptions:NSEnumerationReverse
                                usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    [resultArray addObject:obj];
                                }];
    }];
}
- (void)test_arrayReverse3 {
    [self measureBlock:^{
        NSArray *resultArray = [[self.array10 reverseObjectEnumerator] allObjects];
    }];
}
#endif

@end
