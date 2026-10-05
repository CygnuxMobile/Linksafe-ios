//
//  ThankYouVC.m
//  LinkSafe
//
//  Created by uday on 17/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "ThankYouVC.h"
#import "UIButton+Additions.h"

@interface ThankYouVC ()
{
    NSTimer *timer;
    int waitSecond;
    NSString *successString;
}

@end

@implementation ThankYouVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Thank you" parameters:@{@"onload": @"47"}];
    self.navigationItem.hidesBackButton = YES;
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
     [Common setBgImage:self.view useDefault:YES];
    if ([[Common appDelegate] isIpad])
    {
        _btnSignOutSuccess.titleLabel.font = [UIFont systemFontOfSize:30.0];
    }
    else
    {
        _btnSignOutSuccess.titleLabel.font = [UIFont systemFontOfSize:14.0];
    }
    waitSecond=11;
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common applyThemeColorToPowerdBy:self.view];
    successString = @"Thanks for visiting, Have a good day!\n\nYou will redirect automatically in …";
    
    if (_resultDictionary!=nil)
    {
        if ([_resultDictionary valueForKey:@"signOutMessage"])
        {
            if ([[NSString stringWithFormat:@"%@",[_resultDictionary valueForKey:@"signOutMessage"]] length]>0)
            {
                successString = [NSString stringWithFormat:@"%@\n\nYou will redirect automatically in …",[_resultDictionary valueForKey:@"signOutMessage"]];
            }
        }
    }
    
    _lbInstruction.text=[NSString stringWithFormat:@"%@10 sec",successString];
    
     timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
     [_homeButton applyBlueShedow];
}
-(void)viewWillAppear:(BOOL)animated
{
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
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)timerCalled
{
    NSLog(@"Timer %d",waitSecond);
    waitSecond--;
    
    if (waitSecond<0)
    {
        [self closeMe:nil];
    }
    else
    {
        _lbInstruction.text=[NSString stringWithFormat:@"%@%d sec",successString,waitSecond];
        _lbInstruction.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
        _lbInstruction.numberOfLines=10;
        
        NSString *dataString=[NSString stringWithFormat:@"%@%d sec",successString,waitSecond];
        NSRange range = [dataString rangeOfString:[NSString stringWithFormat:@"%d",waitSecond]];
        UIFont *font = kThemeRegularFonts([Common appDelegate].isIpad?24:16);
        UIColor *fontColor = kGetThemeColor;
        NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:dataString];
        
        [dateAttributedString addAttribute:NSFontAttributeName
                                     value:fontColor
                                     range:range];
        [dateAttributedString addAttribute:NSFontAttributeName
                                     value:font
                                     range:range];
        _lbInstruction.attributedText=dateAttributedString;
        
        
    }
}
- (IBAction)closeMe:(id)sender
{
    [timer invalidate];
    timer = nil;
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


@end
