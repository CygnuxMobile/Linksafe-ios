//
//  TakePhotoVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "TakePhotoVC.h"
#import "MeetingWithVC.h"
#import "UIButton+Additions.h"
#import "SideMenuVC.h"
#import "VisitorInductionVC.h"
#import "UserDefaults.h"
#import "BRPrintResultViewController.h"
#import "AVCamViewController.h"
#import "SiteApproverScreenVC.h"
#import "TakeSignatureVC.h"

#if TARGET_OS_SIMULATOR
BOOL simmulator=YES;
#else
BOOL simmulator=NO;
#endif

@interface TakePhotoVC ()
{
    UIImage *signData;
    UIImage *picData;
    
    BOOL isPhotoNeed;
    BOOL isSignNeed;
}

@end

@implementation TakePhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Take Photo" parameters:@{@"onload": @"16"}];
    _photoInstruction.textColor = kGetHomeLabelColor;
    _signInstruction.textColor = kGetHomeLabelColor;
    if ([Common appDelegate].isIpad)
    {
        self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64);
        self.tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    }
    
    [_signin applyBlueShedow];
    [_btnTakePhoto applyBlueShedow];
    
    _btnTakePhoto.tintColor = [UIColor whiteColor];
    _signHere.tintColor = [UIColor whiteColor];

    [_signDone applyBlueShedow];
    [_signCancel applyGrayTheme];
    [_signHere applyBlueShedow];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    isPhotoNeed=self.isContractor ? app.config.isPhotoRequiredSignInContractor : app.config.isPhotoRequiredSignInVisitor;
    isSignNeed=self.isContractor ? app.config.isSignatureRequiredContractor : app.config.isSignatureRequiredVisitor;
    
    if ([Common appDelegate].isIpad)
    {
        self.userPic.hidden=NO;
    }
    else
    {
        self.userPic.hidden=YES;
    }
    _baseSigntureView.hidden=YES;
    
    self.userPic.clipsToBounds=YES;
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [self performSelector:@selector(setUIComponant) withObject:nil afterDelay:0.1];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;//_isForImageData?@"Take Photo":@"VISITOR SIGN IN";
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
    [Common updateTime:self.view];
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


- (IBAction)onTackPhoto:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    if (simmulator)
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        AVCamViewController *objAVCamObj = [self.storyboard instantiateViewControllerWithIdentifier:@"AVCamViewController"];
        objAVCamObj.didFinishCapturingImage = ^(UIImage *image) {
            self->picData = image;
            self.userPic.image = self->picData;
            self.userPic.hidden = NO;
            [self.userPic setContentMode:UIViewContentModeScaleToFill];
            [self setUIComponant];
        };
        objAVCamObj.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:objAVCamObj animated:YES completion:^{}];
    }
}

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
//        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//            
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Device has no camera"
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles: nil];
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
    self.userPic.image = picData;
    self.userPic.hidden=NO;
    
    [self.userPic setContentMode:UIViewContentModeScaleToFill];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self setUIComponant];
    }];
}

