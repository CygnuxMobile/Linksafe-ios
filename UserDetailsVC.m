//
//  UserDetailsVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "MeetingWithVC.h"
#import "UserRegistrationVC.h"
#import "UserDetailsVC.h"
#import "TakePhotoVC.h"
#import "UIView+Additions.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"
#import "AsyncImageView.h"

#define cellHight 40

@interface UserDetailsVC () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *userDetail;
    UIView *tableBG;
    BOOL isFromSearch;
    BOOL isShowReprint;
}
@end

@implementation UserDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"User Detail" parameters:@{@"onload": @"49"}];
    _lbWelcome.textColor = kGetHomeLabelColor;
    [_btnCancel applyGrayTheme];
    [_btnUpdateDetails applyBlueShedow];
    [_btnContinue applyBlueShedow];
    userDetail=[[NSMutableArray alloc] init];
    tableBG=[self.view viewWithTag:5501];
    tableBG.backgroundColor=kThemeBGGrey;
    [Common ApplyUIViewTheme:tableBG];
    _userPic.layer.cornerRadius=3.0;
    _userPic.clipsToBounds=YES;
    isFromSearch=[[_visitorDetails valueForKey:KEY_FROM_SEARCH] boolValue];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    if(isFromSearch)
    {
        [_btnCancel setHidden:NO];
        [_btnUpdateDetails setHidden:NO];
        [_btnContinue setTitle:@"CONTINUE" forState:UIControlStateNormal];
        [_btnContinue setImage: nil forState:UIControlStateNormal];
        
        [self.view viewWithTag:3301].hidden=YES;
        
        if ([Common appDelegate].isIpad)
        {
            CGRect viewRect=tableBG.frame;
            viewRect.origin.y=80;
            tableBG.frame=viewRect;
            
            CGRect imgRect=_userPic.frame;
            imgRect.origin.y=80;
            _userPic.frame=imgRect;
            
            CGRect lbRect=_lbWelcome.frame;
            lbRect.origin.y=20;
            _lbWelcome.frame=lbRect;
            
            //100//160
        }
    }
    else
    {
        if ([Common appDelegate].isIpad)
        {
            CGRect viewRect=tableBG.frame;
            viewRect.origin.y=160;
            tableBG.frame=viewRect;
            
            CGRect imgRect=_userPic.frame;
            imgRect.origin.y=160;
            _userPic.frame=imgRect;
            
            CGRect lbRect=_lbWelcome.frame;
            lbRect.origin.y=100;
            _lbWelcome.frame=lbRect;
        }
        [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
        [_btnUpdateDetails setHidden:YES];
        [_btnCancel setHidden:YES];
        
        [_btnContinue setImage: [UIImage imageNamed:([Common appDelegate].isIpad?@"call":@"smallcall")] forState:UIControlStateNormal];
        [_btnContinue.imageView setTintColor:[UIColor whiteColor]];
        [_btnContinue setTintColor:[UIColor whiteColor]];
        if ([_visitorDetails valueForKey:KEY_REGISTERATION_ID])
        {
            [self getRegisterUserDeail];
        }
    }
    [self genrateArray:_visitorDetails];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (isFromSearch)
    {
        self.navigationItem.title=self.navTitle;//@"VISITOR DETAIL";
    }
    else
    {
        self.navigationItem.title=@"SITE REGISTER";
    }
    
    [self upadteTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
    //    UILabel *lableTime=[mainVCView viewWithTag:5214];
    //    if (lableTime) {
    //        [lableTime setTextColor:kGetHomeLabelColor];
    //    }
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (void)genrateArray:(NSDictionary *)userDic
{
    [userDetail removeAllObjects];
    [self getKeyValueDic:userDic andKey:@"title" needKey:@"Title:"];
    [self getKeyValueDic:userDic andKey:@"firstName" needKey:@"First Name:"];
    [self getKeyValueDic:userDic andKey:@"lastName" needKey:@"Last Name:"];
    [self getKeyValueDic:userDic andKey:@"organisation" needKey:@"Company:"];
    [self getKeyValueDic:userDic andKey:@"workLocation" needKey:@"Work Location:"];
    [self getKeyValueDic:userDic andKey:@"phone" needKey:@"Phone:"];
    [self getKeyValueDic:userDic andKey:@"signInTime" needKey:@"Signed In at:"];
    
    if (![[_visitorDetails valueForKey:@"type"] isEqualToString:@"Contractor"])
    {
        [self getKeyValueDic:userDic andKey:@"vehicleRegistrationNumber" needKey:@"Vehicle:"];
        [self getKeyValueDic:userDic andKey:@"siteContact" needKey:@"Meeting With:"];
    }
    if (isFromSearch)
    {
        _lbWelcome.text=[NSString stringWithFormat:@"Welcome back %@ %@",[userDic valueForKey:@"firstName"],[userDic valueForKey:@"lastName"]];
        
        _lbWelcome.textAlignment =  ([Common appDelegate].isIpad?NSTextAlignmentLeft:NSTextAlignmentCenter);
    }
    else
    {
        _lbWelcome.textAlignment = NSTextAlignmentCenter;
        
        if ([[_visitorDetails valueForKey:@"type"] isEqualToString:@"Contractor"])
        {
            _lbWelcome.text=@"Contractor Details";
        }
        else
        {
            _lbWelcome.text=@"Visitor Details";
        }
        if ([userDic objectForKey:@"phone"]>0)
        {
            _btnContinue.hidden=NO;
            [_btnContinue setTitle:[userDic objectForKey:@"phone"] forState:UIControlStateNormal];
        }
        else
        {
            _btnContinue.hidden=YES;
        }
    }
    [_siteListview reloadData];
    [_siteListview performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    int tblHight=(int)userDetail.count*cellHight + (isShowReprint ? (([Common appDelegate].isIpad) ? 80 : 60) : 0);
    CGRect frameRect=tableBG.frame;
    int rh=(self.view.frame.size.height-frameRect.origin.y-cellHight-20);
    if (rh>tblHight || ![Common appDelegate].isIpad)
    {
        frameRect.size.height=tblHight+20;
        _siteListview.scrollEnabled = NO;
    }
    else
    {
        _siteListview.scrollEnabled = YES;
        frameRect.size.height=(self.view.frame.size.height-frameRect.origin.y-50);
    }
    tableBG.frame=frameRect;
    
    if (![Common appDelegate].isIpad)
    {
        int neededHight=650+tblHight+20;
        
        if (!isFromSearch)
        {
            neededHight=neededHight-120;
        }
        
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height>neededHight?self.view.frame.size.height:neededHight));
        self.scroll.contentSize = CGSizeMake(self.view.frame.size.width,neededHight);
        
        CGRect bvf=_btnView.frame;
        bvf.origin.y=440+tblHight+20;
        _btnView.frame=bvf;
    }
    else {
        int neededHight=360+tblHight+20;
        if (!isFromSearch)
        {
            neededHight=neededHight-100;
        }
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height>neededHight?self.view.frame.size.height:neededHight));
        self.scroll.contentSize = CGSizeMake(self.view.frame.size.width,neededHight);
    }
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
}

