//
//  VisitorSignOut.m
//  LinkSafe
//
//  Created by uday on 13/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorSignOut.h"
#import "VisitorSignOutMultiUser.h"
#import "VisitorSignOutMultiUserStepTwo.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "FTIndicator.h"
#import "ScannerViewController.h"
#import "ThankYouVC.h"
#import "AVCamViewController.h"


#if TARGET_OS_SIMULATOR
BOOL simmulator3=YES;
#else
BOOL simmulator3=NO;
#endif


@interface VisitorSignOut ()
{
    UIImage *picData;
    NSString *qrCode;
}
@end

@implementation VisitorSignOut

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor SignOut" parameters:@{@"onload": @"46"}];
    [_btnScanQrCode applyBlueShedow];
    [_btnSearch applyBlueShedow];
    [_btnCancel applyGrayTheme];
    
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    _labelOr.layer.cornerRadius=3.0f;
    _labelOr.clipsToBounds=YES;
    _labelOr2.layer.cornerRadius=3.0f;
    _labelOr2.clipsToBounds=YES;
    
    if ([Common appDelegate].isIpad)
    {
        self.containtView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-64);
        self.tpKeybord.contentSize = CGSizeMake(self.view.frame.size.width,self.containtView.frame.size.height);
        [_tfFirstName applyGrayBorderTheme];
        [_tfLastName applyGrayBorderTheme];
        [_tfPhoneNumber applyGrayBorderTheme];
    }
    else
    {
        self.containtView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height - 64 > 680 ? (self.view.frame.size.height - 88) : 680));
        self.tpKeybord.contentSize = CGSizeMake(self.view.frame.size.width,680);
        [_tfPhoneNumber applyGrayBorderTheme];
        [_tfLastName applyGrayBorderTheme];
        [_tfFirstName applyGrayBorderTheme];
    }
   
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];

    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@ SIGN OUT", self.navTitle];//@"VISITOR SIGN OUT";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [self upadteTime];
}
-(void)upadteTime
{
    [Common updateTime:self.view];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}
-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title=@"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

