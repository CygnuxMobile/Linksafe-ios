#import "ContractorPermissions.h"
#import "UIButton+Additions.h"
#import "AsyncImageView.h"
#import "ContractorWorkDetailVC.h"
#import "UILabel+Additions.h"
#import "TakePhotoVC.h"
#import "BEMCheckBox.h"

#define Scale [UIScreen mainScreen].scale

@interface ContractorPermissions ()
{
    NSArray *contractorPermissionArray;
    BEMCheckBox *myCheckBox;
}

@property (weak, nonatomic) IBOutlet UIView *viewByPassPrompt;
@property (weak, nonatomic) IBOutlet UIView *viewByPassPromptContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblByPassPromptText;
@property (weak, nonatomic) IBOutlet UIButton *btnByPassPromptCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnByPassPromptContinue;
@property (weak, nonatomic) IBOutlet UIView *viewByPassPromptCheckBox;

@end

@implementation ContractorPermissions

- (void)viewDidLoad
{
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Permissions" parameters:@{@"onload": @"26"}];
    _viewByPassPrompt.hidden = YES;
    SiteConfig *config = [Common appDelegate].config;

    if (config.permitBypassPromptText.length > 0)
    {
        _lblByPassPromptText.text = config.permitBypassPromptText;
        if ([Common appDelegate].isIpad) {
            
        }
        else {
            CGSize textSize = CGSizeMake(_lblByPassPromptText.frame.size.width, MAXFLOAT);
            int rHeight = lroundf([_lblByPassPromptText sizeThatFits:textSize].height);
            
            CGRect frame = _lblByPassPromptText.frame;
            frame.size.height = rHeight;
            _lblByPassPromptText.frame = frame;
            
            frame = _viewByPassPromptContainer.frame;
            frame.size.height = _lblByPassPromptText.frame.origin.y + _lblByPassPromptText.frame.size.height + 125;
            _viewByPassPromptContainer.frame = frame;
            _viewByPassPromptContainer.center = _viewByPassPrompt.center;
        }

        myCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, _viewByPassPromptCheckBox.frame.size.width, _viewByPassPromptCheckBox.frame.size.height)];
        myCheckBox.boxType=BEMBoxTypeSquare;
        myCheckBox.onAnimationType=BEMAnimationTypeBounce;
        myCheckBox.offAnimationType=BEMAnimationTypeBounce;
        myCheckBox.tintColor=kThemeBlueColor;
        myCheckBox.onFillColor=[UIColor whiteColor];
        myCheckBox.offFillColor=[UIColor clearColor];
        myCheckBox.onTintColor=kThemeBlueColor;
        myCheckBox.onCheckColor=kThemeBlueColor;
        [_viewByPassPromptCheckBox addSubview:myCheckBox];
    }
    
    _lblHeader.textColor = kGetHomeLabelColor;
    if (config.permitSelectionPreamble.length > 0) {
        _lblHeader.text = config.permitSelectionPreamble;
        _lblHeader.numberOfLines = 0;
        [_lblHeader sizeToFit];
        
        NSInteger lineCount = 0;
        CGSize textSize = CGSizeMake(_lblHeader.frame.size.width, MAXFLOAT);
        int rHeight = lroundf([_lblHeader sizeThatFits:textSize].height);
        int charSize = lroundf(_lblHeader.font.lineHeight);
        lineCount = rHeight/charSize;
        NSLog(@"No of lines: %i",lineCount);
        
        if ([[Common appDelegate] isIpad])
        {
            if (lineCount > 1) {
                
                CGRect frame = _lblHeader.frame;
                frame.size.height = [self getLabelHeight:_lblHeader];
                frame.origin.x = 10;
                frame.size.width = _contentView.frame.size.width - 20;
                _lblHeader.frame = frame;
                
                frame = _ContractorPermissionTableView.frame;
                frame.origin.y = _lblHeader.frame.origin.y + _lblHeader.frame.size.height + 8;
                _ContractorPermissionTableView.frame = frame;
                
                frame = _contentView.frame;
                frame.size.height = frame.size.height + (_lblHeader.frame.size.height - 40);
            }
            else {
                CGRect frame = _lblHeader.frame;
                frame.size.height = 40;
                frame.origin.x = 10;
                frame.size.width = _contentView.frame.size.width - 20;
                _lblHeader.frame = frame;
            }
        }
        else
        {
            if (lineCount > 2) {
                
                CGRect frame = _lblHeader.frame;
                frame.size.height = [self getLabelHeight:_lblHeader];
                frame.origin.x = 10;
                frame.size.width = _contentView.frame.size.width - 20;
                _lblHeader.frame = frame;
                
                frame = _ContractorPermissionTableView.frame;
                frame.origin.y = _lblHeader.frame.origin.y + _lblHeader.frame.size.height + 8;
                _ContractorPermissionTableView.frame = frame;
                
                frame = _contentView.frame;
                frame.size.height = frame.size.height + (_lblHeader.frame.size.height - 40);
            }
            else {
                CGRect frame = _lblHeader.frame;
                frame.size.height = 40;
                frame.origin.x = 10;
                frame.size.width = _contentView.frame.size.width - 20;
                _lblHeader.frame = frame;
            }
        }
    }
    
    [_btnContinue applyBlueShedow];
    [_btnCancel applyGrayTheme];
    
    [_btnByPassPromptContinue applyBlueShedow];
    [_btnByPassPromptCancel applyGrayTheme];
    
