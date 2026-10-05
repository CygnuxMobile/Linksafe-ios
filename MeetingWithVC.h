//
//  VisitorSignInStepOneVC.h
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface MeetingWithVC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpscrollview;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnUserInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (nonatomic, strong) NSMutableDictionary *visitorDetails;
@property (retain, nonatomic) NSString *navTitle;

@property (nonatomic) BOOL isForPreregister;

@end
