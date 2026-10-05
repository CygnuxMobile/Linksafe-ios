//
//  ContractorPermissions.h
//  LinkSafe
//
//  Created by uday on 05/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractorPermissions : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)onContinue:(id)sender;
- (IBAction)onCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *ContractorPermissionTableView;
@property (strong,nonatomic) NSMutableDictionary *ContractorDetail;

@property(nonatomic,copy) callbackwithDic  didFinishwithWorkPermission;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpKeyBoard;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) NSString *navTitle;

@end