//    if([Common appDelegate].isIpad)
//    {
//        self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,self.view.frame.size.height);
//        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
//    }
    
    
    [Common setBgImage:self.view useDefault:YES];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common applyThemeColorToPowerdBy:self.view];
    
    _ContractorPermissionTableView.layer.cornerRadius=3.0;
    _ContractorPermissionTableView.clipsToBounds=YES;
    
    [Common ApplyUIViewBoeder:_ContractorPermissionTableView];
    [self PermissionAPI];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [self upadteTime];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = self.navTitle;//@"CONTRACTOR SIGN IN";
    [_ContractorPermissionTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    _viewByPassPrompt.hidden = YES;
    [myCheckBox setOn:NO];
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

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (IBAction)onContinue:(id)sender {
//    [self createWorkPermitForm];
    [self checkForByPassPrompt];
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onByPassPromptContinue:(id)sender {
    
    if (myCheckBox.on) {
    
        [self createWorkPermitForm];
    }
    else {
        [Common showAlert:@"" :@"You cannot proceed without checking the checkbox."];
    }
}

- (IBAction)onByPassPromptCancel:(id)sender {
    
    _viewByPassPrompt.hidden = YES;
}

#pragma mark - Table View Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [contractorPermissionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    UISwitch *defaultSwitch;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"switch==================>3   %ld",indexPath.row);
    }
    defaultSwitch= (UISwitch *) [cell.contentView viewWithTag:(21000 + indexPath.row)];
    if (defaultSwitch==nil)
    {
        defaultSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 100, 0, 0 )];
        defaultSwitch.backgroundColor = [UIColor whiteColor];
        defaultSwitch.onTintColor =[UIColor whiteColor];
        defaultSwitch.clipsToBounds = true;
        defaultSwitch.layer.cornerRadius = 16;
        
        
        defaultSwitch.tag = (21000 + indexPath.row);
        [defaultSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = defaultSwitch;
    }
    
    UILabel *lbPermission= (UILabel *) [cell.contentView viewWithTag:1001];
    lbPermission.frame=CGRectMake(5,0, tableView.frame.size.width-70,50);
    [lbPermission applyUITheme:kThemeGreyValue(24.0)];
    lbPermission.textColor=[UIColor whiteColor];
    
    lbPermission.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    
    lbPermission.text = [[contractorPermissionArray objectAtIndex:indexPath.row] valueForKeyPath:@"displayText"];
    if ([[contractorPermissionArray objectAtIndex:indexPath.row] valueForKey:VAL_SWITCH])
    {
        defaultSwitch.on=[[[contractorPermissionArray objectAtIndex:indexPath.row] valueForKey:VAL_SWITCH] boolValue];
    }
    else
    {
        defaultSwitch.on=NO;
    }
    defaultSwitch.thumbTintColor = defaultSwitch.on ? [UIColor greenColor] : [UIColor redColor];
    
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)changeSwitch:(id)sender{
    UISwitch *swPermission = (UISwitch *)sender;
    swPermission.thumbTintColor = swPermission.on ? [UIColor greenColor] : [UIColor redColor];

    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((long)swPermission.tag - 21000) inSection:0];
    NSLog(@"Switch======%ld",(long)indexPath.row);
    [[contractorPermissionArray objectAtIndex:indexPath.row] setObject:swPermission.on?@"1":@"0" forKey:VAL_SWITCH];
}

-(void)PermissionAPI
{
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
  
    [Common callAPI:dicParameters Request:GET_WORK_PERMITTYPES ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            contractorPermissionArray = [[responseObject valueForKeyPath:@"workPermitTypes"] mutableCopy];
        }
        else
           
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
        
        if (self->contractorPermissionArray==nil)
        {
            self->contractorPermissionArray=[[NSArray alloc] init];
        }
        if ([self->contractorPermissionArray count]>0)
        {
            self.ContractorPermissionTableView.hidden=NO;
            
            int neededHight=0;
            CGRect tblRect=self->_ContractorPermissionTableView.frame;
            
            if ([Common appDelegate].isIpad)
            {
                neededHight=(int)[self->contractorPermissionArray count]*60;
                tblRect.size.height=neededHight;
                neededHight=344+neededHight;
            }
            else
            {
                neededHight=(int)[self->contractorPermissionArray count]*40;
                tblRect.size.height=neededHight;
                neededHight=345+neededHight;
            }
            self.ContractorPermissionTableView.frame=tblRect;
            neededHight=(self.view.frame.size.height)>neededHight?(self.view.frame.size.height):neededHight;
            self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width,neededHight);
            self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,self->_contentView.frame.size.height);
        }
        else
        {
            self.ContractorPermissionTableView.hidden=YES;
        }
        [self.ContractorPermissionTableView reloadData];
    }];
}

