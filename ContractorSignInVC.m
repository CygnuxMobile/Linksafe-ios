//
//  ContractorSignInVC.m
//  LinkSafe
//
//  Created by uday on 05/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorSignInVC.h"
#import "UIButton+Additions.h"
#import "AsyncImageView.h"
#import "UITextField+Additions.h"
#import "VerifyContractorVC.h"
#import "ScannerViewController.h"
#import "ContractorPermissions.h"
#import "TakePhotoVC.h"
#import "Aceess.h"
#import "ContractorJobSelectionVC.h"
#import "ContractorLocationSelectionVC.h"
#import "ContractorWhomToMeetingVC.h"
#import "ContractorCustomQuestionVC.h"
#import "SiteApproverScreenVC.h"
#import "EMCCountryPickerController.h"
#import "UIImage+UIImage_EMCImageResize.h"
#import "EMCCountryManager.h"

@interface ContractorSignInVC () <UITableViewDelegate, UITableViewDataSource, EMCCountryDelegate>
{
//    NSDictionary *responceCopyObj;
    BOOL isWorkLocationScreen;
    BOOL isPermission;
    BOOL isPhoto;
    BOOL isSign;
    BOOL isOrderSelection;
    NSMutableArray *arrCompanies;
    NSString *contractorPin;
    EMCCountryPickerController *countryPicker;
    NSDictionary *countryCodeDictionary;
}

@property (nonatomic, retain) SiteConfig *config;
@end

@implementation ContractorSignInVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor SignIn" parameters:@{@"onload": @"21"}];
    _lblHeader.textColor = kGetHomeLabelColor;
    _viewCompanies.hidden = YES;
    _tblCompanies.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblCompanies.delegate = self;
    _tblCompanies.dataSource = self;
    
    [_btnCancel applyGrayTheme];
    [_btnValidate applyBlueShedow];
    [_btnScanQRCode applyBlueShedow];
    [_tfEnterPIN applyFlatTheme];
    [_tfPhoneNo applyFlatTheme];
    [_tfEnterTemperature applyFlatTheme];
    //_tfEnterPIN.text=@"10379502";
    _btnScanQRCode.clipsToBounds=YES;
    _btnScanQRCode.layer.cornerRadius=3.0f;
