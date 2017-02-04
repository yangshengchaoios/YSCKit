//
//  TestNSDictionary.m
//  YSCKitDemo
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+YSCKit.h"

@interface TestNSDictionary : XCTestCase

@end

@implementation TestNSDictionary

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_ysc_sortedKeyAndJoinedString {
    NSDictionary *dict = @{@"key3" : @1,
                           @"&89" : @"1.34",
                           @":>sdf)(&" : @"3432",
                           @"" : @"123",
                           @"1" : @"1345",
                           @"key2" : @"2345"};
    NSString *sorted = [dict ysc_sortedKeyAndJoinedString];
    NSLog(@"sorted=%@", sorted);
    
    NSDictionary *dict1 = @{@"key3" : @"1",
                            @"&89" : @1.34,
                            @":>sdf)(&" : @"3432",
                            @"1" : @"1345",
                            @"" : @"123",
                            @"key2" : @"2345"};
    NSString *sorted1 = [dict1 ysc_sortedKeyAndJoinedString];
    NSLog(@"sorted1=%@", sorted1);
    
    XCTAssert([sorted isEqualToString:sorted1], @"");
    
}

@end
