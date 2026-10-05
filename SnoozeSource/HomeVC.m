//
//  HomeVC.m
//  LinkSafe
//
//  Created by Hitesh Gs on 09/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import "HomeVC.h"
#import "MFSideMenu.h"
#import "UserLogin.h"
#import "UIButton+Additions.h"
#import "SignOutVC.h"
#import "UserRegistrationVC.h"
#import "ContractorSignInVC.h"
#import "ContractorSignOut.h"
#import "VisitorSignOut.h"
#import "UIImageView+WebCache.h"
#import "MessageBoardVC.h"
#import "ContractorWorkFlowVC.h"
#import "ScannerViewController.h"
#import "AppDelegate.h"


@interface HomeVC ()<UIAlertViewDelegate>
{
    NSMutableArray *arrMessages;
    NSMutableDictionary *messageBoardParameters;
    NSString *loginString;
    BOOL isVisitor;
    BOOL isContractor;
}

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"home" parameters:@{@"onload": @"1"}];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBarTintColor:kGetThemeColor];
    [[UINavigationBar appearance] setBarTintColor:kGetThemeColor];
    
    [_btnVisitor setTitle:@"" forState:UIControlStateNormal];
    [_btnContractor setTitle:@"" forState:UIControlStateNormal];
    
    [self setLogo];
    
    [_btnSIgnOut applyGrayTheme];
    [_btnContractor applyBlueShedow];
    [_btnVisitor applyBlueShedow];
    
    [_lblWarning setTextColor:kGetHomeLabelColor];
    //    [_lblPowerBy setTextColor:kGetHomeLabelColor];
    [_siteName setTextColor:kGetHomeLabelColor];
    
    [Common ApplyClearUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyClearUIViewTheme:[self.view viewWithTag:5502]];
    
    [_btnContractor setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    [_btnContractor setHighlightedColor:kGetThemeColor];
    [Common initWithUserDefault];
    
    
    _btnContractor.hidden=YES;
    _btnVisitor.hidden=YES;
    _btnSIgnOut.hidden=YES;
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"LinkSafe Site";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setbutton)
                                                 name:N_HomeUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    
    [self upadteTime];
    //    [self performSelector:@selector(setbutton) withObject:nil afterDelay:0.12];
    [Common setBgImage:self.view useDefault:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:KEY_MESSAGE_BOARDS];
    [userDefaults synchronize];
}

-(void)updateBackground
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Common setBgImage:self.view useDefault:NO];
    });
}

-(void)upadteTime
{
    [Common updateTime:self.view];
    [_lblDateTime setTextColor:kGetHomeLabelColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_HomeUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)setLogo
{
    AsyncImageView *imageView = (AsyncImageView *)[self.view viewWithTag:3301];
    imageView.imageURL = [NSURL URLWithString:[[Common SiteData] valueForKey:KEY_HOME_LOGO]];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_HOME_LOGO]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error || image == nil)
        {
            imageView.image = image;
        }
        else
        {
            if ([[Common appDelegate] isIpad])
            {
                [self setImageView:image imageView:imageView];
            }
            NSLog(@"i am here with image");
        }
    }];
}

-(void)setImageView:(UIImage *)logoImage imageView:(AsyncImageView *)logoView
{
    if (logoImage==nil)
    {
        return;
    }
    logoView.image=logoImage;
    
    CGFloat width = logoImage.size.width;
    CGFloat height = logoImage.size.height;
    
    CGFloat aspectRatio=height/width;
    CGFloat newWidth=logoView.frame.size.height/aspectRatio;
    
    CGRect logoFrame=logoView.frame;
    logoFrame.size.width=newWidth;
    
    NSString *strPosition = [[Common SiteData] valueForKey:@"homeScreenLogoAlignment"];
    
    if([strPosition isEqualToString:@"right"]){
        logoFrame.origin.x = [UIScreen mainScreen].bounds.size.width - 15 - newWidth;
    }
    else if([strPosition isEqualToString:@"left"]){
        logoFrame.origin.x = 15;
    }
    else{
        logoFrame.origin.x = [UIScreen mainScreen].bounds.size.width/2 - newWidth/2;
    }
    
    logoView.frame=logoFrame;
}

