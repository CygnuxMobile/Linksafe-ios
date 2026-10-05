//
//  SighnUpViewController.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h"
#import "JJMaterialTextfield.h"

@interface SignUpVC : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSMutableArray *arrCity;
    NSString *strCity;
}
@property (weak, nonatomic) IBOutlet UIView *vwTermsAndConditions;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerCity;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scroll;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfUserName;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfFullName;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfPhone;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfBD;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfEmail;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfPassword;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *tfCity;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnTerms;
@property (weak, nonatomic) IBOutlet UIButton *btnPromotions;

@end
