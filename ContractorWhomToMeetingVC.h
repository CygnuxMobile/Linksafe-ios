//
//  ContractorWhomToMeetingVC.h
//  LinkSafe
//
//  Created by Kiran on 23/08/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorWhomToMeetingVC : UIViewController

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpscrollview;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *siteListview;
@property (weak, nonatomic) IBOutlet UILabel *noData;
@property (weak, nonatomic) IBOutlet UILabel *lblHeading;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (strong,nonatomic) NSMutableDictionary *ContractorDetail;
@property (strong,nonatomic) NSMutableDictionary *responseDictionary;

@property (strong,nonatomic) NSMutableDictionary *dicSelectedJob;

@property(nonatomic,copy)callbackwithDic didFinishWithContactSelection;

@property (retain, nonatomic) NSString *navTitle;

@end
