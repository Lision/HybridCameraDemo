//
//  ViewController.m
//  HybridCameraDemo
//
//  Created by Lision on 2017/10/24.
//  Copyright © 2017年 Lision. All rights reserved.
//

#import "ViewController.h"
#import "WCCWebView.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIImage+Base64.h"

////// JSDelegate ////////////////////////////////////
@protocol JSDelegate <JSExport>

- (void)getImage:(id)parameter;

@end

////// ViewController ////////////////////////////////////
@interface ViewController () <JSDelegate, UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) WCCWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, copy) NSString *base64;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imagePickerController.cameraOverlayView = self.cameraView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.webView show];
}

- (void)showCameraAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关, 开启相机功能" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.webView.hidden = NO;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        self.webView.hidden = NO;
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:NULL];
    self.webView.hidden = YES;
}

- (void)showAlbumAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"照片权限未开启" message:@"相机权限未开启，请进入系统【设置】>【隐私】>【照片】中打开开关, 开启相机功能" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.webView.hidden = NO;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"立即开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        self.webView.hidden = NO;
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:NULL];
    self.webView.hidden = YES;
}

#pragma mark - LazyLoad
- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = NO;
        _imagePickerController.showsCameraControls = NO;
        _imagePickerController.toolbarHidden = YES;
        _imagePickerController.navigationBarHidden = YES;
        _imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(1.25,1.25);
        CGSize screenBounds = [UIScreen mainScreen].bounds.size;
        CGFloat cameraAspectRatio = 4.0f / 3.0f;
        CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
        CGFloat scale = screenBounds.height / camViewHeight;
        _imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
        _imagePickerController.cameraViewTransform = CGAffineTransformScale(_imagePickerController.cameraViewTransform, scale, scale);
    }
    
    return _imagePickerController;
}

- (UIView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_cameraView];
    }
    
    return _cameraView;
}

- (WCCWebView *)webView {
    if (!_webView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        _webView = [[WCCWebView alloc] initWithLocalURL:path ? : @""];
        _webView.frame = self.view.bounds;
        _webView.webView.delegate = self;
    }
    
    return _webView;
}

#pragma mark - JSDelegate
- (void)getImage:(id)parameter {
    [self takePicture];
}

- (void)takePicture {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagePickerController takePicture];
    });
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"iosDelegate"] = self;
    __weak typeof(self) weakSelf = self;
    self.jsContext[@"SwitchCamera"] = ^(NSInteger parameter){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (parameter == 1) {
                [weakSelf openCamera];
            } else {
                [weakSelf closeCamera];
            }
        });
    };
    self.jsContext[@"SavePicture"] = ^(NSString *picBase64) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage getImageFromBase64:picBase64];
            if (!image) {
                NSLog(@"获取 image 失败");
                return;
            }
            
            [weakSelf saveImage:image];
        });
    };
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception){
        context.exception = exception;
        NSLog(@"获取 self.jsContext 异常信息：%@", exception);
    };
}

- (void)openCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [self showCameraAlert];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                JSValue *jsValue = self.jsContext[@"getSwitchCameraResult"];
                [jsValue callWithArguments:@[@"1"]];
            });
            [self presentViewController:self.imagePickerController animated:NO completion:nil];
        } else {
            NSLog(@"该设备没有相机");
        }
    }
}

- (void)closeCamera {
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            JSValue *jsValue = self.jsContext[@"getSwitchCameraResult"];
            [jsValue callWithArguments:@[@"0"]];
        });
    }];
}

- (void)saveImage:(UIImage *)image {
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusDenied || authorStatus == PHAuthorizationStatusRestricted) {
        [self showAlbumAlert];
    } else {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        self.photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSString *str = [self.photo getBase64DataStr];
        self.base64 = str;
        dispatch_async(dispatch_get_main_queue(), ^{
            JSValue *jsValue = self.jsContext[@"TakePicture"];
            [jsValue callWithArguments:@[str ? : @""]];
        });
    }
}

@end
