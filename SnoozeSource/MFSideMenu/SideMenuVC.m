//
//  SideMenuVC.m
//  Extreme_trip
//
//  Created by Hitesh Gs on 08/05/15.
//  Copyright (c) 2015 Hitesh Gs. All rights reserved.
//

#import "SideMenuVC.h"
#import "MFSideMenu.h"
#import "HomeVC.h"
#import "AppDelegate.h"
#import "SiteRegister.h"
#import "BackGroundPic.h"
#import "SettingView.h"

#import "SettingView.h"


@interface SideMenuVC ()
{
    NSMutableDictionary *op1,*op2,*op3,*op4;
    BOOL isCancelled, isVerified;
    NSUInteger selectedIndex;
}
@end

@implementation SideMenuVC
@synthesize lastSelectedOption;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    op1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Site Register",@"title",@"siteregister",@"image",@"1",@"opid", nil];
    op2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Settings",@"title",@"setting",@"image",@"2",@"opid", nil];
    op3 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Background Image",@"title",@"background",@"image",@"3",@"opid", nil];
    op4 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Logout",@"title",@"logout",@"image",@"4",@"opid", nil];
    
    sideMenuList= [[NSMutableArray alloc] initWithObjects:op2,op4, nil];
    [tblSideMenu reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openManualScreen:) name:@"openManualScreen" object:nil];
    _lblUsername.text = @"remove me";
    
}
-(void)viewWillAppear:(BOOL)animated
{
    isCancelled = NO;
    isVerified = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setbutton)
                                                 name:N_UpdateSideMenuScreen
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkVerified:)
                                                 name:@"notVerified"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkVerified:)
                                                 name:@"Verified"
                                               object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateSideMenuScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notVerified" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Verified" object:nil];
    isCancelled = NO;
    isVerified = NO;
}

- (void)checkVerified:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"notVerified"]){
        isCancelled = YES;
        isVerified = NO;
    }
    else if ([[notification name] isEqualToString:@"Verified"]){
        isVerified = YES;
        isCancelled = NO;
    }
    [self openScreen:selectedIndex];
    
}

-(void)setbutton
{
    BOOL isSiteRegisterEnabled=[Common appDelegate].config.isSiteRegisterEnabled;
    if (isSiteRegisterEnabled)
    {
        sideMenuList= [[NSMutableArray alloc] initWithObjects:op1,op2,op4,nil];
        [tblSideMenu reloadData];
    }
    
    BOOL isSpotCheckUser=[Common appDelegate].config.isSpotCheckUser;
    if (isSpotCheckUser)
    {
        sideMenuList= [[NSMutableArray alloc] initWithObjects:op1,op2,op4,nil];
        [tblSideMenu reloadData];
    }
}

