//
//  WCCWebView.m
//  HybridCameraDemo
//
//  Created by Lision on 2017/10/12.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "WCCWebView.h"

@interface WCCWebView ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WCCWebView

#pragma mark - Interface
+ (UIWindow *)sharedWebWindow {
    static UIWindow *__sharedWebWindow;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedWebWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        __sharedWebWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        __sharedWebWindow.backgroundColor = [UIColor clearColor];
        __sharedWebWindow.rootViewController = [UIViewController new];
        __sharedWebWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        __sharedWebWindow.userInteractionEnabled = YES;
        __sharedWebWindow.windowLevel = UIWindowLevelAlert;
    });
    
    return __sharedWebWindow;
}

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    
    return self;
}

- (instancetype)initWithLocalURL:(NSString *)localURL {
    if (self = [super init]) {
        NSURL *fileURL = [NSURL fileURLWithPath:localURL];
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:fileURL];
    }
    
    return self;
}

- (void)show {
    [[self.class sharedWebWindow].subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [[self.class sharedWebWindow] addSubview:self];
    [[self.class sharedWebWindow] makeKeyAndVisible];
    [self.class sharedWebWindow].hidden = NO;
    [[self.class sharedWebWindow] bringSubviewToFront:self];
}

- (void)dismiss {
    [self.class sharedWebWindow].hidden = YES;
    [[UIApplication sharedApplication].delegate.window makeKeyWindow];
}

- (UIWebView *)webView {
    if (!_webView) {
        // 设置网页的配置文件
        _webView = [[UIWebView alloc] initWithFrame:[self.class sharedWebWindow].rootViewController.view.bounds];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.bouncesZoom = NO;
        [self addSubview:_webView];
    }
    
    return _webView;
}

@end
