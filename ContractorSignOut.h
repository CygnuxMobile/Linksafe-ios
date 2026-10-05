//
//  ContractorSignOut.h
//  LinkSafe
//
//  Created by uday on 13/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorSignOut : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeybord;
@property (weak, nonatomic) IBOutlet UIView *containtView;
@property (weak, nonatomic) IBOutlet UIButton *btnPIN;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (retain, nonatomic) NSString *navTitle;

- (IBAction)onPinClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnScanQrCode;

- (IBAction)onQrBtnClick:(id)sender;

@end
