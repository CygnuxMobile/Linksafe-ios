//
//  SiteDetails.h
//  LinkSafe
//
//  Created by Wish on 26/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiteDetails : UIViewController

@property(nonatomic, strong) NSDictionary *siteDic;



@property (weak, nonatomic) IBOutlet UIView *bgContainView;
@property (weak, nonatomic) IBOutlet UIScrollView *uiScroll;

@property (weak, nonatomic) IBOutlet UILabel *lbFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbLastName;
@property (weak, nonatomic) IBOutlet UILabel *lbCompany;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *vehicle;
@property (weak, nonatomic) IBOutlet UILabel *lbSignIn;
@property (weak, nonatomic) IBOutlet UILabel *lbMeeting;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
- (IBAction)onCallClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgSiteLogo;
@property (weak, nonatomic) IBOutlet UIImageView *siteLogo;

@end

