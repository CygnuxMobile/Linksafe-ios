//
//  TakePhotoVC.h
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TESignatureView.h"

@interface TakePhotoVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)onTackPhoto:(id)sender;
- (IBAction)onSignHere:(id)sender;
- (IBAction)onContinue:(id)sender;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpscrollview;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *imgSignatureView;

@property (weak, nonatomic) IBOutlet TESignatureView *signtureView;
@property (weak, nonatomic) IBOutlet UIView *baseSigntureView;

@property (weak, nonatomic) IBOutlet UIButton *signHere;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;

@property (weak, nonatomic) IBOutlet UIButton *signin;

@property (weak, nonatomic) IBOutlet UILabel *photoInstruction;
@property (weak, nonatomic) IBOutlet UILabel *signInstruction;

@property (weak, nonatomic) IBOutlet UIButton *signDone;
@property (weak, nonatomic) IBOutlet UIButton *signCancel;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property(nonatomic, strong) NSMutableDictionary *visitorDetails;

@property(nonatomic, assign) BOOL isForImageData;
@property(nonatomic,copy)callbackwithDic  didFinishwithImageData;

@property (retain, nonatomic) NSString *navTitle;

@property(nonatomic, assign) BOOL isContractor;
//@property(nonatomic, assign) BOOL isVisitor;

@end