-(void)openManualScreen :(NSNotification *)notification
{
    NSString *index = notification.object;
    
    if (index)
    {
        [self openScreen:[index integerValue]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sideMenuList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *menuOption = [sideMenuList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tblSideMenu dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    UIImageView *img = (UIImageView *)[cell.contentView viewWithTag:1];
    
    UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:2];
    
    img.image =[UIImage imageNamed:[menuOption valueForKey:@"image"]];
    
    lblName.text = [menuOption valueForKey:@"title"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        selectedIndex = [[[self->sideMenuList objectAtIndex:indexPath.row] valueForKey:@"opid"] intValue];
        [self openScreen:[[[self->sideMenuList objectAtIndex:indexPath.row] valueForKey:@"opid"] intValue]];
    }];
}
-(void)openScreen :(NSUInteger )index
{
    UINavigationController *navController = self.menuContainerViewController.centerViewController;
    navController.navigationItem.title=@"";
    
    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userSpot"]];
    
    if ([strIsSpotCheckUser isEqualToString:@"1"] && index == 1) {
        SiteRegister   *siteRegisterVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SiteRegister"];
        [navController pushViewController:siteRegisterVC animated:YES];
        return;
    }
    SiteConfig *config = [Common appDelegate].config;
    
    //    BOOL isTouchID = [USER_DEFAULT boolForKey:kTouchID];
    
    
    if([USER_DEFAULT boolForKey:kTouchID] && !isCancelled && !isVerified){
        [JZTouchID openTouchId:NO];
    }
    else if([USER_DEFAULT boolForKey:kTouchID] && !isCancelled && isVerified){
        NSMutableDictionary *siteData = [Common SiteData];
        NSString *strSiteDataUser = [NSString stringWithFormat:@"%@",[siteData valueForKey:KEY_SiteUser]];
        
        NSMutableArray *arrTouchData = [[NSMutableArray alloc]init];
        arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
        
        if(arrTouchData.count>0){
            for (int i = 0; i<arrTouchData.count; i++) {
                NSDictionary *dict = [arrTouchData objectAtIndex:i];
                NSString *strTouchUser = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_SiteUser]];
                
                if ([strSiteDataUser isEqualToString:strTouchUser]) {
                    
                    NSString *strTouchPassword = [NSString stringWithFormat:@"%@",[dict valueForKey:KEY_PASSWORD]];
                    [Common callAPI:[[NSMutableDictionary alloc] initWithObjectsAndKeys:strTouchPassword,@"password", nil] Request:REQUEST_VALIDATE_PASSWORD ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                        {
                            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_VALID]] boolValue])
                            {
                                if (index==4)
                                {
                                    [Common callAPI:[[NSMutableDictionary alloc] init] Request:REQUEST_LOGOUT ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                                        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                                            
                                            [Common removeSiteData];
                                    }];
                                    
                                }
                                else
                                {
                                    isCancelled = NO;
                                    isVerified = NO;
                                    if (index==1)
                                    {
                                        SiteRegister   *siteRegisterVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SiteRegister"];
                                        siteRegisterVC.sitePassword = strTouchPassword;
                                        [navController pushViewController:siteRegisterVC animated:YES];
                                    }
                                    else if (index==3)
                                    {
                                        BackGroundPic *backGroundPic = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"BackGroundPic"];
                                        [navController pushViewController:backGroundPic animated:YES];
                                    }
                                    else if (index==2)
                                    {
                                        SettingView *settingView = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SettingView"];
                                        //SettingView *settingView = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SettingView"];
                                        [navController pushViewController:settingView animated:YES];
                                    }
                                }
                            }
                            else
                            {
                                [Common showAlert:@"Error" :[[responseObject valueForKey:KEY_ERROR_MESSAGE] length]>0?[responseObject valueForKey:@"errorMessage"]:@"Please enter valid password"];
                            }
                        }
                        else
                        {
                            [Common showAlert:@"Error" :[[responseObject valueForKey:KEY_ERROR_MESSAGE] length]>0?[responseObject valueForKey:@"errorMessage"]:@"Please try again."];
                        }
                    }];
                    break;
                }
            }
        }
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",(config.siteName ? config.siteName : @"Alert")] message:@"Site Password" preferredStyle:UIAlertControllerStyleAlert];
        NSString *varifyLable=@"Verify";
        if (index==4)
        {
            varifyLable=@"Logout";
        }
        [alert addAction:[UIAlertAction actionWithTitle:varifyLable style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *alertTextField = alert.textFields.firstObject;
            NSLog(@"And the text is... %@", alertTextField.text);
            [Common callAPI:[[NSMutableDictionary alloc] initWithObjectsAndKeys:alertTextField.text,@"password", nil] Request:REQUEST_VALIDATE_PASSWORD ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                {
                    if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_VALID]] boolValue])
                    { 
                        if (index==4)
                        {
                            
                            [Common callAPI:[[NSMutableDictionary alloc] init] Request:REQUEST_LOGOUT ShowProgress:YES WithCompletionHandler:^(id responseObject) {
                                if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                                    
                                    [Common removeSiteData];
                            }];
                            
                        }
                        else
                        {
                            UINavigationController *navController = self.menuContainerViewController.centerViewController;
                            navController.navigationItem.title=@"";
                            isCancelled = NO;
                            isVerified = NO;
                            if (index==1)
                            {
                                SiteRegister   *siteRegisterVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SiteRegister"];
                                siteRegisterVC.sitePassword=alertTextField.text;
                                [navController pushViewController:siteRegisterVC animated:YES];
                            }
                            else if (index==3)
                            {
                                BackGroundPic *backGroundPic = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"BackGroundPic"];
                                [navController pushViewController:backGroundPic animated:YES];
                            }
                            else if (index==2)
                            {
                                SettingView *settingView = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SettingView"];
                                //                                SettingView *settingView = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"SettingView"];
                                [navController pushViewController:settingView animated:YES];
                            }
                        }
                    }
                    else
                    {
                        [Common showAlert:@"Error" :[[responseObject valueForKey:KEY_ERROR_MESSAGE] length]>0?[responseObject valueForKey:@"errorMessage"]:@"Please enter valid password"];
                    }
                }
                else
                {
                    [Common showAlert:@"Error" :[[responseObject valueForKey:KEY_ERROR_MESSAGE] length]>0?[responseObject valueForKey:@"errorMessage"]:@"Please try again."];
                }
            }];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            isCancelled = NO;
            isVerified = NO;
        }]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @" Enter Password";
            textField.secureTextEntry = YES;
            [textField setBorderStyle:UITextBorderStyleNone];
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

@end
