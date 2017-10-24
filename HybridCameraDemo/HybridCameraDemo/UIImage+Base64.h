//
//  UIImage+Base64.h
//  HybridCameraDemo
//
//  Created by Lision on 2017/10/12.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Base64)

- (NSData *)compressDatatoMaxPicSize:(NSInteger)maxPicSize;
- (NSString *)getBase64DataStr;

+ (UIImage *)getImageFromBase64:(NSString *)imgBase64;
+ (UIImage *)getImageWithView:(UIView *)view;

@end
