//
//  ContractorSignOutStepTwo.h
//  LinkSafe
//
//  Created by uday on 13/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "SignOutDocumentsVC.h"

@interface ContractorSignOutStepTwo : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfEnterPin;
- (IBAction)onLogout:(id)sender;

- (IBAction)onProfileBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;

@property (weak, nonatomic) IBOutlet UIImageView *imgPic;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)onCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;

@property (weak, nonatomic) IBOutlet UIScrollView *uiScrollview;
@property (weak, nonatomic) IBOutlet UIView *uiContaintView;

@property (retain, nonatomic) NSString *navTitle;

@end
