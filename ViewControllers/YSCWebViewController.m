//
//  ZDYKWebViewController.m
//  HYTCosmetic
//
//  Created by yangshengchao on 14/12/22.
//  Copyright (c) 2014年 ZhongDaYunKe. All rights reserved.
//

#import "YSCWebViewController.h"

#define KeyOfCachedHtmlString(type)       [NSString stringWithFormat:@"KeyOfCachedHtmlString_%@", (type)]

@interface YSCWebViewController () <UIWebViewDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) NSURLRequest *request;
@property (assign, nonatomic) BOOL authenticated;

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
        [self layoutHtmlString];
        [self laodHtmlWithMethod:method andParams:params];
    }
}

//直接显示html数据
- (void)layoutHtmlString {
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}

#pragma mark - 网络访问
- (void)laodHtmlWithMethod:(NSString *)method andParams:(NSDictionary *)params {
    if ([NSString isEmpty:self.htmlString]) {
        [self showHUDLoading:@"正在更新..."];
    }
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:method
                  andDictParam:params
                     modelName:nil
              requestSuccessed:^(id responseObject) {
                  [blockSelf hideHUDLoading];
                  blockSelf.htmlString = responseObject;
                  [blockSelf saveObject:responseObject forKey:KeyOfCachedHtmlString(blockSelf.type)];
                  [blockSelf layoutHtmlString];
              } requestFailure:^(ErrorType errorType, NSError *error) {
                  if ([NSString isEmpty:blockSelf.htmlString]) {
                      NSString *errMsg = [YSCCommonUtils ResolveErrorType:errorType andError:error];
                      [UIView showResultThenHideOnWindow:errMsg];
                  }
              }];
}

#pragma mark - UIWebViewDelegate
// Note: This method is particularly important. As the server is using a self signed certificate,
// we cannot use just UIWebView - as it doesn't allow for using self-certs. Instead, we stop the
// request in this method below, create an NSURLConnection (which can allow self-certs via the delegate methods
// which UIWebView does not have), authenticate using NSURLConnection, then use another UIWebView to complete
// the loading and viewing of the page. See connection:didReceiveAuthenticationChallenge to see how this works.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; {
    NSString *scheme = [[request URL] scheme];
    if ([scheme isEqualToString:@"https"]) {
        //如果是https:的话，那么就用NSURLConnection来重发请求。从而在请求的过程当中吧要请求的URL做信任处理。
        if (NO == self.authenticated) {
            self.request = request;
            NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
            [self.webView stopLoading];
            return NO;
        }
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHUDLoadingOnView:self.webView];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (isNotEmpty(title)) {
        self.navigationItem.title = title;
    }
    [self.view layoutIfNeeded];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideHUDLoadingOnView:self.webView];
    [self.view layoutIfNeeded];
}

#pragma mark - NURLConnection delegate
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURL *baseURL = [self.request URL];
        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response; {
    [connection cancel];
    self.authenticated = YES;
    [self showHUDLoading:@"网页加载中" onView:self.webView];
    [self.webView loadRequest:self.request];
}


@end
