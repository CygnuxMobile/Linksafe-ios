//
//  SiteDetails.m
//  LinkSafe
//
//  Created by Wish on 26/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "SiteDetails.h"

@interface SiteDetails ()

@end

@implementation SiteDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Site Detail" parameters:@{@"onload": @"35"}];
    NSLog(@"data is -> %@" , _siteDic);
    
    self.bgContainView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    
    // Get the Layer of any view
    CALayer * l = [_imgSiteLogo layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:49.0];
    
    _lbTitle.text =[_siteDic valueForKey:@"firstName"];
     _lbFirstName.text =[_siteDic valueForKey:@"firstName"];
     _lbLastName.text =[_siteDic valueForKey:@"firstName"];
     _lbCompany.text =[_siteDic valueForKey:@"firstName"];
     _lbPhone.text =[_siteDic valueForKey:@"firstName"];
     _vehicle.text =[_siteDic valueForKey:@"firstName"];
     _lbSignIn.text =[_siteDic valueForKey:@"firstName"];
     _lbMeeting.text =[_siteDic valueForKey:@"firstName"];
     [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.uiScroll.contentSize = CGSizeMake(self.view.frame.size.width-10,620);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onCallClick:(id)sender {
}
@end
