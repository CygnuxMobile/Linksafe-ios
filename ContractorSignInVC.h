//
//  ContractorSignInVC.h
//  LinkSafe
//
//  Created by uday on 05/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorSignInVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *vwPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnScanQRCode;
@property (weak, nonatomic) IBOutlet UITextField *tfEnterPIN;
@property (weak, nonatomic) IBOutlet UIView *viewPhoneOr;
@property (weak, nonatomic) IBOutlet UITextField *tfEnterTemperature;
@property (weak, nonatomic) IBOutlet UIView *viewPhoneNo;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNo;
@property (weak, nonatomic) IBOutlet UIView *viewTemperature;
@property (weak, nonatomic) IBOutlet UILabel *orLable;
@property (weak, nonatomic) IBOutlet UIButton *btnValidate;
@property (weak, nonatomic) IBOutlet UIView *viewCompanies;
@property (weak, nonatomic) IBOutlet UITableView *tblCompanies;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpScroll;
@property (weak, nonatomic) IBOutlet UIView *uiContainView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *vwPhoneBG;
@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgCountryFlag;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCountry;

@property(nonatomic) BOOL isSpotUser;

- (IBAction)onValidate:(id)sender;
- (IBAction)onScanQRCode:(id)sender;

@property (retain, nonatomic) NSString *navTitle;

@end
