//
//  LoginViewController.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h"
#import "JJMaterialTextfield.h"


@interface LoginVC : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scroll;
@property (strong, nonatomic) IBOutlet UITextField *tfPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UITextField *tfFullName;
@property (weak, nonatomic) IBOutlet UIView *rememberMe;

@end
