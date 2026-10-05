//
//  UserDetailsVC.h
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailsVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@property (weak, nonatomic) IBOutlet UILabel *lbWelcome;

@property (weak, nonatomic) IBOutlet UIView *btnView;

@property (weak, nonatomic) IBOutlet UITableView *siteListview;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scroll;

- (IBAction)onUpdateDetails:(id)sender;
- (IBAction)onContinue:(id)sender;
- (IBAction)onCancel:(id)sender;

@property(nonatomic, strong) NSMutableDictionary *visitorDetails;
@property (retain, nonatomic) NSString *navTitle;

@end
