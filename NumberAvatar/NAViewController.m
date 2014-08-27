//
//  NAViewController.m
//  NumberAvatar
//
//  Created by Jennifer on 8/27/14.
//  Copyright (c) 2014 folse. All rights reserved.
//

#import "NAViewController.h"
#import <AviarySDK/AviarySDK.h>
#import <iAd/iAd.h>

@interface NAViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,ADBannerViewDelegate>
{
    UIImagePickerController *imagePickerController;
    UIImage *finalImage;
    BOOL bannerIsVisible;
}

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *numberTextView;
@property (weak, nonatomic) IBOutlet ADBannerView *adView;

@end

@implementation NAViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:@"edc762d6aef61bea" secret:@"73429c0222c8298d"];
    });
    
    _adView.delegate = self;
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    s(error)
}

- (IBAction)doneButtonAction:(id)sender
{
    [self saveViewToImage];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:@"快去相册看看吧" delegate:self cancelButtonTitle:@"赞" otherButtonTitles:nil, nil];
    [alertView show];
    
    //UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"" message:@""];
    //[alertView bk_addButtonWithTitle:@"保存到相册" handler:^{
    
    //}];
    
}

- (IBAction)openCameraAction:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

- (IBAction)openAlbumAction:(id)sender
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePickerController setMediaTypes:[UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType]];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma AFPhotoEditorControllerDelegate

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [AFPhotoEditorCustomization setToolOrder:@[kAFEffects,kAFCrop,kAFStickers, kAFDraw, kAFText,kAFOrientation,kAFEnhance,kAFAdjustments, kAFSharpness, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFFrames, kAFFocus]];
    [AFPhotoEditorCustomization setStatusBarStyle:UIStatusBarStyleLightContent];
    [AFPhotoEditorCustomization setNavBarImage:[self imageWithColor:APP_COLOR andSize:CGSizeMake(320, 44)]];
    [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:@"取消"];
    [AFPhotoEditorCustomization setRightNavigationBarButtonTitle:@"完成"];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    [AFPhotoEditorCustomization setCropToolPresets:@[@{kAFCropPresetName:@"方形头像", kAFCropPresetWidth:@1, kAFCropPresetHeight:@1}]];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self displayEditorForImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma AFPhotoEditorControllerDelegate

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [editor dismissViewControllerAnimated:YES completion:^{
        [_avatarImageView setImage:image];
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)saveViewToImage {
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    finalImage = [self cropAvatarView:screenImage];
    
    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil,nil);
}

-(UIImage *)cropAvatarView:(UIImage *)image
{
    CGSize subImageSize = CGSizeMake(200, 200);

    CGRect subImageRect = CGRectMake(60, 128, 200, 200);
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    image = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end