//
//  XCImagePickerTool.h
//  XCCutImage_demo
//
//  Created by wxc on 14/9/17.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCImagePickerTool : NSObject

//成功选取图片
@property (nonatomic, copy) void (^chooseImageBlock)(UIImage *image);

//取消选取
@property (nonatomic, copy) void (^cancelBlock)();

//标题颜色
@property (nonatomic, strong) UIColor *titleColor;

//选择时取消 按钮的文字颜色
@property (nonatomic, strong) UIColor *pickerCancelColor ;

+ (XCImagePickerTool *)sharedInstance;


/**
 根据长宽比选择图片

 @param presentController 调出控制器的ViewController
 @param sourceType        类型（相机，图片）
 @param allowEdit         是否允许编辑
 @param radio             长宽比例（宽度为全屏,比例过大超出一定范围，宽度减小）
 */
- (void)showImagePickerWithPresentController:(UIViewController*)presentController
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
                                   allowEdit:(BOOL)allowEdit
                                       radio:(CGFloat)radio;

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
                                    cutFrame:(CGRect)cutFrame;

@end
