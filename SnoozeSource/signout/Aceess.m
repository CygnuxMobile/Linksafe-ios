//
//  Aceess.m
//  LinkSafe
//
//  Created by uday on 17/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "Aceess.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"

@interface Aceess ()
{
    NSMutableArray *arrItems;
    NSMutableArray *arrCredentials;
}

@end

@implementation Aceess

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Aceess" parameters:@{@"onload": @"24"}];
    self.lblcontractordetail.textColor = kGetHomeLabelColor;
    self.navigationItem.hidesBackButton = YES;
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    [Common ApplyUIViewTheme:_tblItems];
    [Common ApplyUIViewTheme:_tblCredential];
    
    [Common ApplyUIViewTheme:_viewLblSignedIn];
    [Common ApplyUIViewTheme:_viewActiveWorkers];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:self.viewCredentials];
    if ([[self.contractorInfo valueForKey:@"isCompliant"] boolValue])
    {
        [self getCredentials];
        _tblItems.hidden=YES;
        _acessImage.image=[UIImage imageNamed:@"accessgranted"];
        [_btnSignOutSuccess setTitle:[@"  Access granted" uppercaseString] forState:UIControlStateNormal];
        [_btnSignOutSuccess setImage:[UIImage imageNamed:@"truewhight"] forState:UIControlStateNormal];
    }
    else
    {
        self.viewCredentials.hidden = YES;
        _acessImage.image=[UIImage imageNamed:@"accessdenied"];
        [_btnSignOutSuccess setTitle:[NSString stringWithFormat:@" %@", [self.contractorInfo valueForKey:@"nonComplianceText"]] forState:UIControlStateNormal];
        _btnSignOutSuccess.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _btnSignOutSuccess.titleLabel.adjustsFontSizeToFitWidth = YES;
        _btnSignOutSuccess.titleLabel.numberOfLines = 3;
        _btnSignOutSuccess.backgroundColor=[UIColor redColor];
        [_btnSignOutSuccess setImage:[UIImage imageNamed:@"crosswhight"] forState:UIControlStateNormal];
    }
    
    if ([[Common appDelegate] isIpad])
    {
        _btnSignOutSuccess.titleLabel.font = [UIFont systemFontOfSize:35.0];
    }
    else
    {
        _btnSignOutSuccess.titleLabel.font = [UIFont systemFontOfSize:16.0];
        int needHight=650;
        if ([[self.contractorInfo valueForKey:@"isCompliant"] boolValue]) {
            needHight=needHight-100;
        }
        
        if (self.view.frame.size.height>needHight) {
            needHight=self.view.frame.size.height;
        }
        
        self.uiContainView.frame = CGRectMake(0, 0, self.view.bounds.size.width,needHight);
        self.tpScroll.contentSize = CGSizeMake(self.view.frame.size.width,self.uiContainView.frame.size.height);
    }
        
    _lblName.text = [NSString stringWithFormat:@"%@ %@",[self.contractorInfo valueForKey:@"firstName"],[self.contractorInfo valueForKey:@"lastName"]];
    _lblPin.text = [NSString stringWithFormat:@"%@",[self.contractorInfo valueForKey:KEY_PIN]];
    _lblCompany.text = [self.contractorInfo valueForKey:@"companyName"];

    if ([[self.contractorInfo valueForKey:@"failedRules"] isKindOfClass:[NSArray class]] || [[self.contractorInfo valueForKey:@"failedRules"] isKindOfClass:[NSMutableArray class]])
    {
        arrItems = [[NSMutableArray alloc] initWithArray:[self.contractorInfo valueForKey:@"failedRules"]];
    }
    else
    {
        arrItems = [[NSMutableArray alloc] init];
    }
    
    _tblItemsHeight.constant = ([arrItems count] + 1) * 40;
    
    [_btnSignOutSuccess setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_homeButton applyBlueShedow];
    
    if(_isSpotUser){
        _viewLblSignedIn.hidden = NO;
        NSString *str = [NSString stringWithFormat:@"%@",[_contractorInfo valueForKey:@"signedInTime"]];
        if([str isEqualToString:@""]){
            _lblSignedInTime.text = [NSString stringWithFormat:@"Signed in: NO"];//Signed in
        }
        else{
            _lblSignedInTime.text = [NSString stringWithFormat:@"Signed in: %@",[_contractorInfo valueForKey:@"signedInTime"]];
        }
        
        _viewActiveWorkers.hidden = NO;
        _lblActiveWorkers.text = [NSString stringWithFormat:@"Total Company Workers: %@",[_contractorInfo valueForKeyPath:@"company.activeWorkers"]];
    }
    else{
        _viewLblSignedIn.hidden = YES;
        _viewActiveWorkers.hidden = YES;
    }
    
    [self.tblCredential reloadData];
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

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (IBAction)closeMe:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

