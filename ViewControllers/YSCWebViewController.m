//
//  ZDYKWebViewController.m
//  HYTCosmetic
//
//  Created by yangshengchao on 14/12/22.
//  Copyright (c) 2014年 ZhongDaYunKe. All rights reserved.
//

#import "YSCWebViewController.h"

#define KeyOfCachedHtmlString(type)       [NSString stringWithFormat:@"KeyOfCachedHtmlString_%@", (type)]

@interface YSCWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *htmlString;

@end

@implementation YSCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *url = Trim(self.params[kParamUrl]);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
   
}

//直接显示html数据
- (void)layoutHtmlString {
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view layoutIfNeeded];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.view layoutIfNeeded];
}

@end
