//
//  VisitorSignInStepTwoVC.h
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface UserLogin : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNo;

@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnNewUser;

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *orLable;

- (IBAction)onCancel:(id)sender;
- (IBAction)onSearch:(id)sender;
- (IBAction)onNewUser:(id)sender;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) NSString *navTitle;


@end