-(void)setbutton
{
    NSLog(@"Setbutton called");
    SiteConfig *config = [Common appDelegate].config;
    isVisitor = config.isVisitorsButtonVisible;
    isContractor = config.isContractorsButtonVisible;
    
    if (config.isSiteRegisterEnabled)
    {
        _btnSIgnOut.hidden=NO;
    }
    else
    {
        _btnSIgnOut.hidden=YES;
    }
    
    self.siteName.text=[NSString stringWithFormat:@"Welcome to %@",config.siteName ? config.siteName : @"LinkSafe Site"];
    
    [_btnVisitor setTitle:[[NSString stringWithFormat:@"%@",config.visitorsButtonText] uppercaseString] forState:UIControlStateNormal];
    [_btnContractor setTitle:[[NSString stringWithFormat:@"%@",config.contractorsButtonText] uppercaseString] forState:UIControlStateNormal];
    
    if (isContractor && isVisitor)
    {
        [self.view viewWithTag:5501].hidden=NO;
        _btnContractor.hidden=NO;
        _btnVisitor.hidden=NO;
    }
    else if (isContractor || isVisitor)
    {
        if (isVisitor)
        {
            _btnContractor.hidden=YES;
            _btnVisitor.hidden=NO;
            if ([Common appDelegate].isIpad)
            {
                CGRect rectVisitor=_btnVisitor.frame;
                rectVisitor.origin.x=([self.view viewWithTag:5501].frame.size.width-rectVisitor.size.width)/2;
                _btnVisitor.frame=rectVisitor;
            }
        }
        else
        {
            _btnContractor.hidden=NO;
            _btnVisitor.hidden=YES;
            if ([Common appDelegate].isIpad)
            {
                CGRect rectCont=_btnContractor.frame;
                rectCont.origin.x=(self.view.frame.size.width-rectCont.size.width)/2;
                _btnContractor.frame=rectCont;
                
            }
        }
    }
    else
    {
        _btnContractor.hidden=YES;
        _btnVisitor.hidden=YES;
    }
    [self setLogo];
}

#pragma IBAction

- (IBAction)onContactor:(id)sender
{
    loginString = @"Contractor";
    
    //    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_WORK_ENABLED]];
    
    //    if([strIsSpotCheckUser isEqualToString:@"false"]){
    [self getSignInSignOutMessageBoard:@"Contractor" andEvent:@"SignIn"];
    //    }
    //    else{
    //        ContractorWorkFlowVC *ContractorWorkFlowTVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorWorkFlowVC"];
    //        ContractorWorkFlowTVC.registrationType = @"Contractor";
    //        ContractorWorkFlowTVC.eventType = @"SignIn";
    //        ContractorWorkFlowTVC.btnTitleType = _btnContractor.currentTitle;
    //        ContractorWorkFlowTVC.navTitle = _btnContractor.currentTitle;
    //        [self.navigationController pushViewController:ContractorWorkFlowTVC animated:YES];
    //    }
    
    
}

- (void)onPrint:(NSMutableDictionary *)responceDic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel	*_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=responceDic;
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];;
    if (_ptp)
    {
        //        if ([_ptp isPrinterReady])
        //        {
        [printResultViewController.visitorDetails setObject:@"1" forKey:kPrinterStatus];
        [printResultViewController.visitorDetails setObject:@"1" forKey:@"istest"];
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

- (IBAction)onVisitor:(id)sender
{
    //    NSMutableArray *titles = [[NSMutableArray alloc] initWithObjects:LBL_New_Registration,LBL_Already_Registered, nil];
    //    if ([[NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:@"isPreRegistrationEnabled"]] boolValue]) {
    //        [titles addObject:@"Pre-registered"];
    //    }
    //@[][1];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Visitor Registration"
                                                             delegate:self
                                                    cancelButtonTitle:[@"Cancel" uppercaseString]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:LBL_New_Registration, LBL_Already_Registered, ([[NSString stringWithFormat:@"%@", [[Common SiteData] valueForKey:@"isPreRegistrationEnabled"]] boolValue] ? LBL_Pre_Registred : nil), nil];
    actionSheet.tintColor = kGetThemeColor;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[@"Cancel" uppercaseString]])
    {
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:LBL_Already_Registered])
    {
        loginString = @"Already registered?";
        [self getSignInSignOutMessageBoard:@"Visitor" andEvent:@"SignIn"];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:LBL_New_Registration])
    {
        loginString = @"New registration";
        [self getSignInSignOutMessageBoard:@"Visitor" andEvent:@"SignIn"];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:LBL_Pre_Registred])
    {
        loginString = @"Pre-Registered";
        [self getSignInSignOutMessageBoard:@"Visitor" andEvent:@"SignIn"];
    }
}


