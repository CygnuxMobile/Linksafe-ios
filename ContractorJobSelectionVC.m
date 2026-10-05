//
//  ContractorJobSelectionVC.m
//  LinkSafe
//
//  Created by kartik on 7/19/17.
//  Copyright © 2017 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorJobSelectionVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"

@interface ContractorJobSelectionVC ()

@end

@implementation ContractorJobSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Job Selection" parameters:@{@"onload": @"29"}];
    // Do any additional setup after loading the view.
    
    _lblHeader.textColor = kGetHomeLabelColor;
    _siteArray = [_responseDictionary valueForKey:KEY_WORK_ORDERS];
    
    [_btnNext applyBlueShedow];

    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    
    [[self.view viewWithTag:5501].layer setBorderWidth:1];
    
    [[self.view viewWithTag:5501].layer setBorderColor:[[UIColor whiteColor]CGColor]];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    _siteListview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

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
    //    UILabel *lableTime=[mainVCView viewWithTag:5214];
    //    if (lableTime) {
    //        [lableTime setTextColor:kGetHomeLabelColor];
    //    }
}

-(IBAction)didClickNextButton:(id)sender
{
    if ([[NSString stringWithFormat:@"%@",[_responseDictionary valueForKey:@"isWorkOrderSelectionMandatory"]] boolValue])
    {
        if (_dicSelectedJob)
        {
            [_ContractorDetail setObject:[_dicSelectedJob valueForKey:KEY_WORK_OrderID] forKey:KEY_WORK_OrderID];
            [self checkAndCalCompilerHandler];
        }
        else
        {
            [Common showAlert:@"Error" : @"Please select any job first"];
        }
    }
    else
    {
        if (_dicSelectedJob)
        {
            [_ContractorDetail setObject:[_dicSelectedJob valueForKey:KEY_WORK_OrderID] forKey:KEY_WORK_OrderID];
        }

        [self checkAndCalCompilerHandler];
    }
}

-(void)checkAndCalCompilerHandler
{
    SiteConfig *config = [Common appDelegate].config;
    if(!config.isWorkLocationScreenVisible && !config.customQuestionScreen.contractor.isEnabled && !config.isWorkPermitsEnabled && !config.isPhotoRequiredSignInContractor && !config.isSignatureRequiredContractor && !config.signInApprovalScreen.contractor.isEnabled)
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
        _didFinishWithJobSelection(_ContractorDetail);
    }
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_siteArray count] > 0)
    {
        _noData.hidden = YES;
    }
    else
    {
        _noData.hidden = NO;
    }
    return [_siteArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *lbFirstName= (UILabel *) [cell.contentView viewWithTag:1001];
    [lbFirstName applyUITheme:kThemeGreyValue(255.0)];
    lbFirstName.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    lbFirstName.text = [NSString stringWithFormat:@"%@",[[_siteArray objectAtIndex:indexPath.row] valueForKey:@"displayText"]];
    
    cell.backgroundColor = [UIColor clearColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = kGetThemeColor;
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:true];
    _dicSelectedJob = [_siteArray objectAtIndex:indexPath.row];
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
