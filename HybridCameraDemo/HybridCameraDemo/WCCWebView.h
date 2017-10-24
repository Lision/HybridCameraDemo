//
//  WCCWebView.h
//  HybridCameraDemo
//
//  Created by Lision on 2017/10/12.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCCWebView : UIView

@property (nonatomic, strong, readonly) UIWebView *webView;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURL:(NSString *)url;
- (instancetype)initWithLocalURL:(NSString *)localURL;

- (void)show;
- (void)dismiss;

+ (UIWindow *)sharedWebWindow;

@end

NS_ASSUME_NONNULL_END
