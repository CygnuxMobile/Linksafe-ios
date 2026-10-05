//
//  SiteRegister.m
//  LinkSafe
//
//  Created by Wish on 26/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "SiteRegister.h"
#import "SiteDetails.h"
#import "UILabel+Additions.h"
#import "AsyncImageView.h"
#import "UserDetailsVC.h"

@interface SiteRegister ()

@end

@implementation SiteRegister

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"SiteRegister" parameters:@{@"onload": @"38"}];
    _lblHeader.textColor = kGetHomeLabelColor;
    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userSpot"]];
    if ([strIsSpotCheckUser isEqualToString:@"1"]) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"kSelectedSiteName"]) {
            NSString *str = @"Currently Signed in to";
            if ([Common appDelegate].isIpad) {
                str = [NSString stringWithFormat:@"%@ %@", str, [[NSUserDefaults standardUserDefaults] valueForKey:@"kSelectedSiteName"]];
            }
            else {
                str = [NSString stringWithFormat:@"%@\n%@", str, [[NSUserDefaults standardUserDefaults] valueForKey:@"kSelectedSiteName"]];
            }
            _lblHeader.text = str;
        }
        else {
            if ([Common appDelegate].isIpad) {
                _lblHeader.text = [NSString stringWithFormat:@"Currently Signed in to LinkSafe Site"];
            }
            else {
                _lblHeader.text = [NSString stringWithFormat:@"Currently Signed in to\nLinkSafe Site"];
            }
        }
    }
    else {
        
        NSString *str = @"Currently Signed in to";
        if ([Common appDelegate].isIpad) {
            str = [NSString stringWithFormat:@"%@ %@", str, [Common appDelegate].config.siteName ? [Common appDelegate].config.siteName : @"LinkSafe Site"];
        }
        else {
            str = [NSString stringWithFormat:@"%@\n%@", str, [Common appDelegate].config.siteName ? [Common appDelegate].config.siteName : @"LinkSafe Site"];
        }
        
        _lblHeader.text = str;
    }
    [self getRegisterSite];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [[self.view viewWithTag:5501].layer setBorderWidth:1];
    [[self.view viewWithTag:5501].layer setBorderColor:[[UIColor whiteColor]CGColor]];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    self.navigationItem.title=@"SITE REGISTER";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [self upadteTime];
}

-(void)upadteBackground
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

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}
- (void)getRegisterSite{
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    if ([Common appDelegate].config.isSpotCheckUser) {
        NSString *siteId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSelectedSiteId"];
        [dicParameters setObject:[NSNumber numberWithInt:[siteId intValue]] forKey:@"siteID"];
    }
    else {
        [dicParameters setObject:self.sitePassword forKey:@"password"];
    }
    
    [Common callAPI:dicParameters Request:REQUEST_GET_REGISTER_HISTORY ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            _siteArray = [responseObject valueForKey:@"registrations"];
            [_siteListview reloadData];
            [_siteListview performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            
        
            if (_siteArray==nil)
            {
                _siteArray=[[NSArray alloc] init];
            }
            
            if ([_siteArray count]>0)
            {
                _siteListview.hidden=NO;
                _noData.hidden=YES;
            }
            else
            {
                _siteListview.hidden=YES;
                _noData.hidden=NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No visitor or contractor currently signed in."
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"BACK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"BACK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        }
        });
    }];
    
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table View Data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [_siteArray count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    
    int viewWidth=view.frame.size.width;
    
    UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(5,0, viewWidth*0.3-5,50)];
    UILabel *lbType = [[UILabel alloc] initWithFrame:CGRectMake(lbName.frame.origin.x+lbName.frame.size.width,0, viewWidth*0.2,50)];
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(lbType.frame.origin.x+lbType.frame.size.width,0, viewWidth*0.2,50)];
    UILabel *lbCompany = [[UILabel alloc] initWithFrame:CGRectMake(lbTime.frame.origin.x+lbTime.frame.size.width-5, 0, viewWidth*0.3,50)];

