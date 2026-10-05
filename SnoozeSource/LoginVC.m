//
//  LoginViewController.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import "LoginVC.h"
#import "Common.h"
#import "SignUpVC.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "BEMCheckBox.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface LoginVC ()
{
    BEMCheckBox *myCheckBox;
    NSString *strTouchPassword;
    BOOL isCancelled;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Login" parameters:@{@"onload": @"5"}];
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.navigationController.navigationBar.hidden = YES;
    
    [_tfPassword  applyFlatTheme];
    [_tfFullName  applyFlatTheme];
    [_btnSignIn  applyBlueShedow];
    myCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(_rememberMe.frame.origin.x, _rememberMe.frame.origin.y-2, _rememberMe.frame.size.width, _rememberMe.frame.size.height)];
    myCheckBox.boxType=BEMBoxTypeSquare;
    myCheckBox.onAnimationType=BEMAnimationTypeBounce;
    myCheckBox.offAnimationType=BEMAnimationTypeBounce;
    
    if([[Common appDelegate] isIpad])
    {
        [myCheckBox setTintColor:kThemeBlueColor];
        [myCheckBox setOnTintColor:kThemeBlueColor];
        [myCheckBox setOnFillColor:[UIColor whiteColor]];
        [myCheckBox setOffFillColor:[UIColor clearColor]];
        [myCheckBox setOnCheckColor:kThemeBlueColor];
    }
    else
    {
        [myCheckBox setTintColor:[UIColor whiteColor]];
        [myCheckBox setOnTintColor:[UIColor whiteColor]];
        [myCheckBox setOnFillColor:[UIColor whiteColor]];
        [myCheckBox setOffFillColor:[UIColor clearColor]];
        [myCheckBox setOnCheckColor:[UIColor whiteColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForTouchId:)
                                                 name:@"Verified"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForTouchId:)
                                                 name:@"notVerified"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CheckUserForTouchID)
                                                 name:@"checkForTouchID"
                                               object:nil];
    
    
    myCheckBox.onFillColor=[UIColor whiteColor];
    myCheckBox.onTintColor=kThemeBlueColor;
    myCheckBox.onCheckColor=kThemeBlueColor;
    
    if ([[Common appDelegate] isIpad])
    {
        UIView *view=[self.view viewWithTag:5500];
        
        [Common ApplyUIViewTheme:view];
        
        [view addSubview:myCheckBox];
    }
    else
    {
        [self.contentView addSubview:myCheckBox];
    }
    
    _rememberMe.hidden = YES;

    UIView *view = self.view;
    if ([view viewWithTag:6601])
    {
        ((UIImageView *)[view viewWithTag:6601]).image = [UIImage imageNamed:[Common appDelegate].isIpad ? @"screenbg.jpg" : @"screenbgmob.jpg"];
    }
    
    [self isTestingOption:NO];
   // [self GetLoginConfig];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"LOGIN";
    
    self.navigationController.navigationBar.hidden = YES;
      self.scroll.contentSize = CGSizeMake(self.view.frame.size.width-10,520);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [self upadteTime];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self CheckUserForTouchID];
}

-(void)CheckUserForTouchID
{
    if([USER_DEFAULT valueForKey:KEY_Remember_SiteUser])
    {
        _tfFullName.text = [NSString stringWithFormat:@"%@",[USER_DEFAULT valueForKey:KEY_Remember_SiteUser]];
        myCheckBox.on = YES;
        if([USER_DEFAULT valueForKey:KEY_Remember_PASSWORD])
        {
            _tfPassword.text = [NSString stringWithFormat:@"%@",[USER_DEFAULT valueForKey:KEY_Remember_PASSWORD]];
            strTouchPassword = _tfPassword.text;
            isCancelled = NO;
        }
        
        NSMutableArray *arrTouchData = [[NSMutableArray alloc]init];
        arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
        
        NSString *txtUserName = [Common removeWhiteSpace:_tfFullName.text];
        
        if(arrTouchData.count>0){
            for (int i = 0; i<arrTouchData.count; i++) {
                NSDictionary *dict = [arrTouchData objectAtIndex:i];
                NSString *strTouchUser = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_SiteUser]];
                
                if ([txtUserName isEqualToString:strTouchUser]) {
                    NSString *strTouchID = [NSString stringWithFormat:@"%@",[dict valueForKey:kTouchID]];
                    if ([strTouchID isEqualToString:@"1"]){
                        strTouchPassword = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_PASSWORD]];
                        if ([USER_DEFAULT boolForKey:kNewLogin]){
                            [JZTouchID openTouchId:NO];
                            break;
                        }
                    }
                }
            }
        }
    }
}