//    ((AsyncImageView *)[self.view viewWithTag:3301]).imageURL=[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_LOGO]];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
   
    [_viewCompanies viewWithTag:5503].clipsToBounds=YES;
    [_viewCompanies viewWithTag:5503].layer.cornerRadius=3.0f;

    _orLable.clipsToBounds=YES;
    _orLable.layer.cornerRadius=3.0f;
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:55501]];
    [[self.view viewWithTag:55501].layer setBorderWidth:1];
    [[self.view viewWithTag:55501].layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    self.config = [Common appDelegate].config;
    isOrderSelection = NO;
    isWorkLocationScreen = self.config.isWorkLocationScreenVisible;
    isPermission = self.config.isWorkPermitsEnabled;
    isPhoto = self.config.isPhotoRequiredSignInContractor;
    isSign = self.config.isSignatureRequiredContractor;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
    countryCodeDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countrycode" ofType:@"plist"]];
    
    if (![Common appDelegate].isIpad)
    {
        [_tfEnterPIN applyGrayBorderTheme];
        [_tfEnterTemperature applyGrayBorderTheme];
        self.tfEnterTemperature.hidden = !self.config.skinTemperature.isTemperatureMandatoryContractor;

        _viewPhoneNo.backgroundColor = kThemeGreyValue(249.0);
        _viewPhoneNo.layer.cornerRadius = 3.0;
//        _vwPhone.textColor=[UIColor blackColor];
        [_viewPhoneNo.layer setBorderWidth:1.0f];
        [_viewPhoneNo.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
        [_viewPhoneNo.layer setMasksToBounds:NO];
        
        [_viewPhoneNo setHidden: ![self.config isMobileLoginEnable]];
        [_viewPhoneOr setHidden: ![self.config isMobileLoginEnable]];
        [_tfPhoneNo setHidden: ![self.config isMobileLoginEnable]];
    }
    else{
        [_tfEnterPIN applyFlatTheme];
        [_tfEnterTemperature applyFlatTheme];
//        self.viewTemperature.hidden = !self.config.skinTemperature.isTemperatureMandatoryContractor;
//        self.viewTemperature.hidden = YES;
        
        [_tfEnterPIN applyGrayBorderTheme];
        [_tfEnterTemperature applyGrayBorderTheme];
        _vwPhoneBG.backgroundColor = kThemeGreyValue(249.0);
        _vwPhoneBG.layer.cornerRadius = 3.0;
//        _vwPhone.textColor=[UIColor blackColor];
        [_vwPhoneBG.layer setBorderWidth:1.0f];
        [_vwPhoneBG.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
        [_vwPhoneBG.layer setMasksToBounds:NO];
        
        [_viewPhoneOr setHidden: ![self.config isMobileLoginEnable]];
        [_viewPhoneNo setHidden: ![self.config isMobileLoginEnable]];
        [_tfPhoneNo setHidden: ![self.config isMobileLoginEnable]];

    }
    [self.btnSelectCountry setTitle:@"" forState:UIControlStateNormal];
    [self setDefaultCountry];
    [self.view bringSubviewToFront:_viewCompanies];
}

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.navTitle;
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)upadteTime
{
    [Common updateTime:self.uiContainView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (IBAction)onScanQRCode:(id)sender
{
    [self.view endEditing:YES];
    ScannerViewController *scannerViewController = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    scannerViewController.navTitle = self.navTitle;
    scannerViewController.didFinishwithQRDetail = ^(NSMutableDictionary *updaedVisitorDetails)
    {
        if ([[updaedVisitorDetails valueForKey:@"QRCode"] length]>0)
        {
            [self findContractorUsingPin:@"" orPhoneNumber:@"" orScanString:[NSString stringWithFormat:@"%@",[updaedVisitorDetails valueForKey:@"QRCode"]]];
        }
        else
        {
            [Common showAlert:@"Please scan valide QRCode" :@""];
        }
    };
    [self.navigationController pushViewController:scannerViewController animated:YES];
}

- (void)gotoVarifyContractor:(NSDictionary *)responseObject
{
    if(!self.config.isDeclineEntryEnabled && !self.config.isSignInByExceptionEnabled)
    {
//        [Common showAlert:[responseObject objectForKey:@"nonComplianceText"] :@""];
        
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:[responseObject objectForKey:@"nonComplianceText"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [controller addAction:alertAction];

        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
        }];
        
    }
    else
    {
        VerifyContractorVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VerifyContractorVC"];
        vc.dicInfo = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
        vc.navTitle = self.navTitle;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*
    if (self.config.skinTemperature.isTemperatureMandatoryContractor) {
        if (textField == _tfEnterPIN) {
            if ([_tfEnterTemperature.text length] > 0) {
                [textField resignFirstResponder];
                [self onValidate:nil];
                return true;
            }
            else {
                [_tfEnterTemperature becomeFirstResponder];
                return true;
            }
        }
    }
    */
    [textField resignFirstResponder];
    if ([textField.text length] > 0)
    {
        [self onValidate:nil];
    }
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == self.tfEnterTemperature) {
        //skin temperature textfield
        if (range.length > 0) {
            return YES;
        }
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:TEMPERATURE_ACCEPTABLE_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if ([string isEqualToString:filtered]) {
            if (textField.text.length > 0) {
                NSArray *array = [textField.text componentsSeparatedByString:@"."];
                if (array.count > 1) {
                    NSString *decimal = array[1];
                    if (decimal.length >= 2) {
                        return NO;
                    }
                }
            }
            return YES;
        }
        return NO;
    }
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - Methods
- (IBAction)onValidate:(id)sender
{
    NSString *txtEnterPIN = [Common removeWhiteSpace:_tfEnterPIN.text];
    NSString *mobile = [Common getPhoneNumber:_tfPhoneNo.text];
    NSString *countryCode = [Common removeWhiteSpace:self.lblCountryCode.text];
    
    [self.view endEditing:YES];
    if (txtEnterPIN.length == 0 && mobile.length == 0) {
        if ([self.config isMobileLoginEnable]) {
            [Common showAlert:@"Oops!" :@"Please enter pin or phone number"];
        }
        else {
            [Common showAlert:@"Oops!" :@"Please enter PIN"];
        }
        return;
    }
    if (txtEnterPIN.length == 0) {
        if (![self.config isMobileLoginEnable]) {
            [Common showAlert:@"Oops!" :@"Please enter PIN"];
            return;
        }
    } else {
        [self findContractorUsingPin:txtEnterPIN orPhoneNumber:@"" orScanString:@""];
        return;
    }
    if ([self.config isMobileLoginEnable]) {
        
        if (mobile.length == 0) {
                [Common showAlert:@"Oops!" :@"Please enter PIN"];
                return;
        }
        else {
            if (countryCode.length == 0) {
                [Common showAlert:@"Oops!" :@"Please select country"];
                return;
            }
        }
    }
    NSString *codewithphone = [countryCode stringByAppendingString:mobile];
    [self findContractorUsingPin:txtEnterPIN orPhoneNumber:codewithphone orScanString:@""];
}

-(void)findContractorUsingPin:(NSString *)PIN orPhoneNumber:(NSString *)phoneNumber orScanString:(NSString *)decodedString
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    if (PIN.length != 0)
    {
        [dicParameters setObject:PIN forKey:KEY_PIN];
        [dicParameters setObject:@"" forKey:KEY_MOBILE];
        [dicParameters setObject:@"" forKey:@"decodedString"];
    }
    else if (phoneNumber.length != 0)
    {
        [dicParameters setObject:@"" forKey:KEY_PIN];
        [dicParameters setObject:phoneNumber forKey:KEY_MOBILE];
        [dicParameters setObject:@"" forKey:@"decodedString"];
    }
    else
    {
        [dicParameters setObject:@"" forKey:KEY_PIN];
        [dicParameters setObject:@"" forKey:KEY_MOBILE];
        [dicParameters setObject:decodedString forKey:@"decodedString"];
    }
    
    [Common callAPI:dicParameters Request:API_FIND_CONTRACTOR ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            self->contractorPin = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"contractor"] objectForKey:@"pin"]];
            self->arrCompanies = [[NSMutableArray alloc] init];
            self->arrCompanies = [[responseObject objectForKey:@"contractor"] objectForKey:@"companies"];
            
            if (self->arrCompanies.count == 1)
            {
                
                [self signInContractorUsingPin:self->contractorPin andCompanyId:[[self->arrCompanies objectAtIndex:0] objectForKey:@"id"]];
                
            }
            else if (self->arrCompanies.count > 1)
            {
                [self->_tblCompanies reloadData];
                self->_viewCompanies.hidden = NO;
            }
            else
            {
                NSLog(@"No companies to show.");
            }
        }
        else
        {
            [Common showAlert:@"Error" :[responseObject objectForKey:@"errorMessage"]];
        }
    }];
}

