//
//  ContractorLocationSelectionVC.h
//  LinkSafe
//
//  Created by kartik on 01/12/17.
//  Copyright © 2017 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorLocationSelectionVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextView *tvLocationDetails;

@property (strong,nonatomic) NSMutableDictionary *ContractorDetail;

@property(nonatomic,copy)callbackwithDic didFinishWithJobLocation;

@property (retain, nonatomic) NSString *navTitle;

@end
