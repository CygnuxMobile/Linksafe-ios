//
//  ContractorWorkDetailVC.h
//  LinkSafe
//
//  Created by uday on 06/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASJTagsView.h"


@interface ContractorWorkDetailVC : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;
//@property (weak, nonatomic) IBOutlet UILabel *lbPermit;
@property (weak, nonatomic) IBOutlet UITextField *txtPermit;
@property (weak, nonatomic) IBOutlet UITextField *tfContractorName;
@property (weak, nonatomic) IBOutlet UITextField *tfContractorCompany;
@property (weak, nonatomic) IBOutlet UITextField *tfContractorNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfDateOfWork;
@property (weak, nonatomic) IBOutlet UITextField *tfAdditionalContractor;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UITextField *tfDescriptionOfWork;
@property (weak, nonatomic) IBOutlet UITextField *tfEquipmentToBeUsed;
@property (weak, nonatomic) IBOutlet ASJTagsView *tfAttechRiskAssessment;
@property (weak, nonatomic) IBOutlet ASJTagsView *tfAttechSWMS;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAttechRiskAssesment;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAttechSWMS;
- (IBAction)onAddAttechRisk:(id)sender;
- (IBAction)onAddAttechSWMS:(id)sender;
@property(nonatomic,copy) callbackwithDic  didFinishwithWorkDetail;
@property(nonatomic, strong) NSMutableDictionary *workDetailsDic;
@property(nonatomic, strong) NSString *workPermitFormID;

@property (retain, nonatomic) NSString *navTitle;

@end
