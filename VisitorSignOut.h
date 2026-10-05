//
//  VisitorSignOut.h
//  LinkSafe
//
//  Created by uday on 13/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitorSignOut : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeybord;
@property (weak, nonatomic) IBOutlet UIView *containtView;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelOr;
@property (weak, nonatomic) IBOutlet UILabel *labelOr2;

@property (weak, nonatomic) IBOutlet UIButton *btnScanQrCode;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (retain, nonatomic) NSString *navTitle;

- (IBAction)onQRbtnClick:(id)sender;
- (IBAction)onSearchBtnClick:(id)sender;
- (IBAction)onCancelBtnClick:(id)sender;

@end