-(void)checkForByPassPrompt
{
    NSMutableArray *permissionID=[[NSMutableArray alloc] init];
    for (int i=0;i<[contractorPermissionArray count];i++)
    {
        if ([[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH])
        {
            if ([[[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH] boolValue])
            {
                [permissionID addObject:[NSString stringWithFormat:@"%@",[[contractorPermissionArray objectAtIndex:i] valueForKey:@"workPermitTypeID"]]];
            }
        }
    }
    
    if ([permissionID count] <= 0)
    {
        SiteConfig *config = [Common appDelegate].config;
        
        if (config.permitBypassPromptText.length > 0)
        {
            _viewByPassPrompt.hidden = NO;
            _lblByPassPromptText.text = config.permitBypassPromptText;
        }
        else
        {
            [self createWorkPermitForm];
        }
    }
    else {
        [self createWorkPermitForm];
    }
}

//-------- create by w7shal on
-(void)createWorkPermitForm
{
    NSMutableArray *permissionID=[[NSMutableArray alloc] init];
    for (int i=0;i<[contractorPermissionArray count];i++)
    {
        if ([[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH])
        {
            if ([[[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH] boolValue])
            {
                [permissionID addObject:[NSString stringWithFormat:@"%@",[[contractorPermissionArray objectAtIndex:i] valueForKey:@"workPermitTypeID"]]];
            }
        }
    }
    
    if ([permissionID count] <= 0)
    {
        SiteConfig *config = [Common appDelegate].config;
        if(!config.isPhotoRequiredSignInContractor && !config.isSignatureRequiredContractor && !config.signInApprovalScreen.contractor.isEnabled)
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
            _didFinishwithWorkPermission(_ContractorDetail);
        }
        return;
    }
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setValue:[USER_DEFAULT objectForKey:KEY_CONTRACTOR_PIN] forKey:KEY_PIN];
    if ([permissionID count]>0)
    {
        [dicParameters setValue:permissionID forKey:KEY_PERMIT_TYPES_REQUIRED];
    }
    [dicParameters setObject:[_ContractorDetail objectForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
    
    [Common callAPI:dicParameters Request:CREATE_WORK_PERMIT_FORM ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            for (NSString *key in responseObject)
            {
                [_ContractorDetail setObject:[responseObject objectForKey:key] forKey:key];
            }
            NSMutableArray *permissionArray=[[NSMutableArray alloc] init];
            NSMutableDictionary *permitDic;
            for (int i=0;i<[contractorPermissionArray count];i++)
            {
                if ([[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH])
                {
                    if ([[[contractorPermissionArray objectAtIndex:i] valueForKey:VAL_SWITCH] boolValue])
                    {
                        [permissionArray addObject:[contractorPermissionArray objectAtIndex:i]];
                        if (permitDic==nil)
                        {
                            permitDic=[[contractorPermissionArray objectAtIndex:i] mutableCopy];
                        }
                    }
                }                
            }
            [_ContractorDetail setObject:permitDic forKey:@"WorkObj"];
            [_ContractorDetail setObject:permissionArray forKey:KEY_PERMIT_TYPES_REQUIRED];
            
            [self openContractorWork:_ContractorDetail];
            
        }
        else
            
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }
     ];
}
-(void)openContractorWork:(NSMutableDictionary *)workDic
{
    ContractorWorkDetailVC *contractorWorkDetailVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorWorkDetailVC"];
    contractorWorkDetailVC.workDetailsDic = workDic;
    contractorWorkDetailVC.navTitle = self.navTitle;
    contractorWorkDetailVC.didFinishwithWorkDetail = ^(NSMutableDictionary *dicPic)
    {
        [self submitWorkPermitForm];
    };
    [self.navigationController pushViewController:contractorWorkDetailVC animated:YES];
}

-(void)submitWorkPermitForm
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setValue:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[_ContractorDetail valueForKey:KEY_WORKPERMIT_FORM_ID]] intValue]] forKey:KEY_WORKPERMIT_FORM_ID];
    
    [Common callAPI:dicParameters Request:REQUEST_SUBMIT_WORK_PERMIT_FORM ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            if ([_ContractorDetail valueForKey:KEY_WORK_OrderID])
            {
                [dicParameters setValue:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[_ContractorDetail valueForKey:KEY_WORK_OrderID]] intValue]] forKey:KEY_WORK_OrderID];
            }

            SiteConfig *config = [Common appDelegate].config;
            if(!config.isPhotoRequiredSignInContractor && !config.isSignatureRequiredContractor && !config.signInApprovalScreen.contractor.isEnabled)
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
                _didFinishwithWorkPermission(dicParameters);
            }
        }
        else
        {
            NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
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