- (void)setUIComponant
{
    if ([Common appDelegate].isIpad)
    {
        UIView *viewPhoto=[self.view viewWithTag:6200];
        UIView *viewSign=[self.view viewWithTag:6201];
        
        CGRect viewSaprator=[self.view viewWithTag:6202].frame;
        viewSaprator.origin.x=self.view.frame.size.width/2-1;
        CGRect signinRect=_signin.frame;
        CGRect viewPhotoRect=viewPhoto.frame;
        CGRect viewSignRect=viewSign.frame;
        
        // Set the final button width first so centering math is always correct
        signinRect.size.width=self.view.frame.size.width/2-40;
        
        if (isPhotoNeed && !isSignNeed)
        {
            viewPhotoRect.size.width=self.view.frame.size.width/2-40;
            viewPhotoRect.origin.x=10;
            viewSign.hidden=YES;
            
            signinRect.origin.y=(self.view.frame.size.height-signinRect.size.height)/2;
            signinRect.origin.x=self.view.frame.size.width/2+30;
            viewSaprator.size.height = viewPhoto.frame.size.height + 10;
        }
        else if (!isPhotoNeed && isSignNeed)
        {
            viewPhoto.hidden=YES;
            viewSignRect.origin.x=self.view.frame.size.width/2+30;
            viewSignRect.size.width=self.view.frame.size.width/2-40;
            signinRect.origin.y=(self.view.frame.size.height-signinRect.size.height)/2;
            signinRect.origin.x=10;
            viewSaprator.size.height = viewSignRect.size.height + 10;
        }
        else
        {
            viewPhotoRect.size.width=self.view.frame.size.width/2-40;
            viewSignRect.size.width=self.view.frame.size.width/2-40;
            signinRect.origin.x=(self.view.frame.size.width - signinRect.size.width) / 2;
            viewPhotoRect.origin.x=10;
            viewSignRect.origin.x=self.view.frame.size.width/2+30;
            viewSaprator.size.height = viewPhotoRect.size.height + 10;
        }
        viewPhoto.frame=viewPhotoRect;
        viewSign.frame=viewSignRect;
        _signin.frame=signinRect;
        [self.view viewWithTag:6202].frame=viewSaprator;
    }
    else
    {    
        CGRect btnTakePhotoRect=_btnTakePhoto.frame;
        
        if (!isPhotoNeed && isSignNeed)
        {
            btnTakePhotoRect.origin.y=self.userPic.hidden?170:380;
        }
        else
        {
            btnTakePhotoRect.origin.y=self.userPic.hidden?140:350;
        }
        
        _btnTakePhoto.frame=btnTakePhotoRect;
        
        CGRect lbsignInst=_signInstruction.frame;
        
        if (!isPhotoNeed && isSignNeed)
        {
            lbsignInst.origin.y=_photoInstruction.frame.origin.y;
            _btnTakePhoto.hidden=YES;
            _photoInstruction.hidden=YES;
        }
        else if (isPhotoNeed && !isSignNeed)
        {
            lbsignInst.origin.y=btnTakePhotoRect.origin.y+btnTakePhotoRect.size.height+50;
            _signInstruction.hidden=YES;
            _signHere.hidden=YES;
            _baseSigntureView.hidden=YES;
        }
        else
        {
            lbsignInst.origin.y=btnTakePhotoRect.origin.y+btnTakePhotoRect.size.height+50;
        }
        
        _signInstruction.frame=lbsignInst;
        
        CGRect signHereRect=_signHere.frame;
        if (signData)
        {
            CGRect baseSigntureRect=_baseSigntureView.frame;
            baseSigntureRect.origin.y=lbsignInst.origin.y+lbsignInst.size.height+50;
            _baseSigntureView.frame=CGRectMake((self.view.frame.size.width-200)/2, lbsignInst.origin.y+lbsignInst.size.height+50, 200, 200);
            self.imgSignatureView.frame=CGRectMake((self.view.frame.size.width-200)/2, lbsignInst.origin.y+lbsignInst.size.height+50, 200, 200);
        
            signHereRect.origin.y=baseSigntureRect.origin.y+baseSigntureRect.size.height+10;
        }
        else
        {
            signHereRect.origin.y=lbsignInst.origin.y+lbsignInst.size.height+50;
        }
        _signHere.frame=signHereRect;
        
        CGRect signinRect=_signin.frame;
        
        if (!isPhotoNeed && isSignNeed)
        {
            signinRect.origin.y=_signHere.frame.origin.y+_signHere.frame.size.height+30;
        }
        else if (isPhotoNeed && !isSignNeed)
        {
             signinRect.origin.y=_btnTakePhoto.frame.origin.y+_btnTakePhoto.frame.size.height+30;
        }
        else
        {
            signinRect.origin.y=signHereRect.origin.y+signHereRect.size.height+10;
        }
       
        _signin.frame=signinRect;
        _baseSigntureView.hidden=YES;
        [self setScrollView:signinRect.origin.y+signinRect.size.height];
    }
}

