//
//  ContractorWorkFlowVC.h
//  LinkSafe
//
//  Created by Maulikkumar Desai on 16/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContractorWorkFlowTVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContractorWorkFlowVC : UIViewController<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate>

@property (retain, nonatomic) NSString *navTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)onNextClicked:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tblVisitorBehaviour;

@property (weak, nonatomic) IBOutlet UITextView *txtOtherWork;

@property (weak, nonatomic) IBOutlet UILabel *lblOtherWork;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property(nonatomic, strong) NSString *registrationType;
@property(nonatomic, strong) NSString *eventType;
@property(nonatomic, strong) NSString *btnTitleType;

@end

NS_ASSUME_NONNULL_END
