//
//  ContractorSignInSpotCheckVC.m
//  LinkSafe
//
//  Created by Maulikkumar Desai on 25/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorSignInSpotCheckVC.h"
#import "UIButton+Additions.h"
#import "AsyncImageView.h"
#import "UITextField+Additions.h"
#import "AppDelegate.h"
#import "VerifyContractorVC.h"
#import "ScannerViewController.h"
#import "ContractorPermissions.h"
#import "TakePhotoVC.h"
#import "Aceess.h"
#import "ContractorJobSelectionVC.h"
#import "ContractorLocationSelectionVC.h"
#import "ContractorWhomToMeetingVC.h"
#import "SCValidateContractorVC.h"
#import "SCSearchResultVC.h"
#import "ContractorCustomQuestionVC.h"
#import "SiteApproverScreenVC.h"

@interface ContractorSignInSpotCheckVC () <UITableViewDelegate, UITableViewDataSource>
{
    //    NSDictionary *responceCopyObj;
    BOOL isWorkLocationScreen;
    BOOL isPermission;
    BOOL isPhoto;
    BOOL isSign;
    BOOL isOrderSelection;
    NSMutableArray *arrCompanies;
    NSString *contractorPin;
    NSMutableArray *arrSiteNames, *arrSpotChecks, *arrSelectedSpot;
    NSMutableDictionary *dictSelectedSpotCheck;
    NSUserDefaults *userSpotCitySelected;
    NSString *strSelectedSiteID;
}

@property (nonatomic, retain) SiteConfig *config;
@end

@implementation ContractorSignInSpotCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor SignIn SpotCheck" parameters:@{@"onload": @"22"}];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBarTintColor:kGetThemeColor];
    [[UINavigationBar appearance] setBarTintColor:kGetThemeColor];
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _viewCompanies.hidden = YES;
    _tblCompanies.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblCompanies.delegate = self;
    _tblCompanies.dataSource = self;
    
    [_btnCancel applyGrayTheme];
    [_btnValidate applyBlueShedow];
    [_btnScanQRCode applyBlueShedow];
//    [_tfEnterPIN applyFlatTheme];
    //_tfEnterPIN.text=@"10379502";
    _btnScanQRCode.clipsToBounds=YES;
    _btnScanQRCode.layer.cornerRadius=3.0f;
//    ((AsyncImageView *)[self.view viewWithTag:3301]).imageURL=[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_LOGO]];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    [_viewCompanies viewWithTag:5503].clipsToBounds=YES;
    [_viewCompanies viewWithTag:5503].layer.cornerRadius=3.0f;
    
    _ViewSiteSelection.layer.cornerRadius = 5.0f;
    _ViewSiteSelection.layer.borderWidth = 1.0f;
    _ViewSiteSelection.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    
    _lblOrSearch.clipsToBounds=YES;
    _lblOrSearch.layer.cornerRadius=3.0f;
    
    _lblOr.clipsToBounds=YES;
    _lblOr.layer.cornerRadius=3.0f;
    
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
    
    arrSiteNames = [[NSMutableArray alloc]init];

    dictSelectedSpotCheck = [[NSMutableDictionary alloc]init];
    arrSelectedSpot = [[NSMutableArray alloc]init];
    userSpotCitySelected = [NSUserDefaults standardUserDefaults];
    
    _lblSiteName.text = @"";
    strSelectedSiteID = @"1";
    
    [_tfEnterPIN applyGrayBorderTheme];
    [_tfFirstName applyGrayBorderTheme];
    [_tfLastName applyGrayBorderTheme];
    if (![Common appDelegate].isIpad)
    {
        self.uiContainView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height) < 700 ? 700 : self.view.frame.size.height);
        self.tpScroll.contentSize = CGSizeMake(self.view.frame.size.width,self.uiContainView.frame.size.height);
    }
    
    [self.view bringSubviewToFront:_viewCompanies];
}

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.navTitle;
    self.navigationItem.title = @"LinkSafe Site";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadAllSites)
                                                 name:@"loadAllSites"
                                               object:nil];
    
    