- (IBAction)onSignOut:(id)sender
{
    //    BOOL isVisitor = [Common appDelegate].config.isVisitorsButtonVisible;
    //    BOOL isContractor = [Common appDelegate].config.isContractorsButtonVisible;
    
    if(isVisitor && isContractor)
    {
        SignOutVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SignOutVC"];
        vc.strContractor = _btnContractor.currentTitle;
        vc.strVisitor = _btnVisitor.currentTitle;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if(isContractor)
        {
            [self getSignInSignOutMessageBoard:@"Contractor" andEvent:@"SignOut"];
        }
        else
        {
            [self getSignInSignOutMessageBoard:@"Visitor" andEvent:@"SignOut"];
        }
    }
}

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

-(void)getSignInSignOutMessageBoard:(NSString *)registrationType andEvent:(NSString *)eventType
{
    /*
     {
     "Token":
     "D0F894C8CDC3FF917FDB7943A437FA49E26DFF7D7D5CB11D5FCED43170CE40248544F8DF82569B0BAD87B
     FF7DCB38CE1A4E3C65C9705D48D2B59BA33CA1D65C4",
     "RegistrationType": "Contractor" / "Visitor",
     "EventType": "SignIn" / "SignOut"
     }
     */
    
    //test spotcheck user
    
    BOOL isSpotCheckUser = [[NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_SPOT_CHECKUSER]] boolValue];
    
    if(isSpotCheckUser && [registrationType isEqualToString:@"Contractor"]){
        ContractorSignInVC *contractorSignInVC = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignInVC"];
        contractorSignInVC.navTitle = _btnContractor.currentTitle;
        contractorSignInVC.isSpotUser = YES;
        [self.navigationController pushViewController:contractorSignInVC animated:YES];
    }
    else{
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:registrationType forKey:KEY_REGISTRATION_TYPE];
        [parameters setObject:eventType forKey:KEY_EVENT_TYPE];
        messageBoardParameters = parameters;
        [Common callAPI:parameters Request:REQUEST_GET_MESSAGE_BOARDS ShowProgress:YES WithCompletionHandler:^(id responseObject)
         {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                self->arrMessages = [[responseObject objectForKey:@"messages"] mutableCopy];
                //            [arrMessages addObject:@"<html><body>Hi, here’s a sign-in message for you 1!</body></html>"];
                //            [arrMessages addObject:@"<html><body>Hi, here’s a sign-in message for you 2!</body></html>"];
                [self showMessagBoard];
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg : @""];
            }
        }];
    }
}

