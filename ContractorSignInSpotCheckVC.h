//
//  ContractorSignInSpotCheckVC.h
//  LinkSafe
//
//  Created by Maulikkumar Desai on 25/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractorSignInSpotCheckVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnScanQRCode;
@property (weak, nonatomic) IBOutlet UITextField *tfEnterPIN;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UILabel *lblOrSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnValidate;
@property (weak, nonatomic) IBOutlet UIView *viewCompanies;
@property (weak, nonatomic) IBOutlet UITableView *tblCompanies;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpScroll;
@property (weak, nonatomic) IBOutlet UIView *uiContainView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property(nonatomic) BOOL isSpotUser;

- (IBAction)onValidate:(id)sender;
- (IBAction)onScanQRCode:(id)sender;

@property (retain, nonatomic) NSString *navTitle;

- (IBAction)onSiteSelectClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblSiteName;
@property (weak, nonatomic) IBOutlet UIView *ViewSiteSelection;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectSites;
@end

NS_ASSUME_NONNULL_END
