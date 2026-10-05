//
//  VisitorSignOutMultiUserStepTwo.h
//  LinkSafe
//
//  Created by uday on 14/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitorSignOutMultiUserStepTwo : UIViewController<UIImagePickerControllerDelegate , UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
- (IBAction)onCancelBtnClick:(id)sender;
- (IBAction)onSignOutBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property(nonatomic, strong) NSMutableDictionary *visitorDetails;
- (IBAction)onTakePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbMobileNo;
@property (weak, nonatomic) IBOutlet UILabel *lbFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lbVehicle;
@property (weak, nonatomic) IBOutlet UILabel *lbLastName;
@property (weak, nonatomic) IBOutlet UILabel *lbCompany;

@property (weak, nonatomic) IBOutlet UIScrollView *uiScrollview;
@property (weak, nonatomic) IBOutlet UIView *uiContaintView;

@property (retain, nonatomic) NSString *navTitle;

@end