- (IBAction)setScrollView:(int)needHight
{
    needHight=needHight+40;
    needHight=needHight>self.view.frame.size.height?needHight:self.view.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, needHight);
    self.tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    
    UIView *baseFooterView=[self.view viewWithTag:7701];
    
    if (![Common appDelegate].isIpad)
    {
        CGRect baseFooterRect=baseFooterView.frame;
        baseFooterRect.origin.y=needHight-35;
        baseFooterView.frame=baseFooterRect;
    }
}

- (IBAction)onSignHere:(id)sender
{
//    [self openSignView:YES];
    TakeSignatureVC *viewController = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"TakeSignatureVC"];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.didFinishWithCapturedSignature = ^(UIImage *signatureImage) {
        signData = signatureImage;
        self.imgSignatureView.image = [Common reSize:signData];
        [self openSignView:NO];
    };
    [self presentViewController:viewController animated:YES completion:nil];
}

-(IBAction)resetButtonPressed:(id)sender
{
    signData=nil;
    [_signtureView clearSignature];
//    [self openSignView:NO];
}

-(IBAction)saveButtonPressed:(id)sender
{
    signData = [_signtureView getSignatureImage];
    [self openSignView:NO];
}

-(void)openSignView:(BOOL)visible
{
    if(signData!=nil && !visible)
    {
        _baseSigntureView.hidden=NO;
        _imgSignatureView.hidden=NO;
    }
    
    if (visible)
    {
        if ([Common appDelegate].isIpad)
        {
            self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        else
        {
            self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        self.tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    }
    else
    {
        self.signDone.hidden=YES;
        self.signCancel.hidden=YES;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                        
                         if (visible)
                         {
                             self.baseSigntureView.hidden=NO;
                             self.signtureView.userInteractionEnabled=YES;
                             if ([Common appDelegate].isIpad)
                             {
                                 self.baseSigntureView.frame=self.view.bounds;
                                 self.signtureView.frame=CGRectMake((self.view.frame.size.width-500)/2, 60, 500,500);
                             }
                             else
                             {
                                 self.baseSigntureView.frame=self.view.bounds;
                                 self.signtureView.frame=CGRectMake(10, 64, self.view.frame.size.width-20,self.view.frame.size.width-20);
                             }
                             self.signtureView.backgroundColor=[UIColor whiteColor];
                         }
                         else
                         {
                             self.signtureView.userInteractionEnabled=NO;
                             
                             CGRect lbsignInst=self.signInstruction.frame;
                             if (self->signData)
                             {
                                 if ([Common appDelegate].isIpad)
                                 {
                                     self.baseSigntureView.frame=CGRectMake((self.view.frame.size.width/2)+(self.view.frame.size.width/2-200)/2,210, 200, 200);
                                 }
                                 else
                                 {
                                     self.baseSigntureView.frame=CGRectMake((self.view.frame.size.width-200)/2, lbsignInst.origin.y+lbsignInst.size.height+50, 200, 200);
                                     self.imgSignatureView.frame=CGRectMake((self.view.frame.size.width-200)/2, lbsignInst.origin.y+lbsignInst.size.height+50, 200, 200);
                                 }
                             }
                             else
                             {
                                 self.baseSigntureView.frame=CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2, 0, 0);
                                 self.imgSignatureView.frame=CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2, 0, 0);
                             }

                             self.signtureView.frame=CGRectMake(0, 0, 200, 200);
                         }
                     } completion:^(BOOL finished) {
                         self.signHere.hidden=visible;
                         self.signDone.hidden=!visible;
                         self.signCancel.hidden=!visible;
                         if(self->signData==nil && !visible)
                         {
                             self->_baseSigntureView.hidden=YES;
                         }
                         if (!visible)
                         {
                             [self setUIComponant];
                             if (self.tpscrollview.contentSize.height - self.tpscrollview.bounds.size.height >= 0)
                             {
                                 CGPoint bottomOffset = CGPointMake(0, self.tpscrollview.contentSize.height - self.tpscrollview.bounds.size.height);
                                 [self.tpscrollview setContentOffset:bottomOffset animated:YES];
                             }
                         }
                     }];
}

