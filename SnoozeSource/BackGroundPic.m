//
//  BackGroundPic.m
//  LinkSafe
//
//  Created by Hitesh Gs on 09/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import "BackGroundPic.h"
#import "MFSideMenu.h"
#import "UserLogin.h"
#import "UIButton+Additions.h"
#import "UIImage+fixOrientation.h"
#import "BGPhotoViewController.h"


@interface BackGroundPic ()

@end

@implementation BackGroundPic

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"BackGroup" parameters:@{@"onload": @"7"}];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = NO;
    [[self.view viewWithTag:4400] applyBlueShedow];
    [[self.view viewWithTag:4401] applyBlueShedow];
    [[self.view viewWithTag:4402] applyBlueShedow];
    [[self.view viewWithTag:4403] applyGrayTheme];
    
    [[self.view viewWithTag:4403] applyGrayTheme];
    [[self.view viewWithTag:4403] applyGrayTheme];
    [[self.view viewWithTag:4403] applyGrayTheme];
    [[self.view viewWithTag:4403] applyGrayTheme];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
     self.navigationItem.title=@"BACKGROUND IMAGE";
    if ([Common OpenLinkSafeFileOfName:F_BGFileName]!=NULL)
    {
        self.bgImage.image = [Common OpenLinkSafeFileOfName:F_BGFileName];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title=@"";
}
#pragma IBAction
- (IBAction)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTakePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }
    else
    {
        [Common showAlert:@"Camera Unavailable" :@"Unable to find a camera on your device."];
    }
}
- (IBAction)onExisting:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypePhotoLibrary])
    {
        
        
        if([Common appDelegate].isIpad)
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            picker.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController *popPC = picker.popoverPresentationController;
            popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popPC.sourceView = _btnExisting;
            popPC.sourceRect = _btnExisting.bounds;
            
            [self showViewController:picker sender:sender];
        }
        else
        {
            UIImagePickerController *a_imagePicker= [[UIImagePickerController alloc] init];
            a_imagePicker.delegate = self;
            a_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            a_imagePicker.allowsEditing = NO;
            [self presentViewController:a_imagePicker animated:YES completion:^{}];
        }
        
        
    }
}

- (IBAction)onBackGround:(id)sender
{
    
    BGPhotoViewController *bgPhotoViewController=[[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"BGPhotoViewController"];
    self.navigationController.navigationItem.title=@"";
    [self.navigationController pushViewController:bgPhotoViewController animated:YES];
    
}
- (void)presentViewController:(UIImage *)image
{
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
    cropViewController.delegate = self;
    cropViewController.aspectRatioPreset = TOCropViewControllerAspectRatioPresetCustom;
    cropViewController.aspectRatioLockEnabled = YES;
    float hight=(self.view.frame.size.height-64)/self.view.frame.size.width;
    cropViewController.customAspectRatio=CGSizeMake(1.0f,hight);
    [self presentViewController:cropViewController animated:YES completion:nil];
//    [cropViewController presentAnimatedFromParentViewController:self fromFrame:frame completion:nil];
}
#pragma mark UIIMAGEPICKER DELEGATE

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
   
        if (info[UIImagePickerControllerOriginalImage])
        {
            UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
            self.bgImage.image = chosenImage;
            [self presentViewController:chosenImage];
        }

        
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.bgImage.image = image;
    NSData *imageData = UIImagePNGRepresentation(image);
    [Common SaveLinkSafeBGImage:imageData withName:F_BGFileName ];
}



@end