//    [self loadAllSites];
    
    [self upadteTime];
    
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (![Common appDelegate].isIpad) {
        self.uiContainView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height) < 668 ? 668 : self.view.frame.size.height);
        self.tpScroll.contentSize = CGSizeMake(self.view.frame.size.width,self.uiContainView.frame.size.height);
    }
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [_tfEnterPIN applyGrayBorderTheme];
    [_tfFirstName applyGrayBorderTheme];
    [_tfLastName applyGrayBorderTheme];
}

-(void)loadAllSites
{
    arrSpotChecks = [[Common SiteData] objectForKey:KEY_SPOT_CHECK_SITES];
    [arrSiteNames removeAllObjects];
    if ([arrSpotChecks count] == 0 || arrSpotChecks == nil) {
        [Common showAlert:@"Spot check sites not found" :@""];
        return;
    }
    for (int i = 0; i<[arrSpotChecks count]; i ++) {
        NSDictionary *dict = [arrSpotChecks objectAtIndex:i];
        NSString *strSiteName = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
        [arrSiteNames addObject:strSiteName];
    }
    _btnSelectSites.hidden = YES;
    NSDictionary *dic = [arrSpotChecks objectAtIndex:0];
    if(arrSiteNames.count > 1){
        _lblSiteName.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name"]];
        strSelectedSiteID = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
        _btnSelectSites.hidden = NO;
    }
    else if(arrSiteNames.count == 1){
        _lblSiteName.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name"]];
        strSelectedSiteID = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
        _btnSelectSites.hidden = YES;
    }
    
    NSString *strUser = [NSString stringWithFormat:@"%@",[[Common SiteData]valueForKey:KEY_SiteUser]];
    arrSelectedSpot = [[userSpotCitySelected objectForKey:@"userSpotCitySelected"] mutableCopy];
    
    if(arrSelectedSpot.count > 0){
        for (int i = 0; i<arrSelectedSpot.count; i++) {
            NSDictionary *dic = [arrSelectedSpot objectAtIndex:i];
            NSString *str = [NSString stringWithFormat:@"%@",[dic valueForKey:@"user"]];
            if([str isEqualToString:strUser]){
                for (int i = 0; i<[arrSpotChecks count]; i ++) {
                    NSDictionary *spotChecks = [arrSpotChecks objectAtIndex:i];
                    if ([[NSString stringWithFormat:@"%@",[spotChecks valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]]]) {
                        _lblSiteName.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"site"]];
                        strSelectedSiteID = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
                        break;
                    }
                }
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:strSelectedSiteID forKey:@"kSelectedSiteId"];
    [[NSUserDefaults standardUserDefaults] setObject:_lblSiteName.text forKey:@"kSelectedSiteName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadAllSites" object:nil];
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
//            [self findContractorUsingPin:@"" orScanString:[NSString stringWithFormat:@"%@",[updaedVisitorDetails valueForKey:@"QRCode"]]];
            
            [self findContractorUsingQrCodeString:[updaedVisitorDetails valueForKey:@"QRCode"]];
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
        [Common showAlert:[responseObject objectForKey:@"nonComplianceText"] :@""];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    [textField resignFirstResponder];
    
    if ([textField.text length]>0 && (textField == self.tfEnterPIN || textField == self.tfLastName))
    {
        [self onValidate:textField];
    }
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark - Methods
- (IBAction)onValidate:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *txtEnterPIN = [Common removeWhiteSpace:_tfEnterPIN.text];
    NSString *txtFirstName = [Common removeWhiteSpace:_tfFirstName.text];
    NSString *txtLastName = [Common removeWhiteSpace:_tfLastName.text];
    if (![self isValidSubmition]) {
        return;
    }
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setObject:txtFirstName forKey:@"firstName"];
    [dicParameters setObject:txtLastName forKey:@"lastName"];
    [dicParameters setObject:txtEnterPIN forKey:@"pin"];
    [dicParameters setObject:[NSNumber numberWithInteger:[strSelectedSiteID integerValue]] forKey:@"SiteID"];
    
    [Common callAPI:dicParameters Request:kSpotCheckWorkerSearch ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        self.tfEnterPIN.text = @"";
        self.tfFirstName.text = @"";
        self.tfLastName.text = @"";
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue]) {
            
            NSArray *workers = [responseObject objectForKey:@"workers"];
            if (workers.count > 0) {
                if (workers.count == 1) {
                    //Only one user -> Redirect to validate screen
                    SCValidateContractorVC *vc = [SCValidateContractorVC viewController];
                    vc.strSelectedSiteId = strSelectedSiteID;
                    vc.userDetails = [workers objectAtIndex:0];
                    [self.navigationController pushViewController:vc animated:true];
                }
                else {
                    //Multiple users -> Multiple user screen
                    SCSearchResultVC *vc = [SCSearchResultVC viewController];
                    vc.strSelectedSiteId = strSelectedSiteID;
                    vc.arrWorkers = workers;
                    vc.totalWorkers = [[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"totalRecords"]] integerValue];
                    [self.navigationController pushViewController:vc animated:true];
                }
            }
            else {
                [Common showAlert:@"Oops!" : @"No workers found."];
            }
        }
        else {
            
            NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(BOOL)isValidSubmition {
    
    NSString *txtEnterPIN = [Common removeWhiteSpace:_tfEnterPIN.text];
    NSString *txtFirstName = [Common removeWhiteSpace:_tfFirstName.text];
    NSString *txtLastName = [Common removeWhiteSpace:_tfLastName.text];
    
    if (txtEnterPIN.length == 0 && txtFirstName.length == 0 && txtLastName.length == 0) {
        
        [Common showAlert:@"Invalid input" :@"Please enter atleast one filter"];
        return NO;
    }
    else if (txtEnterPIN.length > 0 && (txtFirstName.length > 0 || txtLastName.length > 0)) {
        
        [Common showAlert:@"Invalid input" :@"Please remove unnecesarry filter"];
        return NO;
    }
    else if (txtFirstName.length > 0 || txtLastName.length > 0) {
        
        if (txtEnterPIN.length > 0) {
            [Common showAlert:@"Invalid input" :@"Please remove PIN"];
            return NO;
        }
        else if (txtFirstName.length == 0 && txtLastName.length > 0) {
            [Common showAlert:@"Invalid input" :@"Please enter first name"];
            return NO;
        }
        else if (txtFirstName.length > 0 && txtLastName.length == 0) {
            [Common showAlert:@"Invalid input" :@"Please enter last name"];
            return NO;
        }
        else {
            return YES;
        }
    }
    else if (txtEnterPIN.length > 0) {
        
        if (txtEnterPIN.length == 8) {
            return YES;
        }
        else {
            [Common showAlert:@"Oops!" :@"Please enter valid PIN"];
            return NO;
        }
    }
    else {
        return NO;
    }
}

-(void)findContractorUsingQrCodeString:(NSString *)decodedString
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:decodedString forKey:@"decodedString"];
    [Common callAPI:dicParameters Request:kGetPinFromQrCodeForSpotCheck ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue]) {
            
            if ([responseObject valueForKey:KEY_PIN]) {
                NSString *pin = [responseObject objectForKey:KEY_PIN];
                self.tfEnterPIN.text = pin;
                self.tfFirstName.text = @"";
                self.tfLastName.text = @"";
                
                [self onValidate:self.btnValidate];
            }
        }
        else {
            
            [Common showAlert:@"Error" :[responseObject objectForKey:@"errorMessage"]];
        }
    }];
}

