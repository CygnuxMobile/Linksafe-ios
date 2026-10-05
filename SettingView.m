//
//  SettingView.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 24/11/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "SettingView.h"
#import "MFSideMenu.h"
#import "BRSearchDeviceByWiFiTableViewController.h"
#import "BRPrintResultViewController.h"
#import "UserDefaults.h"
#import "FTIndicator.h"
#import "BRImagePrintViewController.h"
#import "BRPrintSettingsTableViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define Scale [UIScreen mainScreen].scale

@interface SettingView ()
{
    NSString *settingKey;
    BOOL isTouch;
}
@property (strong,nonatomic) LAContext* context;
@end

@implementation SettingView{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Setting" parameters:@{@"onload": @"6"}];
    _lblVersion.textColor = kGetHomeLabelColor;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    CFBundleVersion
//    CFBundleShortVersionString
    _lblVersion.text = [NSString stringWithFormat:@"Version: %@", version];
    _lbCamera.text=[[USER_DEFAULT valueForKey:KEY_CAMERA] localizedCapitalizedString];
    _lbQRCode.text=[[USER_DEFAULT valueForKey:KEY_QRCodeCam] localizedCapitalizedString];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    UIView *myview = [self.view viewWithTag:5501];
    [Common ApplyUIViewTheme:myview];
    [myview.layer setBorderWidth:1.0f];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    isTouch = [USER_DEFAULT boolForKey:kTouchID];
    
    _swichTouchID.layer.cornerRadius = 16.0;
    if(isTouch){
        [_swichTouchID setOn:YES];
        _swichTouchID.backgroundColor = [UIColor greenColor];
//        [_swichTouchID setThumbTintColor:[UIColor greenColor]];
    }
    else{
        [_swichTouchID setOn:NO];
        _swichTouchID.backgroundColor = [UIColor redColor];
//        [_swichTouchID setThumbTintColor:[UIColor redColor]];
    }
}


