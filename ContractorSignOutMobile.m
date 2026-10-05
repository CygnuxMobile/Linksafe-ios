//
//  ContractorSignOutMobile.m
//  LinkSafe
//
//  Created by hitesh gs on 23/05/22.
//  Copyright © 2022 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorSignOutMobile.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "ThankYouVC.h"
#import "SignOutDocumentsVC.h"
#import "AVCamViewController.h"
#import "EMCCountryPickerController.h"
#import "UIImage+UIImage_EMCImageResize.h"
#import "EMCCountryManager.h"


#if TARGET_OS_SIMULATOR
BOOL simmulator5=YES;
#else
BOOL simmulator5=NO;
#endif

@interface ContractorSignOutMobile () <EMCCountryDelegate>
{
    UIImage *picData;
    EMCCountryPickerController *countryPicker;
    NSDictionary *countryCodeDictionary;

}
@end

@implementation ContractorSignOutMobile

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor SignOut 2" parameters:@{@"onload": @"43"}];
    [self upadteTime];
    _lblHeader.textColor = kGetHomeLabelColor;
    _imgPic.layer.cornerRadius = 3;
    _imgPic.clipsToBounds=YES;
    _btnTakePhoto.layer.cornerRadius=3;
    _btnTakePhoto.clipsToBounds=YES;
    [_btnCancel applyGrayTheme];
    [_btnSignOut applyBlueShedow];
//    [_tfEnterPin applyFlatTheme];
    [_tfEnterPin applyGrayBorderTheme];
    _tfEnterPin.delegate=self;
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common applyThemeColorToPowerdBy:self.view];
    [Common setBgImage:self.view useDefault:YES];
    [self upadteTime];
    
    if (![Common appDelegate].config.isPhotoRequiredSignOutContractor)
    {
        _imgPic.hidden=YES;
        _btnTakePhoto.enabled=NO;
        _lblHeader.hidden=YES;
    }
    self.uiContaintView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-64);
    self.uiScrollview.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height-64);
    countryCodeDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countrycode" ofType:@"plist"]];
    [self.btnSelectCountry setTitle:@"" forState:UIControlStateNormal];
    [self setDefaultCountry];

}

-(void)upadteTime
{
    [Common updateTime:self.uiContaintView];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}
-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@ SIGN OUT", self.navTitle];//@"CONTRACTOR SIGN OUT";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    
}
- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (IBAction)onLogout:(id)sender {
    NSString *mobile = [Common getPhoneNumber:_tfEnterPin.text];
    if([mobile length] <= 0)
    {
        [Common showAlert:@"" :@"Please enter mobile"];
        return;
    }
    NSString *countryCode = [Common removeWhiteSpace:self.lblCountryCode.text];
    if([countryCode length] <= 0)
    {
        [Common showAlert:@"" :@"Please select country"];
        return;
    }
    
    [self callGetSignOutContexApiAndGetQuestions];
//    [self signOutUsingPin];
}

- (IBAction)onProfileBtnClick:(id)sender {
    
    [self takePhoto];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *codewithphone = [[Common removeWhiteSpace:self.lblCountryCode.text] stringByAppendingString:[Common getPhoneNumber:_tfEnterPin.text]];
    if([codewithphone length] > 0)
    {
        [self callGetSignOutContexApiAndGetQuestions];
//        [self signOutUsingPin];
    }
    return true;
}