-(void)signInContractorUsingPin:(NSString *)txtEnterPIN andCompanyId:(NSString *)companyId
{
    if (self.config.skinTemperature.isTemperatureMandatoryContractor) {
//        if (![self validateTemperature:_tfEnterTemperature.text]) {
//            [Common showAlert:@"Oops!" :@"Please enter temperature"];
//            return;
//        }
//        int temperature = [_tfEnterTemperature.text doubleValue];
//        [dicParameters setValue:[[NSNumber alloc] initWithDouble:temperature] forKey:@"skinTemperature"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Skin Temperature" message:@"Please enter skin temperature." preferredStyle:UIAlertControllerStyleAlert];
            
        [alert addAction:[UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *alertTextField = alert.textFields.firstObject;
            NSLog(@"And the text is... %@", alertTextField.text);
            NSString *tempData = [NSString stringWithFormat:@"%@",alertTextField.text];
            
            if (tempData.length == 0) {
                [Common showAlert:@"Oops!" :@"Please enter Skin Temperature"];
                return;
               // [self signInContractorUsingPin:txtEnterPIN andCompanyId:companyId];
            }
            if (![Common validateSkinTemperature: tempData]) {
                [Common showAlert:@"Oops!" :@"Please enter valid Skin Temperature"];
                return;
               // [self signInContractorUsingPin:txtEnterPIN andCompanyId:companyId];
            }
            
            
            
//            if (![self validateTemperature:tempData]) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                    [self signInContractorUsingPin:txtEnterPIN andCompanyId:companyId];
//                });
//                return;
//            }
            
            NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_PIN: txtEnterPIN, @"companyID": companyId}];
            [dicParameters setValue:[[NSNumber alloc] initWithDouble:[tempData intValue]] forKey:@"skinTemperature"];
            
            [Common callAPI:dicParameters Request:API_VALIDATE_CONTRACTOR ShowProgress:YES WithCompletionHandler:^(id responseObject)
            {
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                {
                    if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nonComplianceText"]] rangeOfString:@"isn't in our database"].location == NSNotFound)
                    {
                        [USER_DEFAULT setObject:txtEnterPIN forKey:KEY_CONTRACTOR_PIN];
                        [USER_DEFAULT synchronize];
                        if (self.config.isSiteRegisterEnabled)
                        {
                            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"isCompliant"]] boolValue])
                            {
                                [self checkForContactSelectionScreen:responseObject];
                            }
                            else {
                                [self gotoVarifyContractor:responseObject];
                            }
                        }
                        else
                        {
                            _tfEnterPIN.text = @"";
                            Aceess *aceess = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"Aceess"];
                            aceess.contractorInfo = [responseObject mutableCopy];
                            aceess.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:aceess animated:YES completion:^{
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        }
                    }
                    else
                    {
                        [Common showAlert:@"Enter valid Pin" :[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nonComplianceText"]]];
                    }
                }
                else
                {
                    [Common showAlert:@"Error" :[responseObject objectForKey:@"errorMessage"]];
                }
            }];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @" Enter Skin Temperature";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            [textField setBorderStyle:UITextBorderStyleNone];
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_PIN: txtEnterPIN, @"companyID": companyId}];
    [Common callAPI:dicParameters Request:API_VALIDATE_CONTRACTOR ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nonComplianceText"]] rangeOfString:@"isn't in our database"].location == NSNotFound)
            {
                [USER_DEFAULT setObject:txtEnterPIN forKey:KEY_CONTRACTOR_PIN];
                [USER_DEFAULT synchronize];
                if (self.config.isSiteRegisterEnabled)
                {
                    if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"isCompliant"]] boolValue])
                    {
                        [self checkForContactSelectionScreen:responseObject];
                    }
                    else {
                        [self gotoVarifyContractor:responseObject];
                    }
                }
                else
                {
                    _tfEnterPIN.text = @"";
                    Aceess *aceess = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"Aceess"];
                    aceess.contractorInfo = [responseObject mutableCopy];
                    aceess.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:aceess animated:YES completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }
            else
            {
                [Common showAlert:@"Enter valid Pin" :[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nonComplianceText"]]];
            }
        }
        else
        {
            [Common showAlert:@"Error" :[responseObject objectForKey:@"errorMessage"]];
        }
    }];
    }
}