-(void)upadteTime
{
    [Common updateTime:self.view];
    
    if (![self.view viewWithTag:5214]) {
        return;
    }
    UILabel *lableTime = [self.view viewWithTag:5214];
    lableTime.textColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Verified" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notVerified" object:nil];
}

-(void)checkForTouchId:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"notVerified"]){
        isCancelled = YES;
    }
    else if ([[notification name] isEqualToString:@"Verified"]){
        
        NSString *txtUserName = [Common removeWhiteSpace:_tfFullName.text];
        _tfPassword.text = strTouchPassword;
        NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_SiteUser:txtUserName,KEY_PASSWORD:strTouchPassword}];
        
        [Common callAPI:dicParameters Request:REQUEST_LOGIN ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_TOKEN]] length]>0)
                {
                    [Common saveSiteToken:[responseObject valueForKey:KEY_TOKEN] rememberMe:self->myCheckBox.on?@"1":@"0"];
                    
                    NSMutableDictionary *siteData = [Common SiteData];
                    [siteData setObject:txtUserName forKey:KEY_SiteUser];
                    [siteData setObject:strTouchPassword forKey:KEY_PASSWORD];
                    [Common storeSiteData:siteData];
                    
                    if(myCheckBox.on){
                        [USER_DEFAULT setObject:txtUserName forKey:KEY_Remember_SiteUser];
                        [USER_DEFAULT setObject:strTouchPassword forKey:KEY_Remember_PASSWORD];
                    }
                    else {
                        if([[[USER_DEFAULT dictionaryRepresentation] allKeys] containsObject:KEY_Remember_SiteUser]){
                            [USER_DEFAULT removeObjectForKey:KEY_Remember_SiteUser];
                        }
                        if([[[USER_DEFAULT dictionaryRepresentation] allKeys] containsObject:KEY_Remember_PASSWORD]){
                            [USER_DEFAULT removeObjectForKey:KEY_Remember_PASSWORD];
                        }
                    }
                    
                    [USER_DEFAULT setBool:YES forKey:kIsFromLoginScreen];
                    [USER_DEFAULT setBool:NO forKey:kNewLogin];
                    [USER_DEFAULT synchronize];
                    
                    [self performSelector:@selector(showProgressWithSettinLabel) withObject:nil afterDelay:0.1];
                    [[Common appDelegate] downloadBackgroundImages];
                }
                else
                {
                    [Common showAlert:@"Message" :@"Please try again"];
                }
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg.length>0?errorMsg:@"Please try again." : @""];
            }
        }];
    }
}

-(void)isTestingOption:(BOOL)isTest
{
    [Common SetTestEnviromentWithOption:(isTest ? TestEnvironmentOptionAvailable : TestEnvironmentOptionNotAvailable)];
}

- (void)GetLoginConfig
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [Common callAPI:dicParameters Request:API_GET_LOGIN_CONFIGUE ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue]) {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_IsEnvironmentOptionVisible]] boolValue]) {
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Environment Setting" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Production" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [Common SetTestEnviromentWithOption:TestEnvironmentOptionAvailable];
                }];
                [controller addAction:alertAction];
            
                UIAlertAction *alertActionTesting = [UIAlertAction actionWithTitle:@"Testing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [Common SetTestEnviromentWithOption:TestEnvironmentOptionWantToTesting];
                }];
                [controller addAction:alertActionTesting];
                [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
                }];
            }
        } else {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg.length>0?errorMsg:@"Please try again." : @""];
        }
    }];
}

