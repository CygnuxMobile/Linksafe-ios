//
//  VerifyContractorVC.m
//  LinkSafe
//
//  Created by uday on 05/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "VerifyContractorVC.h"
#import "UIButton+Additions.h"
#import "HomeVC.h"
#import "AsyncImageView.h"
#import "ContractorSignInVC.h"
#import "UITextField+Additions.h"
#import "TakePhotoVC.h"
#import "ContractorPermissions.h"
#import "ContractorJobSelectionVC.h"
#import "ContractorLocationSelectionVC.h"
#import "ContractorWhomToMeetingVC.h"
#import "ContractorCustomQuestionVC.h"
#import "SiteApproverScreenVC.h"

@interface VerifyContractorVC ()
{
    BOOL isWorkLocationScreen;
    BOOL isPermission;
    BOOL isPhoto;
    BOOL isSign;
    BOOL isOrderSelection;
}

@property (nonatomic, retain) SiteConfig *config;

@end

@implementation VerifyContractorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Verify Contractor" parameters:@{@"onload": @"25"}];
    [_btnSignInAsException applyBlueShedow];
    [_btnDeclineEntry applyBlueShedow];
    [_btnHome applyGrayTheme];
    self.uiContainView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];    
    [Common ApplyUIViewBoeder:[self.view viewWithTag:5501]];
    [Common ApplyUIViewBoeder:[self.view viewWithTag:5502]];
    
    self.lblHeader.textColor = kGetHomeLabelColor;
    self.lblReasons.textColor = kGetHomeLabelColor;
    
    self.config = [Common appDelegate].config;
    isOrderSelection = NO;
    isWorkLocationScreen = self.config.isWorkLocationScreenVisible;;
    isPermission = self.config.isWorkPermitsEnabled;
    isPhoto = self.config.isPhotoRequiredSignInContractor;
    isSign = self.config.isSignatureRequiredContractor;
    
    ((AsyncImageView *)[self.view viewWithTag:3301]).imageURL=[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_LOGO]];

    _lblName.text = [NSString stringWithFormat:@"%@ %@",[_dicInfo valueForKey:@"firstName"],[_dicInfo valueForKey:@"lastName"]];
    _lblPin.text = [NSString stringWithFormat:@"%@",[_dicInfo valueForKey:KEY_PIN]];
    _lblCompany.text = [_dicInfo valueForKey:@"companyName"];
    
    if([[_dicInfo valueForKey:@"failedRules"] isKindOfClass:[NSArray class]] || [[_dicInfo valueForKey:@"failedRules"] isKindOfClass:[NSMutableArray class]])
    {
        arrItems = [[NSMutableArray alloc] initWithArray:[_dicInfo valueForKey:@"failedRules"]];    //here's the issue. the object is string instead of array
    }
    else
    {
        arrItems = [[NSMutableArray alloc] init];    //here's the issue. the object is string instead of array
    }
    
    int needHight=900;
    if(![Common appDelegate].isIpad)
    {
        needHight=800;
    }
    _btnDeclineEntry.hidden=NO;
    _btnSignInAsException.hidden=NO;
    
    [_tfAuthorizedBy applyGrayBorderTheme];
    [_tfNotes applyGrayBorderTheme];
    
    _tfAuthorizedBy.hidden=NO;
    _tfNotes.hidden=NO;
    
    if(!self.config.isDeclineEntryEnabled)
    {
        if(![Common appDelegate].isIpad)
        {
            needHight=needHight-40;
        }
        else
        {
            CGRect btnException=_btnSignInAsException.frame;
            btnException.origin.x=(self.view.frame.size.width-btnException.size.width)/2;
            _btnSignInAsException.frame=btnException;
            
        }
        _btnDeclineEntry.hidden=YES;
    }
    else
    {
        if(!self.config.isSignInByExceptionEnabled)
        {
                _tfAuthorizedBy.hidden=YES;
                _tfNotes.hidden=YES;
        }
    }
    
    if(!self.config.isSignInByExceptionEnabled)
    {
        if(![Common appDelegate].isIpad)
        {
            needHight=needHight-40;
        }
        else
        {
            CGRect btnException=_btnDeclineEntry.frame;
            btnException.origin.x=(self.view.frame.size.width-btnException.size.width)/2;
            _btnDeclineEntry.frame=btnException;
        }
        
        _btnSignInAsException.hidden=YES;
    }
    
    if (_tfAuthorizedBy.hidden)
    {
        if([Common appDelegate].isIpad)
        {
            needHight=needHight-90;
        }
        else
        {
            needHight=needHight-110;
        }
    }
    
    self.uiContainView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height>needHight?self.view.frame.size.height:needHight);
    self.tpScroll.contentSize = CGSizeMake(self.view.frame.size.width,self.uiContainView.frame.size.height);
    [_tblItems reloadData];
    _tblItems.tableFooterView = [[UIView alloc] init];
    _lblRedTitle.text = self.config.nonComplianceText;
    [_tfAuthorizedBy applyFlatTheme];
    [_tfNotes applyFlatTheme];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title=self.navTitle;
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

