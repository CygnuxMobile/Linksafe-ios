//
//  VisitorCustomQuestionVC.m
//  LinkSafe
//
//  Created by Kiran on 3/25/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorCustomQuestionVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"
#import "TakePhotoVC.h"
#import "SiteApproverScreenVC.h"

@interface VisitorCustomQuestionVC ()<UITextViewDelegate>

@property (nonatomic, retain) SiteConfig *config;

@end

@implementation VisitorCustomQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor Custom Question" parameters:@{@"onload": @"17"}];
    // Do any additional setup after loading the view.
    self.config = [Common appDelegate].config;
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _lblHeader.text = self.config.customQuestionScreen.visitor.questionText;
    
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

-(IBAction)didClickNextButton:(id)sender
{
    NSString *strAnswer = [Common removeWhiteSpace:_tvAnswerDetails.text];
    
    if (strAnswer.length > 0 && ![strAnswer isEqualToString:@"Add answer.."])
    {
        [_visitorDetails setObject:self.config.customQuestionScreen.visitor.questionText forKey:KEY_CUSTOM_QUE_TEXT];
        [_visitorDetails setObject:strAnswer forKey:KEY_CUSTOM_QUE_ANS];
        if ([Common appDelegate].config.isPhotoRequiredSignInVisitor || [Common appDelegate].config.isSignatureRequiredVisitor)
        {
            TakePhotoVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
            vc.visitorDetails = _visitorDetails;
            vc.navTitle = self.navTitle;
            vc.isContractor = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([Common appDelegate].config.signInApprovalScreen.visitor.isEnabled)
        {
            SiteApproverScreenVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
            vc.visitorDetails = self.visitorDetails;
            vc.navTitle = self.navTitle;
            vc.isContractor = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [self onValideLogin:_visitorDetails];
        }
    }
    else
    {
        [Common showAlert:@"Error" :@"Please add answer"];
    }
}

-(void)onValideLogin:(NSMutableDictionary *)visitorDetails
{
    [visitorDetails setObject:[visitorDetails valueForKey:@"phone"] forKey:KEY_MOBILE];
    [Common callVisitorSignInAPI:visitorDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSLog(@"success");
            [self onPrint:[responseObject mutableCopy]];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[responseObject valueForKey:@"errorMessage"] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