- (IBAction)onContinue:(id)sender
{
    if (isPhotoNeed)
    {
        if (picData==nil)
        {
            [Common showAlert:@"Alert" :@"Please take photo"];
            return;
        }
    }
    if (isSignNeed)
    {
        if (signData==nil)
        {
            [Common showAlert:@"Alert" :@"Please sign"];
            return;
        }
    }
    // Guard: ensure _visitorDetails is not nil before mutating
    if (_visitorDetails == nil) {
        _visitorDetails = [[NSMutableDictionary alloc] init];
    }
    [_visitorDetails setObject:@"" forKey:@"photoUri"];
    [_visitorDetails setObject:@"" forKey:@"guestSignatureUri"];

    if (picData)
    {
        picData=[Common reSize:picData];
        [_visitorDetails setObject:[Common encodeToBase64String:picData] forKey:@"photoUri"];
    }
    if (signData)
    {
        signData=[Common reSize:signData];
        [_visitorDetails setObject:[Common encodeToBase64String:signData] forKey:@"guestSignatureUri"];
    }

    
    if (_isForImageData)
    {
        if ([Common appDelegate].config.signInApprovalScreen.contractor.isEnabled)
        {
            SiteApproverScreenVC *takePhotoVC = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
            takePhotoVC.visitorDetails = self.visitorDetails;
            takePhotoVC.navTitle = self.navTitle;
            takePhotoVC.isContractor = self.isContractor;
            [self.navigationController pushViewController:takePhotoVC animated:YES];
        }
        else {
        [Common callContractorSignInAPI:_visitorDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                NSLog(@"success");
                [self onPrint:[responseObject mutableCopy] isFrom:@"1"];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[responseObject valueForKey:KEY_ERROR_MESSAGE] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        }
    }
    else
    {
        if ([Common appDelegate].config.signInApprovalScreen.visitor.isEnabled)
        {
            SiteApproverScreenVC *takePhotoVC = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
            takePhotoVC.visitorDetails = self.visitorDetails;
            takePhotoVC.navTitle = self.navTitle;
            takePhotoVC.isContractor = self.isContractor;
            [self.navigationController pushViewController:takePhotoVC animated:YES];
        }
        else
        {
            [self onValideLogin];
        }
    }
}
-(void)onValideLogin
{
    // Fix: if phone is nil, setObject:nil crashes with NSInvalidArgumentException
    NSString *phone = [self.visitorDetails valueForKey:@"phone"];
    [_visitorDetails setObject:(phone ?: @"") forKey:KEY_MOBILE];
    
    [Common callVisitorSignInAPI:_visitorDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSLog(@"success");
            [self onPrint:[responseObject mutableCopy] isFrom:@"0"];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[responseObject valueForKey:KEY_ERROR_MESSAGE] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
               [self.navigationController popToRootViewControllerAnimated:YES];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
- (void)onPrint:(NSMutableDictionary *)responceDic isFrom:(NSString *)isFrom
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel	*_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=responceDic;
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];
    printResultViewController.navTitle = self.navTitle;
    if (_ptp)
    {
//        if ([_ptp isPrinterReady])
//        {
            [printResultViewController.visitorDetails setObject:@"1" forKey:kPrinterStatus];
//        }
//        else
//        {
//            [printResultViewController.visitorDetails setObject:@"Printer is not ready!" forKey:kPrinterMessage];
//        }
    }
    else
    {
        [printResultViewController.visitorDetails setObject:@"Please set printer properly!" forKey:kPrinterMessage];
    }
    [self.navigationController pushViewController:printResultViewController animated:YES];
}

@end