-(void)callGetSignOutContexApiAndGetQuestions
{
    if ([Common appDelegate].config.isPhotoRequiredSignOutContractor)
    {
        if (picData==nil)
        {
            [self takePhoto];
            return;
        }
    }
    
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    NSString *codewithphone = [[Common removeWhiteSpace:self.lblCountryCode.text] stringByAppendingString:[Common getPhoneNumber:_tfEnterPin.text]];
    [dicParameters setValue:codewithphone forKey:KEY_MOBILE];
    
    [Common callAPI:dicParameters Request:API_GET_SIGNOUT_HANDLE ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSMutableDictionary *dicData = [responseObject mutableCopy];
            NSArray *arrQuestions = [dicData objectForKey:@"questions"];
            
            if (arrQuestions.count > 0) {
                NSDictionary *dictQuestions = [arrQuestions objectAtIndex:0];
                NSArray *arrAnswers = [dictQuestions objectForKey:@"answers"];
                
                if ([arrAnswers isKindOfClass:[NSMutableArray class]] || [arrAnswers isKindOfClass:[NSArray class]])
                {
                    if (arrAnswers.count > 0)
                    {
                        NSString *question = [NSString stringWithFormat:@"%@",[dictQuestions valueForKey:@"questionText"]];
                        
                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:question preferredStyle:UIAlertControllerStyleAlert];
                        
                        for (int i = 0; i<arrAnswers.count; i++) {
                            NSString *strAnswer = [NSString stringWithFormat:@"%@",[arrAnswers objectAtIndex:i]];
                            
                            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:strAnswer style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [dicData setObject:@[action.title] forKey:@"answers"];
                                [self saveSignOutOption:dicData];
                               // [self signOutUsingPin:dicData];
                            }];
                            [controller addAction:alertAction];
                        }
                        
                        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
                        }];
                    }
                }
                else
                {
                    [self signOutUsingPin:responseObject];
                }
            }
            else
            {
                [self signOutUsingPin:responseObject];
            }
        
           
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(void)saveSignOutOption:(NSMutableDictionary *)dicResponse
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    
    if ([Common appDelegate].config.isPhotoRequiredSignOutContractor)
    {
        if (picData == nil)
        {
            [self takePhoto];
            return;
        }
        else
        {
            picData=[Common reSize:picData];
            [dicResponse setObject:[Common encodeToBase64String:picData] forKey:@"photoUri"];
        }
    }
    [dicResponse setValue:[Common getPhoneNumber:_tfEnterPin.text] forKey:KEY_MOBILE];
    
    [dicParameters setObject:[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] forKey:KEY_TOKEN];
    [dicParameters setValue:[NSString stringWithFormat:@"%@",[[dicResponse objectForKey:KEY_SIGNOUTHANDLE] stringValue]] forKey:KEY_SIGNOUTHANDLE];
    if ([dicResponse objectForKey:@"answers"])
    {
        [dicParameters setObject:[dicResponse objectForKey:@"answers"] forKey:@"Answers"];

        [Common callAPI:dicParameters Request:API_SAVE_SIGN_OUT_ANSWERS ShowProgress:YES WithCompletionHandler:^(id responseObject)
         {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                [self getDocumentConfig:dicResponse];
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg : @""];
            }
        }];
    }
    else {
        
    }

}

