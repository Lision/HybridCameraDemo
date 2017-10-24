//
//  UIImage+Base64.m
//  HybridCameraDemo
//
//  Created by Lision on 2017/10/12.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "UIImage+Base64.h"

static NSString * const base64Prefix = @"data:image/jpeg;base64,";

@implementation UIImage (Base64)

- (NSData *)compressDatatoMaxPicSize:(NSInteger)maxPicSize {
    CGFloat compression = 0.7f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    while ([imageData length] > maxPicSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(self, compression);
    }
    
    return imageData;
}

- (NSString *)getBase64DataStr {
    NSData *imageData = UIImageJPEGRepresentation(self, 0.7f);
    NSString *dataStr = [imageData base64EncodedStringWithOptions:0];
    
    return [NSString stringWithFormat:@"%@%@", base64Prefix, dataStr];
}

+ (UIImage *)getImageFromBase64:(NSString *)imgBase64 {
    if (!imgBase64) {
        return nil;
    }
    
    if ([imgBase64 hasPrefix:base64Prefix]) {
        imgBase64 = [imgBase64 substringFromIndex:base64Prefix.length];
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:imgBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:data];
    
    return image;
}

+ (UIImage *)getImageWithView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