-(void)upadteTime
{
    [Common updateTime:self.view];
}

#pragma mark - UITextField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)onDeclineEntry:(id)sender {
    [self.view endEditing:YES];
    NSMutableDictionary *dxParameters = [[NSMutableDictionary alloc] init];
    dxParameters[KEY_PIN] = [USER_DEFAULT objectForKey:KEY_CONTRACTOR_PIN];
    [dxParameters setObject:[_dicInfo objectForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
    
    [Common callAPI:dxParameters Request:REQUEST_CANCEL_DECLINE_ENTRY ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
         if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
         {
             [USER_DEFAULT removeObjectForKey:KEY_CONTRACTOR_PIN];
             [USER_DEFAULT synchronize];
             [self.navigationController popToRootViewControllerAnimated:YES];
         }
         else
         {
             [Common showAlert:@"Error" :[responseObject valueForKey:KEY_ERROR_MESSAGE]];
         }
    }];
}

- (IBAction)onSignInAsException:(id)sender {
    
    NSString *strAuthorizedBy = [Common removeWhiteSpace:_tfAuthorizedBy.text];
    NSString *strNotes = [Common removeWhiteSpace:_tfNotes.text];
    
    if (strAuthorizedBy.length !=0 && strNotes.length !=0)
    {
        [_dicInfo setObject:strAuthorizedBy forKey:KEY_AuthorizedBy];
        [_dicInfo setObject:strNotes forKey:KEY_Notes];
        [self checkForContactSelectionScreen:_dicInfo];
    }
    else
    {
        if (strAuthorizedBy.length ==0)
        {
            [Common showAlert:@"Missing" :@"Please enter authorized by."];
        }
        else
        {
            [Common showAlert:@"Missing" :@"Please enter reasons."];
        }
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
            [dicPic addEntriesFromDictionary:dicPermission];
            [self performSelector:@selector(signInAsException:) withObject:dicPic afterDelay:0.5f];
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
//        if (isWorkLocationScreen || isPermission || isPhoto || isSign)
//        {
//            [self signInAsException:dicPermission];
//        }
//        else
//        {
            if ([NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_SignInAcceptanceMessage]].length > 0)
            {
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_SignInAcceptanceMessage]] preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self signInAsException:dicPermission];
                }];
                [controller addAction:alertAction];

                UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                [controller addAction:alertActionCancel];

                [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
                }];
            }
            else
            {
                [self signInAsException:dicPermission];
            }
//        }
    }
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
    else {
        [self checkForContractorJobSelectionScreen:responseContractorObject];
    }
}

-(void)checkForContractorJobSelectionScreen:(NSDictionary *)responseObject
{
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    if ([responseObject valueForKey:KEY_PIN])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[responseObject valueForKey:KEY_PIN]] forKey:KEY_PIN];
    }
    else
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[USER_DEFAULT valueForKey:KEY_CONTRACTOR_PIN]] forKey:KEY_PIN];
    }
    [dicParameters setObject:[responseObject objectForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
    
    [Common callAPI:dicParameters Request:REQUEST_GET_CONTRACTOR_JOBS ShowProgress:YES WithCompletionHandler:^(id workOrderResponseData)
     {
         if ([[NSString stringWithFormat:@"%@",[workOrderResponseData objectForKey:KEY_SUCCESS]] boolValue])
         {
             
             NSMutableDictionary *workOrderResponseObject = [workOrderResponseData mutableCopy];
             if (![[workOrderResponseData valueForKey:KEY_WORK_ORDERS] isKindOfClass:[NSArray class]]
                 && ![[workOrderResponseData valueForKey:KEY_WORK_ORDERS] isKindOfClass:[NSMutableArray class]])
             {
                 [workOrderResponseObject setObject:[[NSArray alloc] init] forKey:KEY_WORK_ORDERS];
             }
             
             self->isOrderSelection = [[NSString stringWithFormat:@"%@",[workOrderResponseObject objectForKey:@"isWorkOrdersScreenVisible"]] boolValue];
             
             if (self->isOrderSelection)
             {
                 [self gotoContractorJobSelectionScreen:responseObject withData:workOrderResponseObject];
             }
             else
             {
                 if(!isWorkLocationScreen && !self.config.customQuestionScreen.contractor.isEnabled && !isPermission && !isPhoto && !isSign)
                 {
                     if ([NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_SignInAcceptanceMessage]].length > 0)
                     {
                         UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_SignInAcceptanceMessage]] preferredStyle:UIAlertControllerStyleAlert];

                         UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                             [self signInAsException:responseObject];//hgs
                         }];
                         [controller addAction:alertAction];

                         UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                             [self.navigationController popToRootViewControllerAnimated:YES];
                         }];
                         [controller addAction:alertActionCancel];

                         [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
                         }];
                     }
                     else
                     {
                         [self signInAsException:responseObject];//hgs
                     }
                 }
                 else
                 {
                     if (isWorkLocationScreen)
                     {
                         [self gotoContractorLocationSelectionScreen:responseObject];
                     }
                     else
                     {
                         [self gotoContractorPermission:responseObject];
                     }
                 }
             }
         }
         else
         {
             NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:errorMsg
                                                            delegate:self
                                                   cancelButtonTitle:@"BACK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
     }];
}