-(void)getDocumentConfig:(NSMutableDictionary *)dicResponse
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] forKey:KEY_TOKEN];
    [dicParameters setValue:[dicResponse objectForKey:KEY_SIGNOUTHANDLE] forKey:KEY_SIGNOUTHANDLE];
    [Common callAPI:dicParameters Request:API_GET_SIGN_OUT_DOCUMENTS ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"isEnabled"]] boolValue])
            {
                NSMutableDictionary *dicParameters = [responseObject valueForKey:@"settings"];
                
                SignOutDocumentsVC *vc = [SignOutDocumentsVC viewController];
                vc.dictSignOutData = dicResponse;
                vc.dictDocumentData = dicParameters;
                [self.navigationController pushViewController:vc animated:true];
                
            }
            else {
                [self signOutUsingPin:dicResponse];
            }

        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(void)signOutUsingPin:(NSMutableDictionary *)dicResponse
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    if ([Common appDelegate].config.isPhotoRequiredSignOutContractor)
    {
        if (picData == nil)
        {
            [self takePhoto];
            return;
        }
        else
        {
            picData=[Common reSize:picData];
            [dicParameters setObject:[Common encodeToBase64String:picData] forKey:@"photoUri"];
        }
    }
    [dicParameters setValue:[Common getPhoneNumber:_tfEnterPin.text] forKey:KEY_MOBILE];
    [dicParameters setValue:[NSString stringWithFormat:@"%@",[[dicResponse objectForKey:KEY_SIGNOUTHANDLE] stringValue]] forKey:KEY_SIGNOUTHANDLE];
    
    if ([dicResponse objectForKey:@"answers"])
    {
        [dicParameters setObject:[dicResponse objectForKey:@"answers"] forKey:@"answers"];
       
//        [self saveSignOutOption:dicParameters];
    }
    
    if ([Common appDelegate].config.isSignOutAcceptanceScreenVisible && [Common appDelegate].config.signOutAcceptanceMessage.length > 0)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[Common appDelegate].config.signOutAcceptanceMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [Common callContractorSignOutAPI:dicParameters ShowProgress:YES WithCompletionHandler:^(id responseObject)
             {
                 if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                 {
                     [self.navigationController popToRootViewControllerAnimated:NO];
                     ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
                     thankYouVC.resultDictionary = responseObject;
                     thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
                     [self presentViewController:thankYouVC animated:YES completion:^{}];
                 }
                 else
                 {
                     NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                     [Common showAlert:errorMsg : @""];
                 }
             }];
        }];
        [controller addAction:alertAction];
        
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UINavigationController *navController = (UINavigationController *)[Common appDelegate].window.rootViewController;
            if ([navController isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                MFSideMenuContainerViewController *containerVC = (MFSideMenuContainerViewController *)navController;
                UINavigationController *navigationController = containerVC.centerViewController;
                [navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [navController popToRootViewControllerAnimated:YES];
            }
        }];
        [controller addAction:alertActionCancel];
        
        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
        }];
    }
    else
    {
        [Common callContractorSignOutAPI:dicParameters ShowProgress:YES WithCompletionHandler:^(id responseObject)
        {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                [self.navigationController popToRootViewControllerAnimated:NO];
                ThankYouVC *thankYouVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ThankYouVC"];
                thankYouVC.resultDictionary = responseObject;
                thankYouVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:thankYouVC animated:YES completion:^{}];
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg : @""];
            }
        }];
    }
}
#pragma take photo
- (void)takePhoto
{
    if (simmulator5)
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
            _imgPic.image = picData;
        };
        objAVCamObj.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:objAVCamObj animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//        {
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Device has no camera"
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles:nil];
//            [myAlertView show];
//        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    picData = [info valueForKey:UIImagePickerControllerEditedImage];
    
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if(picData==nil)
    {
        picData = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    _imgPic.image = picData;
    [picker dismissViewControllerAnimated:YES completion:^{ }];
}

- (IBAction)onCancel:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)openCountryPicker:(id)sender
{
        countryPicker = [EMCCountryPickerController new];
    // = segue.destinationViewController;
        // default values
        countryPicker.showFlags = true;
        countryPicker.countryDelegate = self;
        countryPicker.drawFlagBorder = true;
        countryPicker.flagBorderColor = [UIColor grayColor];
        countryPicker.flagBorderWidth = 0.5f;
    [self presentViewController:countryPicker animated:YES completion:nil];

    }
- (void)countryController:(id)sender didSelectCountry:(EMCCountry *)chosenCity
{
    
    NSString *imagePath = [NSString stringWithFormat:@"EMCCountryPickerController.bundle/%@", chosenCity.countryCode];
    UIImage *image = [UIImage imageNamed:imagePath inBundle:[NSBundle bundleForClass:EMCCountryPickerController.class] compatibleWithTraitCollection:nil];
    self.imgCountryFlag.image = [image fitInSize:CGSizeMake(20, 20)];
    if ([countryCodeDictionary valueForKey:chosenCity.countryCode]) {
        [self.lblCountryCode setText:[countryCodeDictionary valueForKey:chosenCity.countryCode]];
    }
    [countryPicker dismissViewControllerAnimated:YES completion:nil];
}
- (void)setDefaultCountry
{
    if ([Common appDelegate].config.country != NULL) {
        NSString *countryCode = [Common appDelegate].config.country;
        NSArray *availableCountries = [[EMCCountryManager countryManager] allCountries];
        for (int i=0; i<availableCountries.count; i++) {
            EMCCountry *chosenCountry = [availableCountries objectAtIndex:i];
            if ([countryCode isEqualToString:chosenCountry.countryCode]) {
                [self countryController:nil didSelectCountry:chosenCountry];
                return;
            }
        }
    }
}


@end
