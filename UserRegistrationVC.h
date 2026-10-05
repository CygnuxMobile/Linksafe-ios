
#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface UserRegistrationVC : UIViewController <UIActionSheetDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbWelcomeMessage;
- (IBAction)onClickTitle:(id)sender;


- (IBAction)onCancel:(id)sender;
- (IBAction)onContinue:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property(nonatomic) Boolean isUpdate;

@property (weak, nonatomic) IBOutlet UIView *titleView;

@property(nonatomic) Boolean notFoundUser;

@property(nonatomic, strong) NSDictionary *visitorDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property(nonatomic,copy)callbackwithDic  didFinishwithVisitorDetail;

@property (retain, nonatomic) NSString *navTitle;

@end