-(void)getKeyValueDic:(NSDictionary *)sourceDic andKey:(NSString *)key needKey:(NSString *)displayKey
{
    if ([sourceDic valueForKey:key])
    {
        if ([[NSString stringWithFormat:@"%@",[sourceDic valueForKey:key]] length]>0)
        {
            [userDetail addObject:[[NSDictionary alloc] initWithObjectsAndKeys:displayKey,@"title",[sourceDic valueForKey:key],@"value", nil]];
        }
    }
}

#pragma mark - Table View Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userDetail count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    UILabel *lbTitle= (UILabel *) [cell.contentView viewWithTag:1001];
    UILabel *lbValue= (UILabel *) [cell.contentView viewWithTag:1002];
    int viewWidth=tableView.frame.size.width;
    
    lbTitle.frame=CGRectMake(20,0, viewWidth*0.5-20,cellHight);
    lbValue.frame=CGRectMake(lbTitle.frame.origin.x+lbTitle.frame.size.width,0, viewWidth*0.5,cellHight);
    
    [lbTitle applyUITheme:kThemeGreyValue(255.0)];
    [lbValue applyUITheme:kThemeGreyValue(255.0)];
    
    [lbTitle setFont:kThemeRegularFonts(14.0)];
    [lbValue setFont:kThemeRegularFonts(12.0)];
    
    
    lbTitle.text = [[userDetail objectAtIndex:indexPath.row] valueForKey:@"title"];
    lbValue.text = [[userDetail objectAtIndex:indexPath.row] valueForKey:@"value"];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (isShowReprint)
        return ([Common appDelegate].isIpad) ? 80 : 60;
    else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isShowReprint) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, ([Common appDelegate].isIpad) ? 80 : 60)];
        view.backgroundColor = [UIColor clearColor];
        UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.5)];
        viewTop.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:viewTop];
        UIView *viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, ([Common appDelegate].isIpad) ? 79.5 : 59.5, tableView.frame.size.width, 0.5)];
        viewBottom.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:viewBottom];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, view.frame.size.width, ([Common appDelegate].isIpad) ? 60 : 40)];
        [button setTitle:[@"Reprint Sticker" uppercaseString] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickReprint:) forControlEvents:UIControlEventTouchUpInside];
        [button applyBlueShedow];
        [view addSubview:button];
        
        return view;
    }
    else
    {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

-(void)didClickReprint:(UIButton *)sender
{
    NSLog(@"Clicked Reprint Sticker");
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setObject:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:KEY_REGISTERATION_ID]] intValue]] forKey:KEY_REGISTERATION_ID];
    [Common callAPI:dicParameters Request:API_GET_STICKER_BITMAPS ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            [self onPrint:responseObject isFrom:@"0"];
        }
    }];
}

- (void)onPrint:(NSMutableDictionary *)responceDic isFrom:(NSString *)isFrom
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel    *_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=responceDic;
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];
    printResultViewController.navTitle = self.navTitle;
    printResultViewController.isReprint = YES;
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


- (IBAction)onUpdateDetails:(id)sender
{
    UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
    vc.isUpdate=YES;
    vc.visitorDetails = _visitorDetails;
    vc.navTitle = self.navTitle;
    vc.didFinishwithVisitorDetail = ^(NSMutableDictionary *updaedVisitorDetails)
    {
        self.visitorDetails=updaedVisitorDetails;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onContinue:(id)sender {
    if (isFromSearch)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:_btnContinue.titleLabel.text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getRegisterUserDeail {
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    
    [dicParameters setObject:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [_visitorDetails valueForKey:KEY_REGISTERATION_ID]] intValue]] forKey:KEY_REGISTERATION_ID];
    
    [Common callAPI:dicParameters Request:REQUEST_GET_REGISTRATION_DETAILS ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            self->isShowReprint = [[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"isReprintStickerButtonVisible"]] boolValue];
            [self genrateArray:responseObject];
            if ([responseObject objectForKey:@"photoUri"])
            {
                self->_userPic.image=[Common decodeBase64ToImage:[responseObject objectForKey:@"photoUri"]];
            }
        }
        else
        {
            NSString *errorMsg = [NSString stringWithFormat:@"%@", [responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

@end
