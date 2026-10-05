//
//  SCValidateContractorVC.m
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import "SCValidateContractorVC.h"
#import "UIButton+Additions.h"
#import "Aceess.h"

@interface SCValidateContractorVC ()

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, retain) NSDictionary *selectedCompany;
@property (nonatomic, retain) NSArray *arrCompanies;
@property (retain, nonatomic) NSMutableDictionary *contractorDetails;

@end

@implementation SCValidateContractorVC

+(SCValidateContractorVC *)viewController {
    
    SCValidateContractorVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SCValidateContractorVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Validate Contractor" parameters:@{@"onload": @"19"}];
    // Do any additional setup after loading the view.
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    _lblHeader.textColor = kGetHomeLabelColor;
    
    _imgTakePhoto.hidden = YES;
    _imgTakePhoto.layer.cornerRadius = 3;
    _imgTakePhoto.clipsToBounds=YES;
    
    [_btnValidate applyBlueShedow];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
    _imgDropdown.image = [[UIImage imageNamed:@"down_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _imgDropdown.tintColor = [UIColor whiteColor];
    
    [self getUserDetails];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    [self upadteTime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (IBAction)onValidateButtonClick:(id)sender {
    
    [self validateSpotCheck];
}

- (IBAction)onSelectCompanyButtonClick:(id)sender {
    
    if (_arrCompanies.count > 0) {
        
        NSArray *name = [_arrCompanies valueForKey:@"displayText"];
        [ActionSheetStringPicker showPickerWithTitle:@"Select Company" rows:name initialSelection:_selectedIndex
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _selectedIndex = selectedIndex;
            _selectedCompany = [_arrCompanies objectAtIndex:selectedIndex];
            _lblCompany.text = [NSString stringWithFormat:@"%@", [_selectedCompany objectForKey:@"displayText"]];
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
             NSLog(@"Block Picker Canceled");
         
        } origin:sender];
    }
}

-(void)getUserDetails {
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setObject:[_userDetails objectForKey:KEY_PIN] forKey:KEY_PIN];
    [Common callAPI:dicParameters Request:kGetSpotCheckWorkerDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
       
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue]) {
            
            _contractorDetails = [responseObject objectForKey:@"worker"];
            [self setUserData:[responseObject objectForKey:@"worker"]];
        }
        else {
            
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(void)setUserData:(NSDictionary *)userDetails {
    
    _imgTakePhoto.hidden = YES;
    if ([userDetails valueForKey:@"photoUri"]) {
        NSString *base64 = [NSString stringWithFormat:@"%@", [userDetails objectForKey:@"photoUri"]];
        _imgTakePhoto.image = [Common decodeBase64ToImage:base64];
        _imgTakePhoto.hidden = NO;
    }
    _lblFirstName.text = [NSString stringWithFormat:@"%@", [userDetails objectForKey:@"firstName"]];
    _lblLastName.text = [NSString stringWithFormat:@"%@", [userDetails objectForKey:@"lastName"]];
    _lblCompany.text = @"";
    if ([userDetails valueForKey:@"companies"]) {
        NSArray *companies = [userDetails objectForKey:@"companies"];
        _arrCompanies = companies;
        if (companies.count > 0) {
            /*
            {
                "id": 25418,
                "displayText": "Frank's Plumbing"
            }
            */
            _imgDropdown.hidden = (companies.count == 1);
            NSDictionary *company = [companies objectAtIndex:0];
            _selectedIndex = 0;
            _selectedCompany = company;
            _lblCompany.text = [NSString stringWithFormat:@"%@", [company objectForKey:@"displayText"]];
        }
    }
    _lblMobileNo.text = [NSString stringWithFormat:@"%@", [userDetails objectForKey:@"phoneNumber"]];
}

-(void)validateSpotCheck
{
    NSString *pin = [_contractorDetails objectForKey:@"pin"];
    NSString *companyId = [_selectedCompany objectForKey:@"id"];
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] initWithDictionary:@{KEY_PIN:pin, @"companyID": companyId, @"SiteID":_strSelectedSiteId}];
    [Common callAPI:dicParameters Request:API_VALIDATE_SPOT_CHECK ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
         if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
         {
             if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nonComplianceText"]] rangeOfString:@"isn't in our database"].location == NSNotFound)
             {
                 Aceess *aceess = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"Aceess"];
                 aceess.contractorInfo = [responseObject mutableCopy];
                 aceess.isSpotUser = YES;
                 aceess.modalPresentationStyle = UIModalPresentationFullScreen;
                 [self presentViewController:aceess animated:YES completion:^{
                     
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 }];
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

@end