- (IBAction)onCancelBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSearchBtnClick:(id)sender {
    [self searchVisitorForSignOut];
}
#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==_tfFirstName || textField==_tfLastName)
    {
        _tfPhoneNumber.text=@"";
    }
    else
    {
        _tfFirstName.text=@"";
        _tfLastName.text=@"";
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([_tfFirstName.text length]>0 || [_tfLastName.text length]>0 || [_tfPhoneNumber.text length]>0)
    {
        [self searchVisitorForSignOut];
    }
    
    return true;
}
//-------- create by w7shal on
-(void)searchVisitorForSignOut
{
    
    
//    if ([_tfFirstName.text length]==0 && [_tfLastName.text length]==0 && [_tfPhoneNumber.text length]==0)
//    {
//        [Common showAlert:@"Invalid input" :@"Please enter atleast one filter"];
//        return;
//    }
    
    if (![self isValidSubmitionSignOut]) {
        return;
    }
//
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];

    if ([_tfFirstName.text containsString:@"’"])
    {
        _tfFirstName.text = [_tfFirstName.text stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    if ([_tfLastName.text containsString:@"’"])
    {
        _tfLastName.text = [_tfLastName.text stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    if ([_tfPhoneNumber.text containsString:@"’"])
    {
        _tfPhoneNumber.text = [_tfPhoneNumber.text stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    [dicParameters setValue:[NSString stringWithFormat:@"%@", _tfFirstName.text] forKey:@"firstName"];
    [dicParameters setValue:[NSString stringWithFormat:@"%@", _tfLastName.text] forKey:@"lastName"];
    [dicParameters setValue:[NSString stringWithFormat:@"%@", _tfPhoneNumber.text]  forKey:KEY_DEVICE_PHONE];

    [Common callAPI:dicParameters Request:SEARCH_SIGNOUT_VISITOR ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            if ([[responseObject valueForKey:@"results"] count]>1) {
                VisitorSignOutMultiUser *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOutMultiUser"];
                    vc.navTitle = self.navTitle;
                vc.visitorArray = [responseObject valueForKey:@"results"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([[responseObject valueForKey:@"results"] count]==1)
            {
                VisitorSignOutMultiUserStepTwo *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOutMultiUserStepTwo"];
                vc.visitorDetails = [[responseObject valueForKey:@"results"] objectAtIndex:0];
                vc.navTitle = self.navTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [Common showAlert:@"There is no visitor logged in with this detail" : @""];
            }
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
        
    }];
}

- (Boolean)isValidSubmitionSignOut
{
    NSString *txtFirstName = [Common removeWhiteSpace:_tfFirstName.text];
    
    NSString *txtLastName = [Common removeWhiteSpace:_tfLastName.text];
    
    NSString *txtPhone = [Common removeWhiteSpace:_tfPhoneNumber.text];
    
    if((txtFirstName.length == 0 || txtLastName.length == 0) && txtPhone.length == 0 )
    {
        [Common showAlert:@"Invalid Input" :@"Please enter either First Name and Last Name, OR Phone Number"];
        return false;
    }
    else if(txtFirstName.length > 0 && txtLastName.length > 0 && txtPhone.length > 0)
    {
        [Common showAlert:@"Invalid input" :@"Please remove unnecesarry filter"];
        return false;
    }
    else if(txtFirstName.length > 0 || txtLastName.length > 0)
    {
        if (txtPhone.length>0) {
            [Common showAlert:@"Invalid input" :@"Please remove phone number"];
            return false;
            
        }
        else{
            return true;
        }
    }
    else if (txtPhone.length>0) {
        
        return true;
    }
    
    return false;
}

- (IBAction)onQRbtnClick:(id)sender {
    [self.view endEditing:YES];
    qrCode=@"";
    ScannerViewController *scannerViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    scannerViewController.navTitle = self.navTitle;
    scannerViewController.didFinishwithQRDetail = ^(NSMutableDictionary *updaedVisitorDetails)
    {
        if ([[updaedVisitorDetails valueForKey:@"QRCode"] length]>0)
        {
            qrCode=[NSString stringWithFormat:@"%@",[updaedVisitorDetails valueForKey:@"QRCode"]];
            
            BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutVisitor;
            
            if (isPhotoNeed)
            {
                [self onCaptureBtnClick];
            }
            else
            {
                [self signOut];
            }
        }
        
        else
        {
            [Common showAlert:@"Please Scan valid QRCode" :@""];
        }
    };
    [self.navigationController pushViewController:scannerViewController animated:YES];
    
}

- (void)onCaptureBtnClick
{
    if (simmulator3)
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
            [self signOut];
        };
        objAVCamObj.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:objAVCamObj animated:YES completion:^{
            
        }];
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
//            
//            
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
        
        [self signOut];
        
    }];
}
-(void)signOut
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    
    [dicParameters setObject:qrCode forKey:@"decodedString"];
    //[dicParameters setObject:[NSString stringWithFormat:@"http://something.com?pin=%@",qrCode] forKey:@"decodedString"];
    
    BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutVisitor;
    [dicParameters setValue:@"" forKey:@"photoUri"];
    if (isPhotoNeed)
    {
        if (picData==nil) {
            [Common showAlert:@"Please select image" : @""];
            return; 
        }
        picData = [Common reSize:picData];
        [dicParameters setValue:[Common encodeToBase64String:picData] forKey:@"photoUri"];
        
    }
    [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    // [dicParameters setObject:@[@1232, @1226] forKey:KEY_MESSAGE_BOARDS];

    [Common callAPI:dicParameters Request:API_SIGN_OUT_VISITOR ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            
           // [FTIndicator showSuccessWithMessage:[NSString stringWithFormat:@"Success\nYou have been successfully sign out"]];
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
            thankYouVC.resultDictionary=responseObject;
            thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
            UIViewController *presenter = [Common appDelegate].window.rootViewController ?: self;
            [presenter presentViewController:thankYouVC animated:YES completion:^{ }];

            
        }
        else
            
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
        
    }
     ];
}
#pragma end


@end
