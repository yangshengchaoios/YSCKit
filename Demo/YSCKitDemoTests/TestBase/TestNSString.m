//
//  TestNSString.m
//  YSCKitDemo
//
//  Created by Builder on 16/7/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+YSCKit.h"

@interface TestNSString : XCTestCase
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *pattern1;
@property (nonatomic, strong) NSString *pattern2;
@end

@implementation TestNSString

- (void)setUp {
    [super setUp];
    self.source = @"asfdafsdweabcABCadsf72q938whabd23498^%$";
    self.pattern1 = @"abc";
    self.pattern2 = @"acdasdfasdf";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.source = nil;
    self.pattern1 = nil;
    self.pattern2 = nil;
    [super tearDown];
}

- (void)test_ysc_matchesByRegex1 {
    [self measureBlock:^{
        NSArray *array1 = [self.source ysc_matchesByRegex:self.pattern1 options:NSRegularExpressionCaseInsensitive];
        NSArray *array2 = [self.source ysc_matchesByRegex:self.pattern2 options:NSRegularExpressionCaseInsensitive];
    }];
}

@end
