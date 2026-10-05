//
//  ContractorJobSelectionVC.h
//  LinkSafe
//
//  Created by kartik on 7/19/17.
//  Copyright © 2017 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorJobSelectionVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UITableView *siteListview;
@property (weak, nonatomic) IBOutlet UILabel *noData;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property(nonatomic, strong) NSArray *siteArray;
@property(nonatomic, strong) NSString *sitePassword;

@property (strong,nonatomic) NSMutableDictionary *ContractorDetail;
@property (strong,nonatomic) NSMutableDictionary *responseDictionary;

@property (strong,nonatomic) NSMutableDictionary *dicSelectedJob;

@property(nonatomic,copy)callbackwithDic didFinishWithJobSelection;

@property (retain, nonatomic) NSString *navTitle;

@end
