//
//  ExceptionVC.h
//  LinkSafe
//
//  Created by uday on 06/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "HSDatePickerViewController.h"

@interface ExceptionVC : UIViewController//<HSDatePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic)  NSString *workPermitFormID;
@property (weak, nonatomic)  NSString *workPermitTypeID;
@property (weak, nonatomic)  NSString *titlemassage;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)onCancelClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *uiTableException;

@property (weak, nonatomic) IBOutlet UITextView *passwordIntructView;

@property (weak, nonatomic) IBOutlet UILabel *lbTitleMsg;

@property (weak, nonatomic) IBOutlet UIButton *btnDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lbDateTimePlaceholder;
@property (weak, nonatomic) IBOutlet UIView *viewdatepasscontainer;

@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
- (IBAction)onContinueClick:(id)sender;
@property(nonatomic,copy)callbackwithDic  didFinishwithExceptionDetail;

@property (retain, nonatomic) NSString *navTitle;

@end