-(void)findContractorUsingPin:(NSString *)PIN orScanString:(NSString *)decodedString
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    if (PIN.length == 0)
    {
        [dicParameters setObject:@"" forKey:KEY_PIN];
        [dicParameters setObject:decodedString forKey:@"decodedString"];
    }
    else
    {
        [dicParameters setObject:PIN forKey:KEY_PIN];
        [dicParameters setObject:@"" forKey:@"decodedString"];
    }
    
    [Common callAPI:dicParameters Request:API_FIND_CONTRACTOR ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
         if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
         {
             self->contractorPin = [[responseObject objectForKey:@"contractor"] objectForKey:@"pin"];
             self->arrCompanies = [[NSMutableArray alloc] init];
             self->arrCompanies = [[responseObject objectForKey:@"contractor"] objectForKey:@"companies"];
             
             if (self->arrCompanies.count == 1)
             {
                [self signInContractorUsingPinSpot:self->contractorPin andCompanyId:[[self->arrCompanies objectAtIndex:0] objectForKey:@"id"]];
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

-(void)signInContractorUsingPinSpot:(NSString *)txtEnterPIN andCompanyId:(NSString *)companyId
{
    
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_PIN:txtEnterPIN,@"companyID": companyId,@"SiteID":strSelectedSiteID}];
    [Common callAPI:dicParameters Request:API_VALIDATE_SPOT_CHECK ShowProgress:YES WithCompletionHandler:^(id responseObject)
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
                     aceess.isSpotUser = YES;
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
    BRLMChannel    *_ptp = [Common prepareForPtp];
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
             NSLog(@"RESPONSE : %@",responseData);
             
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
    
    [self signInContractorUsingPinSpot:contractorPin andCompanyId:[dic objectForKey:@"id"]];
    
    
    
    _viewCompanies.hidden = YES;
}

-(IBAction)onCancelSelectCompany:(id)sender
{
    _viewCompanies.hidden = YES;
}

- (IBAction)onSiteSelectClicked:(id)sender {
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Site" rows:arrSiteNames initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         self.lblSiteName.text = selectedValue;
         NSDictionary *dict = [arrSpotChecks objectAtIndex:selectedIndex];
         strSelectedSiteID = [NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:strSelectedSiteID forKey:@"kSelectedSiteId"];
        [[NSUserDefaults standardUserDefaults] setObject:_lblSiteName.text forKey:@"kSelectedSiteName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
         NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
         
         NSString *strUser = [NSString stringWithFormat:@"%@",[[Common SiteData]valueForKey:KEY_SiteUser]];
         
         [dict1 setValue:strSelectedSiteID forKey:@"id"];
         [dict1 setValue:strUser forKey:@"user"];
         [dict1 setValue:self.lblSiteName.text forKey:@"site"];
         
         if(arrSelectedSpot.count > 0){
             for (int i = 0; i<arrSelectedSpot.count; i++) {
                 NSDictionary *dic = [arrSelectedSpot objectAtIndex:i];
                 NSString *str = [NSString stringWithFormat:@"%@",[dic valueForKey:@"user"]];
                 if([str isEqualToString:strUser]){
                     NSMutableArray *arr = [arrSelectedSpot mutableCopy];
                     [arr replaceObjectAtIndex:i withObject:dict1];
                     [userSpotCitySelected setObject:arr forKey:@"userSpotCitySelected"];
                 }
                 else{
                     [arrSelectedSpot addObject:dict1];
                     [userSpotCitySelected setObject:arrSelectedSpot forKey:@"userSpotCitySelected"];
                 }
             }
         }
         else if(arrSelectedSpot.count == 0){
             arrSelectedSpot = [[NSMutableArray alloc]init];
             [arrSelectedSpot addObject:dict1];
             [userSpotCitySelected setObject:arrSelectedSpot forKey:@"userSpotCitySelected"];
         }
         
         
         
         [userSpotCitySelected synchronize];
         
     }cancelBlock:^(ActionSheetStringPicker *picker)
     {
         NSLog(@"Block Picker Canceled");
     }origin:sender];
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
