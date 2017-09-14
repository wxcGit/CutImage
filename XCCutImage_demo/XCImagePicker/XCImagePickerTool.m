//
//  XCImagePickerTool.m
//  XCCutImage_demo
//
//  Created by wxc on 14/9/17.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import "XCImagePickerTool.h"
#import "XCImageCutViewController.h"

@interface XCImagePickerTool ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,XCImageCutViewControllerDelegate>

@property (nonatomic, strong) UIViewController *presentController;

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, assign) BOOL allowEdit;
@property (nonatomic, assign) CGRect cutFrame;

@end

@implementation XCImagePickerTool

+ (XCImagePickerTool *)sharedInstance {
    static XCImagePickerTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XCImagePickerTool alloc]init];
    });
    
    return manager;
}

/**
 根据长宽比选择图片
 
 @param presentController 调出控制器的ViewController
 @param sourceType        类型（相机，图片）
 @param allowEdit         是否允许编辑
 @param radio             长宽比例（宽度为全屏）
 */
- (void)showImagePickerWithPresentController:(UIViewController*)presentController
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
                                   allowEdit:(BOOL)allowEdit
                                       radio:(CGFloat)radio
{
    CGRect cutFrame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH * radio);
    
    CGFloat MaxHeight = SCREEN_HEIGHT - 64 - 70;
    if (CGRectGetHeight(cutFrame) > MaxHeight) {
        cutFrame = CGRectMake((SCREEN_WIDTH - MaxHeight/radio)/2, 64, MaxHeight/radio, MaxHeight);
    }
    
    [self showImagePickerWithPresentController:presentController sourceType:sourceType allowEdit:allowEdit cutFrame:cutFrame];
}

/**
 根据长宽比选择图片
 
 @param presentController 调出控制器的ViewController
 @param sourceType        类型（相机，图片）
 @param allowEdit         是否允许编辑
 @param cutFrame          自定义裁剪位置
 */

- (void)showImagePickerWithPresentController:(UIViewController*)presentController
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
                                   allowEdit:(BOOL)allowEdit
                                    cutFrame:(CGRect)cutFrame
{
    self.presentController = presentController;
    self.allowEdit = allowEdit;
    self.cutFrame = cutFrame;

    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.sourceType = sourceType;
    
    [_picker setAllowsEditing:NO];
    
    if (self.titleColor){
        [_picker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:self.titleColor}];
    }
    if (self.pickerCancelColor) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIBarButtonItem *item = _picker.navigationBar.topItem.rightBarButtonItem;
            item.tintColor = self.pickerCancelColor;
        });
    }
    [self.presentController presentViewController: _picker animated: YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = nil;
    image = info[UIImagePickerControllerOriginalImage];
    image = [XCImagePickerTool fixOriginalImage:image];
    
    if (!_allowEdit) {
        if (_chooseImageBlock ) {
            _chooseImageBlock(image);
        }
    }else{
        image = info[UIImagePickerControllerOriginalImage];
        XCImageCutViewController *cutVc = [[XCImageCutViewController alloc]init];
        cutVc.originalImage = image;
        cutVc.delegate = self;
        cutVc.cutFrame = self.cutFrame;
        [picker pushViewController:cutVc animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_cancelBlock) {
            _cancelBlock();
        }
    }];
}

/**
 裁剪完成
 
 @param controller controller
 @param editImage  裁剪完的图片
 */
- (void)imageCutViewController:(XCImageCutViewController*)controller finishedEidtImage:(UIImage*)editImage
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
    if (_chooseImageBlock ) {
        _chooseImageBlock(editImage);
    }
}


/**
 取消裁剪
 
 @param controller controller
 */
- (void)imageCutViewControllerDidCancel:(XCImageCutViewController*)controller
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
}


/**
 修正图片，使其显示方向正确
 */
+ (UIImage *)fixOriginalImage:(UIImage *)originalImage {
    if (originalImage.imageOrientation == UIImageOrientationUp) return originalImage;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (originalImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, originalImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, originalImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (originalImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, originalImage.size.width, originalImage.size.height,
                                             CGImageGetBitsPerComponent(originalImage.CGImage), 0,
                                             CGImageGetColorSpace(originalImage.CGImage),
                                             CGImageGetBitmapInfo(originalImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (originalImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,originalImage.size.height,originalImage.size.width), originalImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,originalImage.size.width,originalImage.size.height), originalImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
