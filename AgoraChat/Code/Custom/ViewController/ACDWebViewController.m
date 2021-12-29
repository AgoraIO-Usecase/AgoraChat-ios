//
//  ACDWebViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDWebViewController.h"
#import <Masonry/Masonry.h>

@interface ACDWebViewController ()
@property (nonatomic, strong) WKWebView*  webView;
@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, copy) NSURLRequest* request;
@end

@implementation ACDWebViewController

+ (instancetype)new {
    abort();
}

- (instancetype)init {
    abort();
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    abort();
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    abort();
}


#pragma mark - Initial
- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _request = [NSURLRequest requestWithURL:URL];
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    }
    return self;
}

- (instancetype)initWithURLRequest:(NSURLRequest *)request {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _request = request.copy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_HEX(0xf0f0f0);
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(5.0, 0, 0, 0));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.view);
        make.height.equalTo(@2.0);
    }];
    
    
    [self.webView loadRequest:self.request];
}

- (void)dealloc {
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}

#pragma mark - Getter

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preference = [[WKPreferences alloc]init];
        config.preferences = preference;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) configuration:config];
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView){
        _progressView = UIProgressView.new;
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark -- WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}

@end
