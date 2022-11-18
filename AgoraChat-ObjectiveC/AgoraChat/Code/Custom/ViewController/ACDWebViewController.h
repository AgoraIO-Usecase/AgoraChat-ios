//
//  ACDWebViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDWebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong,readonly) WKWebView*  webView;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithURLString:(NSString *)URLString NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithURLRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
