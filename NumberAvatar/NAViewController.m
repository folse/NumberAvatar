//
//  NAViewController.m
//  NumberAvatar
//
//  Created by Jennifer on 8/27/14.
//  Copyright (c) 2014 folse. All rights reserved.
//

#import "NAViewController.h"
#import <AviarySDK/AviarySDK.h>
#import <ShareSDK/ShareSDK.h>
#import <iAd/iAd.h>
#import "WXApi.h"

@interface NAViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,ADBannerViewDelegate>
{
    UIImagePickerController *imagePickerController;
    UIImage *finalImage;
    BOOL bannerIsVisible;
    NSString *shareUrl;
    NSString *shareTitle;
    NSString *shareContent;
    NSString *shareImageUrl;
}

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *numberTextView;
@property (weak, nonatomic) IBOutlet ADBannerView *adView;

@end

@implementation NAViewController

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:@"edc762d6aef61bea" secret:@"73429c0222c8298d"];
    });
    
    _adView.delegate = self;
    
    shareUrl = @"http://fir.im/jbtx";
    shareTitle = @"看着我的新头像,是不是整个人都不好了? ";
    shareContent = @"让朋友圈的小伙伴们都抓狂的#秘密#...";
    shareImageUrl = @"http://ts-image1.qiniudn.com/share_image@2x.png";
    
    [self removeNavigationBarShadow];
}

-(void)removeNavigationBarShadow
{
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UIImageView class]] && view2.frame.size.width == 320) {
                [view2 removeFromSuperview];
            }
        }
    }
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    s(@"iAD:")
    s(error)
}

- (IBAction)doneButtonAction:(id)sender
{
    [self.view endEditing:YES];

    [self saveViewToImage:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"保存成功" message:@"已经保存到手机相册了"];

    [alertView bk_addButtonWithTitle:@"分享到朋友圈" handler:^{
        if ([WXApi isWXAppInstalled]) {
            
            [self sendToTimeLine];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未发现微信应用,请安装微信再分享" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    [alertView bk_addButtonWithTitle:@"发给微信好友" handler:^{
        
        if ([WXApi isWXAppInstalled]) {
            
            [self sendToSession];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未发现微信应用,请安装微信再分享" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    [alertView bk_setCancelButtonWithTitle:@"这就去换头像" handler:^{
        
    }];

    [alertView show];
}

- (IBAction)shareButtonAction:(id)sender
{
    [self.view endEditing:YES];
    
    [self saveViewToImage:NO];
    
    UIActionSheet *shareActionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
    
    [shareActionSheet bk_addButtonWithTitle:@"分享到朋友圈" handler:^{
        
        if ([WXApi isWXAppInstalled]) {
            
            [self sendToTimeLine];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未发现微信应用,请安装微信再分享" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
    [shareActionSheet bk_addButtonWithTitle:@"发给微信好友" handler:^{
        
        if ([WXApi isWXAppInstalled]) {
            
            [self sendToSession];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未发现微信应用,请安装微信再分享" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
    [shareActionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];

    [shareActionSheet showInView:self.view];
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
//    [AFPhotoEditorCustomization setNavBarImage:[self imageWithColor:APP_COLOR andSize:CGSizeMake(320, 44)]];
    [AFPhotoEditorCustomization setLeftNavigationBarButtonTitle:@"取消"];
    [AFPhotoEditorCustomization setRightNavigationBarButtonTitle:@"完成"];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
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

- (void)saveViewToImage:(BOOL)needSaveToAlbum {
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    finalImage = [self cropAvatarView:screenImage];
    
    if (needSaveToAlbum) {
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil,nil);
    }
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

-(void)sendToSession;
{
    id<ISSContent> content = [ShareSDK content:shareContent
                                defaultContent:nil
                                         image:[ShareSDK pngImageWithImage:finalImage]
                                         title:shareTitle
                                           url:shareUrl
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeApp];
    
    [content addWeixinSessionUnitWithType:[NSNumber numberWithInt:SSPublishContentMediaTypeNews]
                                  content:shareContent
                                    title:shareTitle
                                      url:shareUrl
                                    image:[ShareSDK pngImageWithImage:finalImage]
                             musicFileUrl:nil
                                  extInfo:nil
                                 fileData:nil
                             emoticonData:nil];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:NO
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                    }];
}

- (void)sendToTimeLine;
{
    id<ISSContent> content = [ShareSDK content:shareContent
                                defaultContent:nil
                                         image:[ShareSDK pngImageWithImage:finalImage]
                                         title:shareTitle
                                           url:shareUrl
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeApp];
    
    [content addWeixinTimelineUnitWithType:[NSNumber numberWithInt:SSPublishContentMediaTypeNews]
                                   content:shareContent
                                     title:shareTitle
                                       url:shareUrl
                                     image:[ShareSDK pngImageWithImage:finalImage]
                              musicFileUrl:nil
                                   extInfo:nil
                                  fileData:nil
                              emoticonData:nil];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiTimeline
               authOptions:authOptions
             statusBarTips:NO
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