-(void)setViewSettingFrame
{
//    BOOL isIpad=[[Common appDelegate] isIpad];
//    CGRect viewSettingFrame=_viewSetting.frame;
//    viewSettingFrame.size.height=isIpad?300:180;
//    CGRect lbprinterFrame=_lbPrinter.frame;
//    lbprinterFrame.origin.y=isIpad?30:20;
//
//    CGRect viewPrintersFrame = _viewPrinters.frame;
//    viewPrintersFrame.size.height = isIpad?100:60;
//
//    if ([USER_DEFAULT valueForKey:kSelectedDevice]) {
//        if ([[USER_DEFAULT valueForKey:kSelectedDevice] length]>0)
//        {
//            if ([USER_DEFAULT valueForKey:kIPAddress]) {
//                if ([[USER_DEFAULT valueForKey:kIPAddress] length]>0)
//                {
//                    NSLog(@"%@-%@",[USER_DEFAULT valueForKey:kSelectedDevice],[USER_DEFAULT valueForKey:kIPAddress]);
//                    viewPrintersFrame.size.height = isIpad?100:60;
//                    viewSettingFrame.size.height=isIpad?300:180;
//                    lbprinterFrame.origin.y=10;
//                }
//            }
//        }
//    }
//
//    _lbPrinter.frame=lbprinterFrame;
//    _viewSetting.frame=viewSettingFrame;
    
    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userSpot"]];
    
    if ([strIsSpotCheckUser isEqualToString:@"1"]) {
        _viewPrinters.hidden = YES;
    }
    else {
        _viewPrinters.hidden = NO;
    }
    BOOL hasTouchID = NO;
    if ([LAContext class]) {
        self.context = [[LAContext alloc] init];
        
        NSError *error = nil;
        if ([_context canEvaluatePolicy:1 error:&error]) {
            hasTouchID = YES;
        }
        else{
            switch (error.code) {
                case LAErrorPasscodeNotSet:{
                    NSLog(@"Authentication could not be started because the device does not have a password set.");
                    hasTouchID = YES;
                    break;
                }
                case LAErrorTouchIDNotEnrolled:{
                    hasTouchID = NO;
                    break;
                }
                case LAErrorTouchIDLockout:{
                    hasTouchID = YES;
                    break;
                }
                default:{
                    NSLog(@"TouchID is not available");
                    hasTouchID = NO;
                    break;
                }
                    
            }
        }
        _viewTouchID.hidden = !hasTouchID;
//        _viewPrinters.frame = viewPrintersFrame;
//        if(!hasTouchID){
//            _viewTouchID.hidden = YES;
//        }
//        else{
//            CGRect viewTouchFrame = _viewTouchID.frame;
//            viewTouchFrame.origin.y = viewPrintersFrame.size.height + viewPrintersFrame.origin.y;
//            _viewTouchID.frame = viewTouchFrame;
//            BOOL isIpad=[[Common appDelegate] isIpad];
//            CGRect viewSettingFrame=_viewSetting.frame;
//            viewSettingFrame.size.height = viewTouchFrame.size.height + viewTouchFrame.origin.y;
//            _viewSetting.frame=viewSettingFrame;
//        }
    }
    
}
-(void)upadteTime
{
    [Common updateTime:self.view];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=@"SETTINGS";
    [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(upadteTime)
             name:N_UpdateTime
           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    _lbPrinterIp.hidden = YES;
    if ([USER_DEFAULT valueForKey:kSelectedDevice]) {
        _lbPrinter.text=[USER_DEFAULT valueForKey:kSelectedDevice];
        if ([USER_DEFAULT valueForKey:kIPAddress]) {
            _lbPrinterIp.text=[USER_DEFAULT valueForKey:kIPAddress];
            _lbPrinterIp.hidden = (_lbPrinterIp.text.length == 0);
        }
    }
    [self upadteTime];
    [self setViewSettingFrame];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (IBAction)onSwitchCamera:(id)sender
{
    settingKey=KEY_CAMERA;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select camera"
       delegate:self
                cancelButtonTitle:[@"Cancel" uppercaseString]
           destructiveButtonTitle:nil
                otherButtonTitles:[VALUE_CAMERA_FRONT uppercaseString],[VALUE_CAMERA_REAR uppercaseString], nil];
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[@"Cancel" uppercaseString]]) {
        return;
    }
    NSMutableDictionary *siteData=[Common SiteData];
    
    [siteData setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:settingKey];
    [USER_DEFAULT setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:settingKey];
    [USER_DEFAULT synchronize];
    if ([settingKey isEqualToString:KEY_QRCodeCam])
    {
        _lbQRCode.text=[[siteData valueForKey:settingKey] localizedCapitalizedString];
    }
    else
    {
        _lbCamera.text=[[siteData valueForKey:settingKey] localizedCapitalizedString];
    }
    [Common storeSiteData:siteData];
    [self checkAndSaveCameraSettings];
}

- (IBAction)onSelectBarcode:(id)sender
{
    settingKey=KEY_QRCodeCam;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select camera for scan QRCode"
       delegate:self
                cancelButtonTitle:[@"Cancel" uppercaseString]
           destructiveButtonTitle:nil
                otherButtonTitles:[VALUE_CAMERA_FRONT uppercaseString],[VALUE_CAMERA_REAR uppercaseString], nil];
    [actionSheet showInView:self.view];
}
- (IBAction)onSelectPrinter:(id)sender
{
    UIStoryboard *imagePrintViewStoryboard = [UIStoryboard storyboardWithName: @"BRImagePrintViewController" bundle: nil];
    BRImagePrintViewController *imagePrintViewController = (BRImagePrintViewController *)[imagePrintViewStoryboard instantiateViewControllerWithIdentifier: @"imagePrintViewController"];
    [self.navigationController pushViewController:imagePrintViewController animated:YES];
    /*
    BRSearchDeviceByWiFiTableViewController *nextViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"BRSearchDeviceByWiFiTableViewController"];
    nextViewController.mSearchMode = BRSearchModeIPv6IPv4;
    
    nextViewController.didFinishwithSearch = ^(NSMutableDictionary *printerDetails)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self->_lbPrinter.text=@"";
        self->_lbPrinterIp.text=@"";
        
        if ([userDefaults valueForKey:kSelectedDevice]) {
            self->_lbPrinter.text=[userDefaults valueForKey:kSelectedDevice];
            if ([userDefaults valueForKey:kIPAddress]) {
                self->_lbPrinterIp.text=[userDefaults valueForKey:kIPAddress];
            }
        }
        NSLog(@"%@ - %@",[userDefaults valueForKey:kSelectedDevice],[userDefaults valueForKey:kIPAddress]);
        [self setViewSettingFrame];
    };

    [self.navigationController pushViewController:nextViewController animated:YES];
    */
}

