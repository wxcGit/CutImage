//
//  XCImageCutViewController.h
//  DuihuaApp
//
//  Created by wxc on 5/9/17.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 屏幕高度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 屏幕宽度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

/**
 图片裁剪
 */
@class XCImageCutViewController;

@protocol  XCImageCutViewControllerDelegate <NSObject>


/**
 裁剪完成

 @param controller controller
 @param editImage  裁剪完的图片
 */
- (void)imageCutViewController:(XCImageCutViewController*)controller finishedEidtImage:(UIImage*)editImage;


/**
 取消裁剪

 @param controller controller
 */
- (void)imageCutViewControllerDidCancel:(XCImageCutViewController*)controller;

@end

@interface XCImageCutViewController : UIViewController

@property (nonatomic, strong) UIColor *cutBorderColor;//边框颜色
@property (nonatomic, assign) CGRect cutFrame;//边框位置
@property (nonatomic, assign) CGFloat maxScale;//最大缩放比例
@property (nonatomic, strong) UIImage *originalImage;//原图像
@property (nonatomic, assign) CGFloat cutBorderWidth;//边框宽度
@property (nonatomic, strong) UIColor *cutCoverColor;//周围覆盖层颜色

@property (nonatomic, weak) id<XCImageCutViewControllerDelegate> delegate;

@end