- (void)gotoContractorPermission:(NSDictionary *)responceData
{
    if(isPermission)
    {
        ContractorPermissions *contractorPermissions = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorPermissions"];
        contractorPermissions.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responceData];
        contractorPermissions.navTitle = self.navTitle;
        contractorPermissions.didFinishwithWorkPermission = ^(NSMutableDictionary *dicPic)
        {
            [dicPic addEntriesFromDictionary:responceData];
            [self takePhotoContractor:dicPic];
        };
        [self.navigationController pushViewController:contractorPermissions animated:YES];
    }
    else
    {
        [self takePhotoContractor:responceData];
    }
}

-(void)takePhotoContractor:(NSDictionary *)dicPermission
{
    if (isPhoto || isSign)
    {
        TakePhotoVC *takePhotoVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
        takePhotoVC.visitorDetails = [[NSMutableDictionary alloc] initWithDictionary:dicPermission];
        takePhotoVC.isForImageData=YES;
        takePhotoVC.navTitle = self.navTitle;
        takePhotoVC.isContractor = YES;
        takePhotoVC.didFinishwithImageData = ^(NSMutableDictionary *dicPic)
        {
            if (dicPermission != nil)
            {
                [dicPic addEntriesFromDictionary:dicPermission];
            }
            [self signInAsContractor:dicPic];
        };
        [self.navigationController pushViewController:takePhotoVC animated:YES];
    }
    else if ([Common appDelegate].config.signInApprovalScreen.contractor.isEnabled)
    {
        SiteApproverScreenVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
        vc.visitorDetails = [[NSMutableDictionary alloc] initWithDictionary:dicPermission];
        vc.navTitle = self.navTitle;
        vc.isContractor = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self signInAsContractor:dicPermission];
    }
}

