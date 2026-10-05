//
//  ContractorSignOut.m
//  LinkSafe
//
//  Created by uday on 13/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorSignOut.h"
#import "ContractorSignOutStepTwo.h"
#import "UIButton+Additions.h"
#import "ScannerViewController.h"
#import "FTIndicator.h"
#import "ThankYouVC.h"
#import "AVCamViewController.h"
#import "ContractorSignOutMobile.h"

#if TARGET_OS_SIMULATOR
BOOL simmulator2=YES;
#else
BOOL simmulator2=NO;
#endif

@interface ContractorSignOut ()
{
    UIImage *picData;
    NSString *qrCode;
}

@end

@implementation ContractorSignOut

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor SignOut" parameters:@{@"onload": @"42"}];
    _lblHeader.textColor = kGetHomeLabelColor;
    if ([Common appDelegate].isIpad)
    {
        self.containtView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-64);
        self.tpKeybord.contentSize = CGSizeMake(self.view.frame.size.width,self.containtView.frame.size.height);
    }
    else
    {
        self.containtView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height>568?self.view.frame.size.height:500));
        self.tpKeybord.contentSize = CGSizeMake(self.view.frame.size.width,500);
    }
    [_btnPhone setHidden: ![[Common appDelegate].config isMobileLoginEnable]];
    [_btnScanQrCode applyBlueShedow];
    [_btnPIN applyGrayTheme];
    [_btnPhone applyGrayTheme];
    
    _orLabel.clipsToBounds=YES;
    _orLabel.layer.cornerRadius=3.0f;
    [_orLabel setHidden: [[Common appDelegate].config isMobileLoginEnable]];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common applyThemeColorToPowerdBy:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _orLabel.clipsToBounds=YES;
    _orLabel.layer.cornerRadius=3.0f;
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@ SIGN OUT", self.navTitle];//@"CONTRACTOR SIGN OUT";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    
    [self upadteTime];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}
-(void)upadteTime
{
    [Common updateTime:self.containtView];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (IBAction)onPinClick:(id)sender {
    
    ContractorSignOutStepTwo *contractorSignOutStepTwo = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignOutStepTwo"];
    contractorSignOutStepTwo.navTitle = self.navTitle;
    [self.navigationController pushViewController:contractorSignOutStepTwo animated:YES];
}

- (IBAction)onMobileClick:(id)sender {
    
    ContractorSignOutMobile *contractorSignOutStepTwo = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignOutMobile"];
    contractorSignOutStepTwo.navTitle = self.navTitle;
    [self.navigationController pushViewController:contractorSignOutStepTwo animated:YES];
}

- (IBAction)onQrBtnClick:(id)sender {
    [self.view endEditing:YES];
    qrCode=@"";
    ScannerViewController *scannerViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    scannerViewController.navTitle = self.navTitle;
    scannerViewController.didFinishwithQRDetail = ^(NSMutableDictionary *updaedVisitorDetails)
    {
        if ([[updaedVisitorDetails valueForKey:@"QRCode"] length]>0)
        {
            self->qrCode=[NSString stringWithFormat:@"%@",[updaedVisitorDetails valueForKey:@"QRCode"]];
            
            BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutContractor;
            
            if (isPhotoNeed)
            {
                [self onCaptureBtnClick];
            }
            else
            {
                [self callGetSignOutContexApiAndGetQuestions];
//                [self signOut];
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
    if (simmulator2)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        AVCamViewController *objAVCamObj = [self.storyboard instantiateViewControllerWithIdentifier:@"AVCamViewController"];
        objAVCamObj.didFinishCapturingImage = ^(UIImage *image) {
            picData = image;
            [self callGetSignOutContexApiAndGetQuestions];
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
        
        [self callGetSignOutContexApiAndGetQuestions];
//        [self signOut];
        
    }];
}
-(void)signOutUsingScan:(NSMutableDictionary *)dicResponse
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    
    BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutContractor;
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
    
    if ([dicResponse objectForKey:@"answers"])
    {
        [dicParameters setObject:[dicResponse objectForKey:@"answers"] forKey:@"answers"];
    }
    [dicParameters setObject:[NSString stringWithFormat:@"%@",qrCode] forKey:@"decodedString"];
    id signOutHandleVal = [dicResponse objectForKey:KEY_SIGNOUTHANDLE];
    NSString *strSignOutHandle = @"";
    if ([signOutHandleVal isKindOfClass:[NSNumber class]]) {
        strSignOutHandle = [signOutHandleVal stringValue];
    } else if (signOutHandleVal != nil) {
        strSignOutHandle = [NSString stringWithFormat:@"%@", signOutHandleVal];
    }
    [dicParameters setValue:strSignOutHandle forKey:KEY_SIGNOUTHANDLE];
    
    if ([Common appDelegate].config.isSignOutAcceptanceScreenVisible && [Common appDelegate].config.signOutAcceptanceMessage.length > 0)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[Common appDelegate].config.signOutAcceptanceMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [Common callContractorSignOutAPI:dicParameters ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                {
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
            }];
        }];
        [controller addAction:alertAction];
        
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UINavigationController *navController = (UINavigationController *)[Common appDelegate].window.rootViewController;
            if ([navController isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                MFSideMenuContainerViewController *containerVC = (MFSideMenuContainerViewController *)navController;
                containerVC.modalPresentationStyle = UIModalPresentationFullScreen;
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
        [Common callContractorSignOutAPI:dicParameters ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
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
            
        }];
    }
    
    
}

-(void)saveSignOutOption:(NSMutableDictionary *)dicResponse
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    
    BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutContractor;
    [dicParameters setValue:@"" forKey:@"photoUri"];
    if (isPhotoNeed)
    {
        if (picData==nil) {
            [Common showAlert:@"Please select image" : @""];
            return;
        }
        picData = [Common reSize:picData];
        [dicResponse setValue:[Common encodeToBase64String:picData] forKey:@"photoUri"];
    }
    
    [dicResponse setObject:[NSString stringWithFormat:@"%@",qrCode] forKey:@"decodedString"];
    [dicParameters setObject:[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] forKey:KEY_TOKEN];
    id signOutHandleVal2 = [dicResponse objectForKey:KEY_SIGNOUTHANDLE];
    NSString *strSignOutHandle2 = @"";
    if ([signOutHandleVal2 isKindOfClass:[NSNumber class]]) {
        strSignOutHandle2 = [signOutHandleVal2 stringValue];
    } else if (signOutHandleVal2 != nil) {
        strSignOutHandle2 = [NSString stringWithFormat:@"%@", signOutHandleVal2];
    }
    [dicParameters setValue:strSignOutHandle2 forKey:KEY_SIGNOUTHANDLE];
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
                [self signOutUsingScan:dicResponse];
            }

        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(void)callGetSignOutContexApiAndGetQuestions
{
    BOOL isPhotoNeed=[Common appDelegate].config.isPhotoRequiredSignOutContractor;
    if (isPhotoNeed)
    {
        if (picData==nil)
        {
            [Common showAlert:@"Please select image" : @""];
            return;
        }
    }
    
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:[NSString stringWithFormat:@"%@",qrCode] forKey:@"decodedString"];
    
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
//                                 [self signOutUsingScan:dicData];
                                 [self saveSignOutOption:dicData];
                             }];
                             [controller addAction:alertAction];
                         }
                         
                         [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
                         }];
                     }
                 }
             }
             else
             {
                 [self signOutUsingScan:responseObject];
             }
         }
         else
         {
             NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
             [Common showAlert:errorMsg : @""];
         }
     }];
}

@end
