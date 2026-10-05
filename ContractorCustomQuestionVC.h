//
//  ContractorCustomQuestionVC.h
//  LinkSafe
//
//  Created by Kiran on 3/24/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContractorCustomQuestionVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextView *tvAnswerDetails;

@property (strong,nonatomic) NSMutableDictionary *ContractorDetail;

@property(nonatomic,copy)callbackwithDic didFinishWithCustomQuestion;

@property (retain, nonatomic) NSString *navTitle;

@end

NS_ASSUME_NONNULL_END
