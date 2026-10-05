//
//  VerifyContractorVC.h
//  LinkSafe
//
//  Created by uday on 05/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyContractorVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *arrItems;
}
@property (weak, nonatomic) IBOutlet UIButton *btnSignInAsException;
@property (weak, nonatomic) IBOutlet UIButton *btnDeclineEntry;
- (IBAction)onDeclineEntry:(id)sender;
- (IBAction)onSignInAsException:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
- (IBAction)onHome:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPin;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblReasons;

@property (weak, nonatomic) IBOutlet UITableView *tblItems;
@property (strong,nonatomic) NSMutableDictionary *dicInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblRedTitle;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpScroll;

@property (weak, nonatomic) IBOutlet UIView *uiContainView;
@property (weak, nonatomic) IBOutlet UITextField *tfAuthorizedBy;
@property (weak, nonatomic) IBOutlet UITextField *tfNotes;

@property (retain, nonatomic) NSString *navTitle;

@end
