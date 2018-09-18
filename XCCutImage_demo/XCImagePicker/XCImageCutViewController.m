//
//  XCImageCutViewController.m
//  DuihuaApp
//
//  Created by wxc on 5/9/17.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import "XCImageCutViewController.h"

@interface XCImageCutViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *showImageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *borderView;

//选取取消按钮
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation XCImageCutViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self xc_setupController];
    }
    
    return self;
}

/**
 设置默认值
 */
- (void)xc_setupController
{
    _cutFrame = CGRectMake(0, (SCREEN_HEIGHT - SCREEN_WIDTH) / 2, SCREEN_WIDTH, SCREEN_WIDTH);
    _cutBorderColor = [UIColor whiteColor];
    _maxScale = 3;
    _cutBorderWidth = 0.5;
    _cutCoverColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self xc_initSubViews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark UI
/**
 初始化view
 */
- (void)xc_initSubViews
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.borderView];
    [self setCoverView];
    [self.view addSubview:self.confirmButton];
    [self.view addSubview:self.cancelButton];
}

- (UIScrollView*)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled=YES; //是否支持多点触控
        _scrollView.minimumZoomScale = 1.0;  //表示与原图片最小的比例
        _scrollView.maximumZoomScale = _maxScale; //表示与原图片最大的比例
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.clipsToBounds = NO;
        _scrollView.contentInset = UIEdgeInsetsMake(_cutFrame.origin.y, _cutFrame.origin.x, SCREEN_HEIGHT - _cutFrame.origin.y - _cutFrame.size.height, SCREEN_WIDTH -  _cutFrame.origin.x - _cutFrame.size.width);
        [_scrollView addSubview:self.showImageView];
    }
    
    return _scrollView;
}

- (UIImageView*)showImageView
{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc]init];
        if (_originalImage) {
            _showImageView.image = _originalImage;
            _showImageView.frame = CGRectMake(0, 0, _cutFrame.size.width, _cutFrame.size.width * _originalImage.size.height / _originalImage.size.width);
            
            if (_showImageView.frame.size.height < _cutFrame.size.height) {
                _showImageView.frame = CGRectMake(0, 0,_cutFrame.size.height * _originalImage.size.width / _originalImage.size.height, _cutFrame.size.height);
            }
            
            _scrollView.contentSize = CGSizeMake(_cutFrame.size.width, _cutFrame.size.height);
            
            //调节图片位置
            if (_showImageView.frame.size.height > _scrollView.contentSize.height) {
                _scrollView.contentSize = CGSizeMake(_cutFrame.size.width, _showImageView.frame.size.height);
            }
            
            //调节图片位置
            if (_showImageView.frame.size.width > _scrollView.contentSize.width) {
                _scrollView.contentSize = CGSizeMake( _showImageView.frame.size.width, _cutFrame.size.height);
            }
        }
    }
    
    return _showImageView;
}

- (UIView*)borderView
{
    if (!_borderView) {
        _borderView = [[UIView alloc]initWithFrame:_cutFrame];
        _borderView.backgroundColor = [UIColor clearColor];
        _borderView.layer.borderWidth = _cutBorderWidth;
        _borderView.layer.borderColor = _cutBorderColor.CGColor;
        _borderView.userInteractionEnabled = NO;
    }
    
    return _borderView;
}

- (UIButton*)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 60, 60, 40)];
        [_confirmButton setTitle:@"选取" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _confirmButton;
}

- (UIButton*)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60, 60, 40)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}


/**
 覆盖层
 */
- (void)setCoverView
{
    CGMutablePathRef path = CGPathCreateMutableCopy([UIBezierPath bezierPathWithRect:self.view.bounds].CGPath);
    
    UIBezierPath *cutBezierPath = [UIBezierPath bezierPathWithRect:_cutFrame];
    cutBezierPath.lineWidth = self.cutBorderWidth;
    
    CGMutablePathRef cutPath = CGPathCreateMutableCopy(cutBezierPath.CGPath);
    CGPathAddPath(path, nil, cutPath);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = path;
    shapeLayer.fillColor = self.cutCoverColor.CGColor;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    [self.view.layer addSublayer:shapeLayer];
    
    CGPathRelease(cutPath);
    CGPathRelease(path);
}

/**
 裁剪照片
 
 @return 图片
 */
-(UIImage *)getCutImage{
    //算出截图位置相对图片的坐标
    CGRect rect = [self.view convertRect:_cutFrame toView:_showImageView];
    CGFloat scale = _originalImage.size.width / _showImageView.frame.size.width *
    _showImageView.transform.a;
    CGRect myImageRect= CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(_originalImage.CGImage, myImageRect);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    //释放资源
    CGImageRelease(subImageRef);
    
    return smallImage;
}


#pragma mark scrollView
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _showImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //缩放处理
}

#pragma mark action
- (void)confirmAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageCutViewController:finishedEidtImage:)]) {
        [_delegate imageCutViewController:self finishedEidtImage:[self getCutImage]];
    }
}

- (void)cancelAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageCutViewControllerDidCancel:)]) {
        [_delegate imageCutViewControllerDidCancel:self];
    }
}


@end