- (IBAction)txtUserNameDidEdit:(id)sender {
    NSMutableArray *arrTouchData = [[NSMutableArray alloc]init];
    arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
    
    NSString *txtUserName = [Common removeWhiteSpace:_tfFullName.text];
    
    if(arrTouchData.count>0){
        for (int i = 0; i<arrTouchData.count; i++) {
            NSDictionary *dict = [arrTouchData objectAtIndex:i];
            NSString *strTouchUser = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_SiteUser]];
            
            if ([txtUserName isEqualToString:strTouchUser]) {
                NSString *strTouchID = [NSString stringWithFormat:@"%@",[dict valueForKey:kTouchID]];
                if ([strTouchID isEqualToString:@"1"]){
                    strTouchPassword = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_PASSWORD]];
                    [JZTouchID openTouchId:NO];
                }
            }
        }
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _tfFullName)
    {
        NSMutableArray *arrTouchData = [[NSMutableArray alloc]init];
        arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
        
        NSString *txtUserName = [Common removeWhiteSpace:_tfFullName.text];
        
        if(arrTouchData.count>0){
            for (int i = 0; i<arrTouchData.count; i++) {
                NSDictionary *dict = [arrTouchData objectAtIndex:i];
                NSString *strTouchUser = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_SiteUser]];
                
                if ([txtUserName isEqualToString:strTouchUser]) {
                    NSString *strTouchID = [NSString stringWithFormat:@"%@",[dict valueForKey:kTouchID]];
                    if ([strTouchID isEqualToString:@"1"]){
                        strTouchPassword = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_PASSWORD]];
                        [JZTouchID openTouchId:NO];
                    }
                }
            }
        }
    }
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == _tfPassword)
    {
        return YES;
    }
    else
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
}

- (IBAction)onLogin:(id)sender
{
    NSString *txtUserName = [Common removeWhiteSpace:_tfFullName.text];
    NSString *txtPassword = [Common removeWhiteSpace:_tfPassword.text];
    [self.view endEditing:YES];
    if (txtUserName.length ==0)
    {
        [Common showAlert:@"Oops!" :@"Please enter username"];
    }
    else if (txtPassword.length ==0)
    {
        [Common showAlert:@"Oops!" :@"Please enter password"];
    }
    else
    {
        if ([txtUserName hasPrefix:@"test_"]) {
            [Common SetTestEnviromentWithOption:TestEnvironmentOptionWantToTesting];
            txtUserName = [txtUserName substringFromIndex:5];
        }
        
        
        NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_SiteUser:txtUserName,KEY_PASSWORD:txtPassword}];
        
        [Common callAPI:dicParameters Request:REQUEST_LOGIN ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_TOKEN]] length]>0)
                {
                    [Common saveSiteToken:[responseObject valueForKey:KEY_TOKEN] rememberMe:self->myCheckBox.on?@"1":@"0"];
                    
                    NSMutableDictionary *siteData = [Common SiteData];
                    [siteData setObject:txtUserName forKey:KEY_SiteUser];
                    [siteData setObject:txtPassword forKey:KEY_PASSWORD];
                    [Common storeSiteData:siteData];
                    
                    if(myCheckBox.on){
                        [USER_DEFAULT setObject:txtUserName forKey:KEY_Remember_SiteUser];
                        [USER_DEFAULT setObject:txtPassword forKey:KEY_Remember_PASSWORD];
                    }
                    else {
                        if([[[USER_DEFAULT dictionaryRepresentation] allKeys] containsObject:KEY_Remember_SiteUser]){
                            [USER_DEFAULT removeObjectForKey:KEY_Remember_SiteUser];
                        }
                        if([[[USER_DEFAULT dictionaryRepresentation] allKeys] containsObject:KEY_Remember_PASSWORD]){
                            [USER_DEFAULT removeObjectForKey:KEY_Remember_PASSWORD];
                        }
                    }
                    
                    [USER_DEFAULT setBool:YES forKey:kIsFromLoginScreen];
                    [USER_DEFAULT synchronize];
                    
                    [self performSelector:@selector(showProgressWithSettinLabel) withObject:nil afterDelay:0.1];
                    [[Common appDelegate] downloadBackgroundImages];
                 }
                else
                {
                    [Common showAlert:@"Message" :@"Please try again"];
                }
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg.length>0?errorMsg:@"Please try again." : @""];
            }
        }];
    }
}

-(void)showProgressWithSettinLabel
{
    [SVProgressHUD showWithStatus:@"Please wait while we load your settings."];
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
