//
//  ContractorSignOutMobile.h
//  LinkSafe
//
//  Created by hitesh gs on 23/05/22.
//  Copyright © 2022 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractorSignOutMobile : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate>
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
@property (weak, nonatomic) IBOutlet UIView *vwPhoneBG;
@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgCountryFlag;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCountry;

@property (retain, nonatomic) NSString *navTitle;


@end

NS_ASSUME_NONNULL_END
