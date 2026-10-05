//
//  VisitorSignOutMultiUserStepTwo.m
//  LinkSafe
//
//  Created by uday on 14/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorSignOutMultiUserStepTwo.h"
#import "HomeVC.h"
#import "UIButton+Additions.h"
#import "FTIndicator.h"
#import "ThankYouVC.h"
#import "AVCamViewController.h"


#if TARGET_OS_SIMULATOR
BOOL simmulator4=YES;
#else
BOOL simmulator4=NO;
#endif


@interface VisitorSignOutMultiUserStepTwo ()
{
    UIImage *picData;
}
@end

@implementation VisitorSignOutMultiUserStepTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor SignOut Multi User 1" parameters:@{@"onload": @"45"}];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    
    //self.uiContaintView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    //self.uiScrollview.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    
    [_btnSignOut applyBlueShedow];
    [_btnCancel applyGrayTheme];
    _imgTakePhoto.layer.cornerRadius = 3;
    _imgTakePhoto.clipsToBounds=YES;
    _btnTakePhoto.layer.cornerRadius=3;
    _btnTakePhoto.clipsToBounds=YES;
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _imgTakePhoto.hidden = YES;
    _btnTakePhoto.hidden = YES;
    _lblHeader.hidden = YES;
    if ([Common appDelegate].config.isPhotoRequiredSignOutVisitor) {
        _imgTakePhoto.hidden = NO;
        _btnTakePhoto.hidden = NO;
        _lblHeader.hidden = NO;
    }
    _lbFirstName.text = [NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"firstName"]];
    _lbLastName.text = [NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"lastName"]];
    _lbCompany.text = [NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"organisation"]];
    
    if ([NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"vehicleRegistrationNumber"]].length<=0)
    {
        UIView *vehicalView=[self.view viewWithTag:4405];
        vehicalView.hidden=YES;
    }
    
    _lbVehicle.text = [NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"vehicleRegistrationNumber"]];
    
    NSString *val = [NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:@"phone"]];
    NSString *newVal = [Common GetMaskedIfPhone:val forKay:@"phone"];
    _lbMobileNo.text = newVal;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@ SIGN OUT", self.navTitle];//@"VISITOR SIGN OUT";
    [self upadteTime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (IBAction)onCancelBtnClick:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onSignOutBtnClick:(id)sender {
    
    if ([Common appDelegate].config.isPhotoRequiredSignOutVisitor && picData == nil)
    {
        [self onTakePhoto:nil];
    }
    else
    {
        [self searchVisitorForSignOut];
    }
}

//-------- create by w7shal on
-(void)searchVisitorForSignOut
{
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    
    BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutVisitor;
    
    if (isPhotoNeed)
    {
        if (picData==nil) {
            [Common showAlert:@"Please select image" : @""];
            return;
        }
        picData = [Common reSize:picData];
        [dicParameters setValue:[Common encodeToBase64String:picData] forKey:@"photoUri"];
    }
    
    [dicParameters setValue:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:KEY_REGISTERATION_ID]] intValue]] forKey:KEY_REGISTERATION_ID];
    [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    [Common callAPI:dicParameters Request:API_SIGN_OUT_VISITOR ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
            thankYouVC.resultDictionary=responseObject;
            thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:thankYouVC animated:YES completion:^{ }];
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

#pragma take photo
- (IBAction)onTakePhoto:(id)sender
{
    if (simmulator4)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        AVCamViewController *objAVCamObj = [self.storyboard instantiateViewControllerWithIdentifier:@"AVCamViewController"];
        objAVCamObj.didFinishCapturingImage = ^(UIImage *image) {
            picData = image;
            _imgTakePhoto.image = picData;
//            [self searchVisitorForSignOut];
        };
        objAVCamObj.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:objAVCamObj animated:YES completion:^{}];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//            
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Device Has No Camera"
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles: nil];
//            
//            [myAlertView show];
//        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    picData = [info valueForKey:UIImagePickerControllerEditedImage];
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerCropRect];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        _imgTakePhoto.image = picData;
//        [self searchVisitorForSignOut];
    }];
}

@end
