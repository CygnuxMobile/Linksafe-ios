//
//  SiteApproverScreenVC.m
//  LinkSafe
//
//  Created by Kiran on 3/25/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import "SiteApproverScreenVC.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "UILabel+Additions.h"
#import "TakeSignatureVC.h"

@interface SiteApproverScreenVC () <UITextFieldDelegate>
{
    UIImage *signData;
}

@property (nonatomic, retain) SiteConfig *config;

@end

@implementation SiteApproverScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Site Approv" parameters:@{@"onload": @"41"}];
    // Do any additional setup after loading the view.
    _config = [Common appDelegate].config;
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _lblApproverName.textColor = kGetHomeLabelColor;
    _lblSignatureName.textColor = kGetHomeLabelColor;
    _txtApproverName.keyboardType = UIKeyboardTypeDefault;
    _txtApproverName.delegate = self;
    [_txtApproverName  applyGrayBorderTheme];
    if (self.isContractor) {
        _lblHeader.text = _config.signInApprovalScreen.contractor.instructions;
        _lblApproverName.text = _config.signInApprovalScreen.contractor.nameLabelText;
        _lblSignatureName.text = _config.signInApprovalScreen.contractor.signatureLabelText;
        
        _txtApproverName.placeholder = _config.signInApprovalScreen.contractor.nameLabelText;
    }
    else {
        _lblHeader.text = _config.signInApprovalScreen.visitor.instructions;
        _lblApproverName.text = _config.signInApprovalScreen.visitor.nameLabelText;
        _lblSignatureName.text = _config.signInApprovalScreen.visitor.signatureLabelText;
        
        _txtApproverName.placeholder = _config.signInApprovalScreen.visitor.nameLabelText;
    }
    
    [_btnSignHere applyBlueShedow];
    [_btnNext applyBlueShedow];
    
    _btnSignHere.tintColor = [UIColor whiteColor];

    [_signDone applyBlueShedow];
    [_signCancel applyGrayTheme];
    [_btnSignHere applyBlueShedow];
    
    [self.view bringSubviewToFront:_viewSignatureContainer];
    _viewSignatureContainer.hidden = YES;
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
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

- (IBAction)onSignHere:(id)sender
{
    /*
    self.viewSignatureContainer.hidden = NO;
    self.viewSignatureContainer.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
    
        self.viewSignatureContainer.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
    */
    TakeSignatureVC *viewController = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"TakeSignatureVC"];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.didFinishWithCapturedSignature = ^(UIImage *signatureImage) {
        signData = signatureImage;
        self.imgSignature.image = [Common reSize:signData];
    };
    [self presentViewController:viewController animated:YES completion:nil];
    
}

-(IBAction)resetButtonPressed:(id)sender
{
    signData=nil;
    self.imgSignature.image = [UIImage imageNamed:@"signatureImage"];
    [_signtureView clearSignature];
}

-(IBAction)saveButtonPressed:(id)sender
{
    signData = [_signtureView getSignatureImage];
    self.imgSignature.image = [Common reSize:signData];
    [UIView animateWithDuration:0.5 animations:^{
    
        self.viewSignatureContainer.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        self.viewSignatureContainer.hidden = YES;
    }];
}

- (IBAction)onContinue:(id)sender
{
    NSString *approverName = _txtApproverName.text;
    if (approverName.length == 0) {
        [Common showAlert:@"Oops!" :@"Please enter approver name"];
        return;
    }
    if (signData == nil) {
        [Common showAlert:@"Oops!" :@"Please sign"];
        return;
    }
    [_visitorDetails setObject:approverName forKey:@"approverName"];
    [_visitorDetails setObject:@"" forKey:@"approverSignatureUri"];
    if (signData)
    {
        signData=[Common reSize:signData];
        [_visitorDetails setObject:[Common encodeToBase64String:signData] forKey:@"approverSignatureUri"];
    }
    
    if (_isContractor)
    {
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
    else
    {
        [self onValideLogin];
    }
}
-(void)onValideLogin
{
    [_visitorDetails setObject:[self.visitorDetails valueForKey:@"phone"] forKey:KEY_MOBILE];
    
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
    BRLMChannel    *_ptp=[Common prepareForPtp];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}

@end