#pragma mark - UITableView Datasource and Delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblCredential) {
        return arrCredentials.count;
    }
    else {
        return arrItems.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblCredential) {
        return 1;
    }
    else {
        return 40;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblCredential) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        int viewWidth=view.frame.size.width;
        [view setBackgroundColor:kThemeBGGrey];
        view.layer.cornerRadius=3.0;
        
        UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(5,0, viewWidth-10,40)];
        [lbName applyUITheme:kThemeGreyValue(0.0)];
        lbName.text=@"Reasons";
        lbName.textAlignment = NSTextAlignmentCenter;
        [lbName applyUITheme:kThemeGreyValue(255.0)];
        lbName.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
        [view addSubview:lbName];
        
        return view;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    
    if (tableView == self.tblCredential) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSDictionary *dic = arrCredentials[indexPath.row];
        
        UILabel *lbl1 = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *lbl2 = (UILabel *)[cell.contentView viewWithTag:2];
        UIButton *btnResend = (UIButton *)[cell.contentView viewWithTag:3];
        if(_isSpotUser) {
            btnResend.hidden = ![[NSString stringWithFormat:@"%@", [dic objectForKey:@"isDue"]] boolValue];
        }
        else {
            btnResend.hidden = YES;
        }
        [btnResend addTarget:self action:@selector(selectResendEmailClick:) forControlEvents:UIControlEventTouchUpInside];

        lbl1.numberOfLines=2;
        lbl1.lineBreakMode = NSLineBreakByWordWrapping;
        lbl1.text = [dic objectForKey:@"itemType"];
        lbl2.text = [[dic objectForKey:@"expiresOn"] length] > 0 ? [dic objectForKey:@"expiresOn"] : [dic objectForKey:@"status"];
        
        NSString *str = [dic objectForKey:@"itemID"];
        
        if ([str length] == 0) {
            btnResend.hidden = YES;
        }
        
        if ([[NSString stringWithFormat:@"%@", [dic objectForKey:@"isCompliant"]] boolValue])
        {
            lbl1.textColor = [UIColor whiteColor];
            lbl2.textColor = [UIColor whiteColor];
        }
        else
        {
            lbl1.textColor = [UIColor redColor];
            lbl2.textColor = [UIColor redColor];
        }
        
        if (indexPath.row % 2 == 0)
        {
            cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        }
        else
        {
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *lbl1 = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *lbl2 = (UILabel *)[cell.contentView viewWithTag:2];
        lbl2.layer.cornerRadius=4.0f;
        lbl1.numberOfLines=2;
        lbl1.lineBreakMode = NSLineBreakByWordWrapping;
        
        UIButton *btnResend = (UIButton *)[cell.contentView viewWithTag:3];
        [btnResend addTarget:self action:@selector(selectResendEmailClick:) forControlEvents:UIControlEventTouchUpInside];
        btnResend.hidden = YES;
        
        id data = arrItems[indexPath.row];
        if ([data isKindOfClass:[NSString class]] || [data isKindOfClass:[NSMutableString class]]) {
            lbl1.text = data;
        }
        else if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSMutableDictionary class]]) {
            lbl1.text = data[@"description"];
            NSString *str = [data objectForKey:@"itemID"];
            if ([str length] > 0) {
                btnResend.hidden = NO;
            }
        }
        
        return cell;
    }
}

- (void)selectResendEmailClick:(id)sender {
    
    UIView *aView = (UIView *)sender;
    while(aView != nil) {
        if([aView isKindOfClass:[UITableViewCell class]]) {
            
            UITableViewCell *cell = (UITableViewCell *) aView;
            if ([[self.contractorInfo valueForKey:@"isCompliant"] boolValue])
            {
                NSIndexPath *indexpath = [self.tblCredential indexPathForCell:cell];
                NSDictionary *dic = arrCredentials[indexpath.row];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Resend Email?" message:[NSString stringWithFormat:@"Resend previous email for %@", [dic objectForKey:@"itemType"]] preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                    [parameters setObject:[self.contractorInfo valueForKey:KEY_PIN] forKey:KEY_PIN];
                    [parameters setObject:[dic objectForKey:@"itemID"] forKey:@"itemID"];
                    
                    [Common callAPI:parameters Request:API_SEND_COMPLIANCE_ITEM_EMAIL ShowProgress:YES WithCompletionHandler:^(id responseObject)
                    {
                        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                        {
                            [Common showSuccess:@"" : @"Email has been sent successfully.\nThanks!"];
                        }
                    }];
                    
                }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                NSIndexPath *indexpath = [self.tblItems indexPathForCell:cell];
                NSDictionary *dic = arrItems[indexpath.row];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Resend Email?" message:[NSString stringWithFormat:@"Resend previous email for %@", [dic objectForKey:@"description"]] preferredStyle:UIAlertControllerStyleAlert];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                    [parameters setObject:[self.contractorInfo valueForKey:KEY_PIN] forKey:KEY_PIN];
                    [parameters setObject:[dic objectForKey:@"itemID"] forKey:@"itemID"];
                    
                    [Common callAPI:parameters Request:API_SEND_COMPLIANCE_ITEM_EMAIL ShowProgress:YES WithCompletionHandler:^(id responseObject)
                    {
                        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                        {
                            [Common showSuccess:@"" : @"Email has been sent successfully.\nThanks!"];
                        }
                    }];
                    
                }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        }
        aView = aView.superview;
    }
}

#pragma mark - Get Credentials from API
-(void)getCredentials
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[self.contractorInfo valueForKey:KEY_PIN] forKey:KEY_PIN];
    
    [Common callAPI:parameters Request:API_GET_COMPLIANCE_ITEMS ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        self->arrCredentials = [[NSMutableArray alloc] init];
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            self->arrCredentials = [responseObject objectForKey:@"items"];
        }
        
        _tblCredentialsHeight.constant = [arrCredentials count] * 40;
        
        [self.tblCredential reloadData];
    }];
}

@end
