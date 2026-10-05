//
//  SignOutVC.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 28/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "SignOutVC.h"
#import "ScannerViewController.h"
#import "ContractorSignOut.h"
#import "VisitorSignOut.h"
#import "UIButton+Additions.h"
#import "AsyncImageView.h"
#import "MessageBoardVC.h"

@interface SignOutVC ()
{
    NSString *isContactor;
    
    NSMutableArray *arrMessages;
    NSMutableDictionary *messageBoardParameters;
    BOOL isContractor;
}

@end

@implementation SignOutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Sign Out" parameters:@{@"onload": @"34"}];
    [_btnVisitor applyBlueShedow];
    [_btnContractor applyGrayTheme];
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    SiteConfig *config = [Common appDelegate].config;
    [_btnVisitor setTitle:[[NSString stringWithFormat:@"%@",config.visitorsButtonText] uppercaseString] forState:UIControlStateNormal];
    [_btnContractor setTitle:[[NSString stringWithFormat:@"%@",config.contractorsButtonText] uppercaseString] forState:UIControlStateNormal];
   
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common setBgImage:self.view useDefault:YES];
    [self upadteTime];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=@"SIGN OUT";
    
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

- (IBAction)onContractorButtonClick:(id)sender
{
    isContractor = YES;
    [self getSignInSignOutMessageBoard:@"Contractor" andEvent:@"SignOut"];
}

- (IBAction)onVisitorButtonClick:(id)sender
{
    isContractor = NO;
    [self getSignInSignOutMessageBoard:@"Visitor" andEvent:@"SignOut"];
}

-(void)getSignInSignOutMessageBoard:(NSString *)registrationType andEvent:(NSString *)eventType
{
    /*
     {
         "Token":
         "D0F894C8CDC3FF917FDB7943A437FA49E26DFF7D7D5CB11D5FCED43170CE40248544F8DF82569B0BAD87B
         FF7DCB38CE1A4E3C65C9705D48D2B59BA33CA1D65C4",
         "RegistrationType": "Contractor" / "Visitor",
         "EventType": "SignIn" / "SignOut"
     }
     */
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:registrationType forKey:KEY_REGISTRATION_TYPE];
    [parameters setObject:eventType forKey:KEY_EVENT_TYPE];
    messageBoardParameters = parameters;
    [Common callAPI:parameters Request:REQUEST_GET_MESSAGE_BOARDS ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
         if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
         {
             arrMessages = [[responseObject objectForKey:@"messages"] mutableCopy];
             [self showMessagBoard];
         }
         else
         {
             NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
             [Common showAlert:errorMsg : @""];
         }
     }];
}

-(void)showMessagBoard
{
    if (arrMessages.count == 0)
    {
        if(isContractor)
        {
            ContractorSignOut *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignOut"];
            vc.navTitle = self.strContractor;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            VisitorSignOut *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOut"];
            vc.navTitle = self.strVisitor;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
    {
        MessageBoardVC *next = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"MessageBoardVC"];
        next.arrMessages = arrMessages;
        next.didFinishAcknowledge = ^(NSMutableDictionary *response){
            
            if ([[response objectForKey:@"isFinished"] isEqualToString:@"yes"])
            {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                [self->arrMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [result addObject:obj[@"id"]];
                }];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:result forKey:KEY_MESSAGE_BOARDS];
                [userDefaults synchronize];
                
                [self->arrMessages removeAllObjects];
                [self showMessagBoard];
            }
            else
            {
                //Hide Message board
                //don't do anything
            }
        };
        next.view.backgroundColor = [UIColor clearColor];
        next.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:next animated:YES completion:^{}];
    }
}

/*
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index : %ld", buttonIndex);
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
    {
        return;
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Acknowledge"])
    {
        [arrMessages removeObjectAtIndex:0];
        [self showMessagBoard];
    }
}
*/

@end