- (IBAction)onSwitchClicked:(id)sender {
    SiteConfig *config = [Common appDelegate].config;
    NSMutableArray *arrTouchData = [[NSMutableArray alloc]init];
    arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
    
    NSMutableDictionary *siteData = [Common SiteData];
    NSString *userPass = [NSString stringWithFormat:@"%@",[siteData valueForKey:KEY_PASSWORD]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",(config.siteName ? config.siteName : @"Alert")] message:@"Site Password" preferredStyle:UIAlertControllerStyleAlert];
    NSString *varifyLable = @"Verify";
    
    [alert addAction:[UIAlertAction actionWithTitle:varifyLable style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *alertTextField = alert.textFields.firstObject;
        
        if ([alertTextField.text isEqualToString:userPass]){
            if(isTouch){
                [_swichTouchID setOn:NO];
                _swichTouchID.backgroundColor = [UIColor redColor];
                isTouch = NO;
                [FTIndicator showSuccessWithMessage:@"TouchID/FaceID Disabled"];
                [USER_DEFAULT setBool:NO forKey:kTouchID];
            }
            else{
                BOOL hasTouchID = NO;
                if ([LAContext class]) {
                    self.context = [[LAContext alloc] init];
                    
                    NSError *error = nil;
                    if ([_context canEvaluatePolicy:1 error:&error]) {
                        hasTouchID = YES;
                    }
                    else{
                        switch (error.code) {
                            case LAErrorPasscodeNotSet:{
                                [Common showAlert:@"Alert" :@"Authentication could not be started because the device does not have a password set."];
                                NSLog(@"Authentication could not be started because the device does not have a password set.");
                                hasTouchID = NO;
                                break;
                            }
                            case LAErrorTouchIDNotEnrolled:{
                                [Common showAlert:@"Alert" :@"Authentication could not be started because the device does not have a password set."];
                                hasTouchID = NO;
                                break;
                            }
                            case LAErrorTouchIDLockout:{
                                hasTouchID = YES;
                                break;
                            }
                            default:{
                                NSLog(@"TouchID is not available");
                                hasTouchID = NO;
                                break;
                            }
                        }
                    }
                    if(hasTouchID){
                        [_swichTouchID setOn:YES];
                        _swichTouchID.backgroundColor = [UIColor greenColor];
                        isTouch = YES;
                        [FTIndicator showSuccessWithMessage:@"TouchID/FaceID enabled"];
                        [USER_DEFAULT setBool:hasTouchID forKey:kTouchID];
                    }
                }
            }
            [USER_DEFAULT synchronize];
            NSMutableArray *arr = [[USER_DEFAULT objectForKey:KEY_TOUCH_DATA] mutableCopy];
            for (int i = 0; i<arr.count; i++) {
                NSDictionary *dict = [arr objectAtIndex:i];
                if ([[NSString stringWithFormat:@"%@",[dict objectForKey:KEY_SiteUser]] isEqualToString:[NSString stringWithFormat:@"%@",[siteData objectForKey:KEY_SiteUser]]])
                {
                    NSMutableArray *arrTemp = [arr mutableCopy];
                    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
                    [dict1 setValue:[siteData valueForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                    [dict1 setValue:[siteData valueForKey:KEY_PASSWORD] forKey:KEY_PASSWORD];
                    
                    if (isTouch){
                        [dict1 setValue:@"1" forKey:kTouchID];
                    }
                    else{
                        [dict1 setValue:@"0" forKey:kTouchID];
                    }
                    [arrTemp replaceObjectAtIndex:i withObject:dict1];
                    [USER_DEFAULT setObject:arrTemp forKey:KEY_TOUCH_DATA];
                    [USER_DEFAULT synchronize];
                    break;
                }
            }
        }
        else{
            [Common showAlert:@"Error" :@"Please enter valid password"];
            if(isTouch){
                [_swichTouchID setOn:YES];
            }
            else{
                [_swichTouchID setOn:NO];
            }
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(isTouch){
            [_swichTouchID setOn:YES];
        }
        else{
            [_swichTouchID setOn:NO];
        }
    }]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @" Enter Password";
        textField.secureTextEntry = YES;
        [textField setBorderStyle:UITextBorderStyleNone];
    }];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)ChangedOnOff:(id)sender {
    if(isTouch){
        [_swichTouchID setOn:NO];
        isTouch = NO;
        [FTIndicator showSuccessWithMessage:@"TouchID/FaceID Disabled"];
        [USER_DEFAULT setBool:NO forKey:kTouchID];
    }
    else{
        [_swichTouchID setOn:YES];
        isTouch = YES;
        [FTIndicator showSuccessWithMessage:@"TouchID/FaceID enabled"];
        [USER_DEFAULT setBool:YES forKey:kTouchID];
    }
    [USER_DEFAULT synchronize];
//    onOffSwitch.on = isTouch;
}

- (IBAction)onPrintPaperSetting:(id)sender
{
    
    BRPrintSettingsTableViewController *nextViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"BRPrintSettingsTableViewController"];
    [self.navigationController pushViewController:nextViewController animated:YES];
    
    
}
- (IBAction)onPrint:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    //[self prepareForPtp];
    BRLMChannel	*_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=[[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"istest", nil] mutableCopy];
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];;
    if (_ptp)
    {
        
//        if ([_ptp isPrinterReady]){
            printResultViewController.visitorDetails=[[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"istest", nil] mutableCopy];
            [printResultViewController.visitorDetails setObject:@"1" forKey:kPrinterStatus];
//        }
//        else
//        {
//             [printResultViewController.visitorDetails setObject:@"Printer is not ready!" forKey:kPrinterStatus];
//        }
        [self.navigationController pushViewController:printResultViewController animated:YES];
    }
    else
    {
         [printResultViewController.visitorDetails setObject:@"Please set printer properly!" forKey:kPrinterStatus];
    }
}

-(void)checkAndSaveCameraSettings
{
    NSMutableArray *arrSettings = [[USER_DEFAULT objectForKey:CAMERA_SETTINGS] mutableCopy];
    if (arrSettings == nil)
    {
        arrSettings = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *configDic = [Common SiteData];
    if (arrSettings.count > 0)
    {
        for (int i = 0 ; i < arrSettings.count ; i++)
        {
            NSMutableDictionary *dicSettings = [[arrSettings objectAtIndex:i] mutableCopy];
            if ([[NSString stringWithFormat:@"%@",[dicSettings objectForKey:KEY_SiteUser]] isEqualToString:[NSString stringWithFormat:@"%@",[configDic objectForKey:KEY_SiteUser]]])
            {
                [dicSettings setObject:[dicSettings objectForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                [dicSettings setObject:[USER_DEFAULT objectForKey:KEY_CAMERA] forKey:KEY_CAMERA];
                [dicSettings setObject:[USER_DEFAULT objectForKey:KEY_QRCodeCam] forKey:KEY_QRCodeCam];
                [arrSettings replaceObjectAtIndex:i withObject:dicSettings];
                [USER_DEFAULT setObject:arrSettings forKey:CAMERA_SETTINGS];
                break;
            }
        }
    }
}



@end
