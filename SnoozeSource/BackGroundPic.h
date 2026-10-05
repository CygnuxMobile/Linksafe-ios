//
//  HomeVC.h
//  LinkSafe
//
//  Created by Hitesh Gs on 09/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOCropViewController.h"

@interface BackGroundPic : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,TOCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnExisting;
@property (strong, nonatomic) IBOutlet UIButton *btnBackGround;

- (IBAction)onCancel:(id)sender;
- (IBAction)onTakePhoto:(id)sender;
- (IBAction)onExisting:(id)sender;
- (IBAction)onBackGround:(id)sender;

@end
