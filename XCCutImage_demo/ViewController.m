//
//  ViewController.m
//  XCCutImage_demo
//
//  Created by wxc on 5/9/17.
//  Copyright © 2017年 wxc. All rights reserved.
//

#import "ViewController.h"
#import "XCImagePickerTool.h"

@interface ViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"a"]];
    _imageView.userInteractionEnabled  = YES;
    [self.view addSubview:_imageView];
    
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
        }
            break;
        case 1:
        {
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        }
            break;
            
        default:
            break;
    }
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourcetype
{
    XCImagePickerTool *tool = [XCImagePickerTool sharedInstance];
    
    __weak typeof(self) wself = self;
    tool.chooseImageBlock = ^(UIImage *image){
        wself.imageView.image = image;
        [wself.imageView sizeToFit];
    };
    
    [tool showImagePickerWithPresentController:self sourceType:sourcetype allowEdit:YES cutFrame:CGRectMake(100, 100, 100, 100)];
    
//    [tool showImagePickerWithPresentController:self sourceType:sourcetype allowEdit:YES radio:4/3.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
