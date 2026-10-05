//
//  HomeVC.h
//  LinkSafe
//
//  Created by Hitesh Gs on 09/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeVC : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *siteName;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblWarning;
@property (weak, nonatomic) IBOutlet UILabel *lblPowerBy;

@property (strong, nonatomic) IBOutlet UIButton *btnContractor;
@property (strong, nonatomic) IBOutlet UIButton *btnVisitor;
@property (strong, nonatomic) IBOutlet UIButton *btnSIgnOut;


- (IBAction)onContactor:(id)sender;
- (IBAction)onVisitor:(id)sender;
- (IBAction)onSignOut:(id)sender;
- (IBAction)onSideMenuClick:(id)sender;


@end
