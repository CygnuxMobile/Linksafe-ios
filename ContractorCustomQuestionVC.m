//
//  ContractorCustomQuestionVC.m
//  LinkSafe
//
//  Created by Kiran on 3/24/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorCustomQuestionVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"

@interface ContractorCustomQuestionVC ()<UITextViewDelegate>

@property (nonatomic, retain) SiteConfig *config;

@end

@implementation ContractorCustomQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Custom Question" parameters:@{@"onload": @"32"}];
    // Do any additional setup after loading the view.
    self.config = [Common appDelegate].config;
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _lblHeader.text = self.config.customQuestionScreen.contractor.questionText;
    
    _tvAnswerDetails.delegate = self;
    _tvAnswerDetails.text = @"Add answer..";
    
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
    NSString *strAnswer = [Common removeWhiteSpace:_tvAnswerDetails.text];
    
    if (strAnswer.length > 0 && ![strAnswer isEqualToString:@"Add answer.."])
    {
        [_ContractorDetail setObject:self.config.customQuestionScreen.contractor.questionText forKey:KEY_CUSTOM_QUE_TEXT];
        [_ContractorDetail setObject:strAnswer forKey:KEY_CUSTOM_QUE_ANS];
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
            _didFinishWithCustomQuestion(_ContractorDetail);
        }
    }
    else
    {
        [Common showAlert:@"Error" :@"Please add answer"];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([[Common removeWhiteSpace:textView.text] isEqualToString:@"Add answer.."])
    {
        textView.text = @"";
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([Common removeWhiteSpace:textView.text].length == 0)
    {
        textView.text = @"Add answer..";
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