-(void)signInAsContractor:(NSDictionary *)dicPic
{
    [Common callContractorSignInAPI:[dicPic mutableCopy] ShowProgress:YES WithCompletionHandler:^(id responseObject) {
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

- (void)onPrint:(NSMutableDictionary *)responceDic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel	*_ptp = [Common prepareForPtp];
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

-(void)checkForContactSelectionScreen:(NSDictionary *)responseContractorObject
{
    if (self.config.isContactSelectionEnabledContractor)
    {
        ContractorWhomToMeetingVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorWhomToMeetingVC"];
        next.navTitle = self.navTitle;
        next.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responseContractorObject];
        next.didFinishWithContactSelection = ^(NSMutableDictionary *dicWithContactSelection) {
            
            [self checkForContractorJobSelectionScreen:dicWithContactSelection];
        };
        [self.navigationController pushViewController:next animated:YES];
    }
    else
    {
        [self checkForContractorJobSelectionScreen:responseContractorObject];
    }
}

-(void)checkForContractorJobSelectionScreen:(NSDictionary *)responseContractorObject
{
    if ([[NSString stringWithFormat:@"%@",[responseContractorObject objectForKey:@"isCompliant"]] boolValue])
    {
        NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
        if ([responseContractorObject valueForKey:KEY_PIN])
        {
            [dicParameters setObject:[NSString stringWithFormat:@"%@",[responseContractorObject valueForKey:KEY_PIN]] forKey:KEY_PIN];
        }
        else
        {
            [dicParameters setObject:[NSString stringWithFormat:@"%@",[USER_DEFAULT valueForKey:KEY_CONTRACTOR_PIN]] forKey:KEY_PIN];
        }
        [dicParameters setObject:[responseContractorObject objectForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
        
        [Common callAPI:dicParameters Request:REQUEST_GET_CONTRACTOR_JOBS ShowProgress:YES WithCompletionHandler:^(id responseData)
         {             
             if ([[NSString stringWithFormat:@"%@",[responseData objectForKey:KEY_SUCCESS]] boolValue])
             {
                 NSMutableDictionary *workOrderResponseObject = [responseData mutableCopy];
                 if (![[responseData valueForKey:KEY_WORK_ORDERS] isKindOfClass:[NSArray class]]
                     && ![[responseData valueForKey:KEY_WORK_ORDERS] isKindOfClass:[NSMutableArray class]])
                 {
                     [workOrderResponseObject setObject:[[NSArray alloc] init] forKey:KEY_WORK_ORDERS];
                 }
                 
                 self->isOrderSelection = [[NSString stringWithFormat:@"%@",[workOrderResponseObject objectForKey:KEY_IsWorkOrdersScreenVisible]] boolValue];
                 
                 if (self->isOrderSelection)
                 {
                     [self gotoContractorJobSelectionScreen:responseContractorObject withData:workOrderResponseObject];
                 }
                 else
                 {
                     if(!self->isWorkLocationScreen && !self.config.customQuestionScreen.contractor.isEnabled && !self->isPermission && !self->isPhoto && !self->isSign)
                     {
                         [self signInAsContractor:responseContractorObject];
                     }
                     else
                     {
                         if (self->isWorkLocationScreen)
                         {
                             [self gotoContractorLocationSelectionScreen:responseContractorObject];
                         }
                         else if (self.config.customQuestionScreen.contractor.isEnabled)
                         {
                             [self gotoContractorCustomQuestionScreen:responseContractorObject];
                         }
                         else
                         {
                             [self gotoContractorPermission:responseContractorObject];
                         }
                     }
                 }
             }
             else
             {
                 NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseContractorObject objectForKey:KEY_ERROR_MESSAGE]];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:errorMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"BACK"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    else
    {
        [self gotoVarifyContractor:responseContractorObject];
    }
}

-(void)gotoContractorJobSelectionScreen:(NSDictionary *)responseObject withData:(NSDictionary *)data
{
    ContractorJobSelectionVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorJobSelectionVC"];
    next.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
    next.responseDictionary = [data mutableCopy];
    next.navTitle = self.navTitle;
    next.didFinishWithJobSelection = ^(NSMutableDictionary *dicPic)
    {
        if ([[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"isCompliant"]] boolValue])
        {
            if (self->isWorkLocationScreen)
            {
                [self gotoContractorLocationSelectionScreen:dicPic];
            }
            else if (self.config.customQuestionScreen.contractor.isEnabled)
            {
                [self gotoContractorCustomQuestionScreen:dicPic];
            }
            else
            {
                [self gotoContractorPermission:dicPic];
            }
        }
        else
        {
            [self gotoVarifyContractor:responseObject];
        }
    };
    [self.navigationController pushViewController:next animated:YES];
}

-(void)gotoContractorLocationSelectionScreen:(NSDictionary *)responseObject
{
    ContractorLocationSelectionVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorLocationSelectionVC"];
    next.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
    next.navTitle = self.navTitle;
    next.didFinishWithJobLocation = ^(NSMutableDictionary *dicPic)
    {
        if (self.config.customQuestionScreen.contractor.isEnabled) {
            [self gotoContractorCustomQuestionScreen:dicPic];
        }
        else {
            [self gotoContractorPermission:dicPic];
        }
    };
    [self.navigationController pushViewController:next animated:YES];
}

-(void)gotoContractorCustomQuestionScreen:(NSDictionary *)responseObject
{
    ContractorCustomQuestionVC *next = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"ContractorCustomQuestionVC"];
    next.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
    next.navTitle = self.navTitle;
    next.didFinishWithCustomQuestion = ^(NSMutableDictionary *dicPic)
    {
        [self gotoContractorPermission:dicPic];
    };
    [self.navigationController pushViewController:next animated:YES];
}

#pragma mark - UITableView Datasource and Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCompanies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSDictionary *dic = [arrCompanies objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"displayText"]];
    
    if ([Common appDelegate].isIpad)
    {
        cell.textLabel.font = kThemeRegularFonts(22);
    }
    else
    {
        cell.textLabel.font = kThemeRegularFonts(15);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [arrCompanies objectAtIndex:indexPath.row];
    
    
    [self signInContractorUsingPin:contractorPin andCompanyId:[dic objectForKey:@"id"]];
    
    
    
    _viewCompanies.hidden = YES;
}

-(IBAction)onCancelSelectCompany:(id)sender
{
    _viewCompanies.hidden = YES;
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
    if (self.config.country != NULL) {
        NSString *countryCode = self.config.country;
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

