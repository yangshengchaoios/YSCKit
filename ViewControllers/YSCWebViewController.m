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
@property (strong, nonatomic) NSString *type;

@end

@implementation YSCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *url = Trim(self.params[kParamUrl]);
    NSString *content = Trim(self.params[kParamContent]);
    NSString *method = Trim(self.params[kParamMethod]);
    if ([NSString isUrl:url]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    else if ([NSString isNotEmpty:content]) {
        [self.webView loadHTMLString:content baseURL:nil];
    }
    else if ([NSString isNotEmpty:method]) {
        NSDictionary *params = self.params[kParamParams];
        self.type = params[kParamType];
        if ([NSString isEmpty:self.type] || [NSString isEmpty:method]) {
            [self showResultThenBack:@"参数有误"];
            return;
        }
        self.htmlString = [self cachedObjectForKey:KeyOfCachedHtmlString(self.type)];
        [self laodHtmlWithMethod:method andParams:params];
    }
}

//直接显示html数据
- (void)layoutHtmlString {
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}

#pragma mark - 网络访问
- (void)laodHtmlWithMethod:(NSString *)method andParams:(NSDictionary *)params {
    [self showHUDLoading:@"正在更新..."];
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:method
                  andDictParam:params
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  blockSelf.htmlString = responseObject;
                  [blockSelf saveObject:responseObject forKey:KeyOfCachedHtmlString(blockSelf.type)];
                  [blockSelf layoutHtmlString];
              } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                  [blockSelf showResultThenHide:errorMessage];
                  [blockSelf bk_performBlock:^(id obj) {
                      [blockSelf backViewController];
                  } afterDelay:1];
              }];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.view layoutIfNeeded];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.view layoutIfNeeded];
}

@end