-(void)showMessagBoard
{
    if (arrMessages.count == 0)
    {
        if ([[messageBoardParameters objectForKey:KEY_EVENT_TYPE] isEqualToString:@"SignIn"])
        {
            if ([loginString isEqualToString:@"Contractor"])
            {
                ContractorSignInVC *contractorSignInVC = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignInVC"];
                contractorSignInVC.navTitle = _btnContractor.currentTitle;
                [self.navigationController pushViewController:contractorSignInVC animated:YES];
            }
            else if ([loginString isEqualToString:@"Already registered?"])
            {
                UserLogin *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserLogin"];
                vc.navTitle =_btnVisitor.currentTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([loginString isEqualToString:@"New registration"])
            {
                UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
                vc.visitorDetails=nil;
                vc.isUpdate=NO;
                vc.navTitle =_btnVisitor.currentTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([loginString isEqualToString:@"Pre-Registered"])
            {
                
                //                [self validatePreregistration:@"MP_B379C233256A9E3FB7AA139B419CA79B6211844DB2A6A4464AABBDF80538D18796D7E5F93708C31A4ACAD3DD3CF255FACB7DA7F5A186C6360048EEE3746F6AD7"];
                
                [self.view endEditing:YES];
                ScannerViewController *scannerViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ScannerViewController"];
                scannerViewController.navTitle = _btnVisitor.currentTitle;
                scannerViewController.didFinishwithQRDetail = ^(NSMutableDictionary *updaedVisitorDetails)
                {
                    NSString *qrCode = [updaedVisitorDetails valueForKey:@"QRCode"];
                    if ([qrCode length] > 0)
                    {
                        [self validatePreregistration:qrCode];
                    }
                    else
                    {
                        [Common showAlert:@"Please scan valide QRCode" :@""];
                    }
                };
                [self.navigationController pushViewController:scannerViewController animated:YES];
            }
            else {
                [Common showAlert:@"" :@"Screen not identified."];
            }
        }
        else
        {
            if ([[messageBoardParameters objectForKey:KEY_REGISTRATION_TYPE] isEqualToString:@"Contractor"])
            {
                ContractorSignOut *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignOut"];
                vc.navTitle = _btnContractor.currentTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                VisitorSignOut *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOut"];
                vc.navTitle = _btnVisitor.currentTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else
    {
        MessageBoardVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"MessageBoardVC"];
        next.arrMessages = arrMessages;
        next.didFinishAcknowledge = ^(NSMutableDictionary *response)
        {
            if ([[response objectForKey:@"isFinished"] isEqualToString:@"yes"])
            {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                [self->arrMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [result addObject:obj[@"id"]];
                }];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:result forKey:KEY_MESSAGE_BOARDS];
                [userDefaults synchronize];
                
                [self->arrMessages removeAllObjects];
                [self showMessagBoard];
            }
            else
            {
                //Hide Message board
                //don't do anything
            }
        };
        next.view.backgroundColor = [UIColor clearColor];
        next.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:next animated:YES completion:^{}];
        
        /*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Acknowledge", nil];
         
         UIWebView *webView = [[UIWebView alloc] init];
         [webView setFrame:CGRectMake(0,0,300,300)];
         [webView loadHTMLString:[arrMessages objectAtIndex:0] baseURL:nil];
         
         UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
         [view addSubview:webView];
         [alert setValue:view forKey:@"accessoryView"];
         [alert show];
         */
    }
}

-(void)validatePreregistration:(NSString *)qrCode {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:qrCode forKey:@"decodedString"];
    [Common callAPI:parameters Request:GET_PRE_REGISTRATION_DETAILS ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        
        //        NSString *jsonString = @"{\"visitor\":{\"title\":\"Mr\",\"firstName\":\"john\",\"lastName\":\"carry\",\"organisation\":\"DownTown\",\"phone\":\"9898989898\",\"vehicleRegistrationNumber\":\"GJ5001\",\"custom1\":\"C1Test\",\"custom2\":\"C2Test\",\"custom3\":\"C3Test\",\"custom4\":\"C4Test\",\"custom5\":\"C5Test\"},\"success\":true,\"helpfulErrorMessage\":null,\"debugInfo\":null,\"errorNumber\":null,\"errorMessage\":null}";
        //
        //        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        //        NSError *error;
        //        responseObject = [NSJSONSerialization JSONObjectWithData:jsonData
        //                                                           options:NSJSONReadingAllowFragments
        //                                                             error:&error];
        
        //        if (error) {
        //            NSLog(@"Got an error: %@", error);
        //        } else {
        //            NSLog(@"%@", data);
        //        }
        
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[responseObject objectForKey:@"visitor"]];
            [data setObject:@"1" forKey:KEY_FROM_SEARCH];
            UserRegistrationVC *userUpdateVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
            //             userUpdateVC.isUpdate = YES;
            userUpdateVC.visitorDetails = data;
            userUpdateVC.navTitle = _btnVisitor.currentTitle;
            [self.navigationController pushViewController:userUpdateVC animated:YES];
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_HELP_MESSAGE]]];
        }
    }];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

@end
