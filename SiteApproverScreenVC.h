//
//  SiteApproverScreenVC.h
//  LinkSafe
//
//  Created by Kiran on 3/25/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TESignatureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SiteApproverScreenVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet UILabel *lblApproverName;
@property (weak, nonatomic) IBOutlet UITextField *txtApproverName;

@property (weak, nonatomic) IBOutlet UIButton *btnSignHere;
@property (weak, nonatomic) IBOutlet UILabel *lblSignatureName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSignature;

@property (weak, nonatomic) IBOutlet UIView *viewSignatureContainer;
@property (weak, nonatomic) IBOutlet TESignatureView *signtureView;
@property (weak, nonatomic) IBOutlet UIButton *signDone;
@property (weak, nonatomic) IBOutlet UIButton *signCancel;

@property (nonatomic, strong) NSMutableDictionary *visitorDetails;
@property (retain, nonatomic) NSString *navTitle;

@property (nonatomic, assign) BOOL isContractor;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpScroll;
@property (weak, nonatomic) IBOutlet UIView *uiContainView;

@end

NS_ASSUME_NONNULL_END