//    UILabel *lbBg = [[UILabel alloc] initWithFrame:CGRectMake(5,49, viewWidth-10-5,1)];
//    lbBg.backgroundColor=kThemeBlueColor;
    [lbName applyUITheme:kThemeGreyValue(0.0)];
    [lbType applyUITheme:kThemeGreyValue(0.0)];
    [lbTime applyUITheme:kThemeGreyValue(0.0)];
    [lbCompany applyUITheme:kThemeGreyValue(0.0)];
    
    lbName.text=@"Name";
    lbType.text=@"Type";
    lbTime.text=@"Time In";
    lbCompany.text=@"Company ";
    
    lbType.textAlignment = NSTextAlignmentCenter;
    lbTime.textAlignment = NSTextAlignmentCenter;
    lbCompany.textAlignment = NSTextAlignmentRight;
    
    
    [lbName applyUITheme:kThemeGreyValue(255.0)];
    [lbType applyUITheme:kThemeGreyValue(255.0)];
    [lbTime applyUITheme:kThemeGreyValue(255.0)];
    [lbCompany applyUITheme:kThemeGreyValue(255.0)];
    
    lbName.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    lbType.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    lbTime.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    lbCompany.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    
    [view addSubview:lbName];
    [view addSubview:lbType];
    [view addSubview:lbTime];
    [view addSubview:lbCompany];

//    [view addSubview:lbBg];
    
    [view setBackgroundColor:kThemeBGGrey];

    view.layer.cornerRadius=3.0;
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
  
    
    UILabel *lbFirstName= (UILabel *) [cell.contentView viewWithTag:1001];
    UILabel *lbType= (UILabel *) [cell.contentView viewWithTag:1002];
    UILabel *signInTime= (UILabel *) [cell.contentView viewWithTag:1003];
    UILabel *organisation= (UILabel *) [cell.contentView viewWithTag:1004];
    
    int viewWidth=tableView.frame.size.width;
    lbFirstName.frame=CGRectMake(5,0, viewWidth*0.3-5,50);
    lbType.frame=CGRectMake(lbFirstName.frame.origin.x+lbFirstName.frame.size.width,0, viewWidth*0.2,50);
    signInTime.frame=CGRectMake(lbType.frame.origin.x+lbType.frame.size.width,0, viewWidth*0.2,50);
    organisation.frame=CGRectMake(signInTime.frame.origin.x+signInTime.frame.size.width, 0, viewWidth*0.3-5,50);
    
    [lbFirstName applyUITheme:kThemeGreyValue(255.0)];
    [lbType applyUITheme:kThemeGreyValue(255.0)];
    [signInTime applyUITheme:kThemeGreyValue(255.0)];
    [organisation applyUITheme:kThemeGreyValue(255.0)];
    
    signInTime.textAlignment = NSTextAlignmentCenter;
    organisation.textAlignment = NSTextAlignmentRight;
    
    lbFirstName.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    lbType.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    signInTime.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    organisation.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
    
    lbType.text = [[_siteArray objectAtIndex:indexPath.row] valueForKey:@"type"];
    lbFirstName.text = [NSString stringWithFormat:@"%@ %@",[[_siteArray objectAtIndex:indexPath.row] valueForKey:@"firstName"],[[_siteArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]];
    signInTime.text = [[_siteArray objectAtIndex:indexPath.row] valueForKey:@"signInTime"];
    organisation.text = [[_siteArray objectAtIndex:indexPath.row] valueForKey:@"organisation"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    UserDetailsVC *userDetailsVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserDetailsVC"];
    userDetailsVC.visitorDetails = [_siteArray objectAtIndex:indexPath.row];
    [userDetailsVC.visitorDetails setObject:@"0" forKey:KEY_FROM_SEARCH];
    [self.navigationController pushViewController:userDetailsVC animated:YES];
    
}
@end
