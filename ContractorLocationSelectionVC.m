//
//  ContractorLocationSelectionVC.m
//  LinkSafe
//
//  Created by kartik on 01/12/17.
//  Copyright © 2017 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorLocationSelectionVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"

@interface ContractorLocationSelectionVC ()<UITextViewDelegate>

@end

@implementation ContractorLocationSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Location Selection" parameters:@{@"onload": @"30"}];
    // Do any additional setup after loading the view.
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _tvLocationDetails.delegate = self;
    _tvLocationDetails.text = @"Add location..";
    
    [_btnNext applyBlueShedow];

    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    
    [[self.view viewWithTag:5501].layer setBorderWidth:1];
    
    [[self.view viewWithTag:5501].layer setBorderColor:[[UIColor whiteColor]CGColor]];
        
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.navigationItem.title=self.navTitle;//@"LinkSafe Site";
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickNextButton:(id)sender
{
    NSString *strLocation = [Common removeWhiteSpace:_tvLocationDetails.text];
    
    if (strLocation.length > 0 && ![strLocation isEqualToString:@"Add location.."])
    {
        [_ContractorDetail setObject:strLocation forKey:KEY_WORK_Location];
        SiteConfig *config = [Common appDelegate].config;
        if(!config.isWorkPermitsEnabled && !config.isPhotoRequiredSignInContractor && !config.isSignatureRequiredContractor && !config.signInApprovalScreen.contractor.isEnabled)
        {            
            [Common callContractorSignInAPI:_ContractorDetail ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                {
                    NSLog(@"success");
                    [self onPrint:[responseObject mutableCopy]];
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
            [self.navigationController popViewControllerAnimated:NO];
            _didFinishWithJobLocation(_ContractorDetail);
        }
    }
    else
    {
        [Common showAlert:@"Error" :@"Please add location"];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([[Common removeWhiteSpace:textView.text] isEqualToString:@"Add location.."])
    {
        textView.text = @"";
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([Common removeWhiteSpace:textView.text].length == 0)
    {
        textView.text = @"Add location..";
    }
}

- (void)onPrint:(NSMutableDictionary *)responceDic
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

@end
