//
//  TestCustomAlertViewViewController.m
//  YSCKitDemo
//
//  Created by Builder on 16/10/12.
//  Copyright © 2016年 Builder. All rights reserved.
//

#import "TestCustomAlertViewViewController.h"

@interface TestCustomAlertViewViewController ()

@end

@implementation TestCustomAlertViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, AUTOLAYOUT_LENGTH(300))];
    customView.backgroundColor = [UIColor blueColor];
    
    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 80, 40)];
    [testButton setTitle:@"Test" forState:UIControlStateNormal];
    testButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:testButton];
    
    [testButton ysc_addTouchUpInsideEventBlock:^(id sender) {
        YSCCustomAlertView *alertView = [YSCCustomAlertView showCustomView:customView style:YSCAlertControllerStyleAlert];
        alertView.isDismissByClickingOutOfArea = YES;
    }];
    
    UIButton *testButton1 = [[UIButton alloc] initWithFrame:CGRectMake(150, 50, 80, 40)];
    [testButton1 setTitle:@"Test1" forState:UIControlStateNormal];
    testButton1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:testButton1];
    
    [testButton1 ysc_addTouchUpInsideEventBlock:^(id sender) {
        [YSCCustomAlertView showCustomView:customView style:YSCAlertControllerStyleActionSheet];
    }];
}

@end