-(void)gotoContractorJobSelectionScreen:(NSDictionary *)responseObject withData:(NSDictionary *)data
{
    ContractorJobSelectionVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorJobSelectionVC"];
    next.responseDictionary = [data mutableCopy];
    next.ContractorDetail = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
    next.navTitle = self.navTitle;
    next.didFinishWithJobSelection = ^(NSMutableDictionary *dicPic)
    {
        if (self->isWorkLocationScreen)
        {
            [self gotoContractorLocationSelectionScreen:dicPic];
        }
        else
        {
            [self gotoContractorPermission:dicPic];
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

- (void)signInAsException:(NSDictionary *)picDataDic
{
    [self.view endEditing:YES];
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setObject:[_dicInfo valueForKey:KEY_PIN] forKey:KEY_PIN];
    [dicParameters setObject:_tfNotes.text forKey:KEY_Notes];
    [dicParameters setObject:_tfAuthorizedBy.text forKey:KEY_AuthorizedBy];
    if ([picDataDic valueForKey:KEY_WORK_OrderID])
    {
        [dicParameters setValue:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[picDataDic valueForKey:KEY_WORK_OrderID]] intValue]] forKey:KEY_WORK_OrderID];
    }
    if ([picDataDic valueForKey:@"photoUri"])
    {
        [dicParameters setObject:[picDataDic valueForKey:@"photoUri"] forKey:@"photoUri"];
    }
    if ([picDataDic valueForKey:@"guestSignatureUri"])
    {
        [dicParameters setObject:[picDataDic valueForKey:@"guestSignatureUri"] forKey:@"guestSignatureUri"];
    }
    if (isPermission)
    {
        [dicParameters setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[picDataDic valueForKey:KEY_WORKPERMIT_FORM_ID]] intValue]] forKey:KEY_WORKPERMIT_FORM_ID];
    }
    if ([picDataDic valueForKey:KEY_WORK_Location])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[picDataDic valueForKey:KEY_WORK_Location]] forKey:KEY_WORK_Location];
    }
    
    [dicParameters setObject:[_dicInfo valueForKey:KEY_WORKPERMIT_FORM_ID] ? [NSString stringWithFormat:@"%@",[_dicInfo valueForKey:KEY_WORKPERMIT_FORM_ID]] : @"" forKey:KEY_WORKPERMIT_FORM_ID];
    
    if ([picDataDic valueForKey:KEY_SignInHandle])
    {
        [dicParameters setObject:[picDataDic valueForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
    }
    
    if ([picDataDic valueForKey:KEY_CONTACT_ID])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[picDataDic valueForKey:KEY_CONTACT_ID]] forKey:KEY_CONTACT_ID];
    }

    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_WORK_ENABLED]];
    
    if([strIsSpotCheckUser isEqualToString:@"true"]){
        NSDictionary *dict = [[NSDictionary alloc]init];
        NSUserDefaults *userContractorWork = [NSUserDefaults standardUserDefaults];
        dict = [userContractorWork valueForKey:@"userContractorWork"];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        arr = [dict objectForKey:@"workTypeID"];
        NSString *str = [dict valueForKey:@"workTypeOther"];
        
        [dicParameters setObject:str forKey:@"workTypeOther"];
        [dicParameters setObject:arr forKey:@"workTypeID"];
    }
    [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    
    if ([picDataDic valueForKey:KEY_CUSTOM_QUE_ANS])
    {
        [dicParameters setObject:[picDataDic valueForKey:KEY_CUSTOM_QUE_ANS] forKey:KEY_CUSTOM_QUE_ANS];
    }
    
    if ([picDataDic valueForKey:KEY_CUSTOM_QUE_TEXT])
    {
        [dicParameters setObject:[picDataDic valueForKey:KEY_CUSTOM_QUE_TEXT] forKey:KEY_CUSTOM_QUE_TEXT];
    }
    dicParameters = [Common TurnNumberOrNull:dicParameters];
    [Common callAPI:dicParameters Request:REQUEST_SignInException ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            [self onPrint:[responseObject mutableCopy]];
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

- (void)onPrint:(NSMutableDictionary *)responceDic
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

- (IBAction)onHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];

}

#pragma mark - UITableView Datasource and Delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrItems.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";

    UITableViewCell *cell = [_tblItems dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *lbl1 = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *lbl2 = (UILabel *)[cell.contentView viewWithTag:2];

//    lbl1.frame=CGRectMake(0, 0, cell.contentView.frame.size.width-20, 40);
//    lbl2.frame=CGRectMake(cell.contentView.frame.size.width/3, 0, cell.contentView.frame.size.width*0.2, 40);
    lbl2.layer.cornerRadius = 4.0f;
    lbl1.numberOfLines = 2;
    lbl1.lineBreakMode = NSLineBreakByWordWrapping;
    lbl1.text = arrItems[indexPath.row];
    
    return cell;
}


@end
