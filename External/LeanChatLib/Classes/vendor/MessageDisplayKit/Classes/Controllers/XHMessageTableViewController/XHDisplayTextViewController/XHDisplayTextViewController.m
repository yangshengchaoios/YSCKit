//
//  XHDisplayTextViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-6.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHDisplayTextViewController.h"
#import "CDEmotionUtils.h"

@interface XHDisplayTextViewController ()

@property (nonatomic, weak) UITextView *displayTextView;

@end

@implementation XHDisplayTextViewController

- (UITextView *)displayTextView {
    if (!_displayTextView) {
        UITextView *displayTextView = [[UITextView alloc] initWithFrame:self.view.frame];
        displayTextView.font = [UIFont systemFontOfSize:16.0f];
        displayTextView.textColor = [UIColor blackColor];
        displayTextView.userInteractionEnabled = YES;
        displayTextView.editable = NO;
        displayTextView.backgroundColor = [UIColor clearColor];
        displayTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        [self.view addSubview:displayTextView];
        _displayTextView = displayTextView;
    }
    return _displayTextView;
}

- (void)setMessage:(AVIMTypedMessage *)message {
    _message = message;
    self.displayTextView.text = [CDEmotionUtils emojiStringFromString:[message text]];
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedStringFromTable(@"TextDetail", @"MessageDisplayKitString", @"文本消息");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.displayTextView = nil;
}

@end
