//
//  VisitorSignOutMultiUser.h
//  LinkSafe
//
//  Created by uday on 14/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitorSignOutMultiUser : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tbInfoList;
@property (weak, nonatomic) IBOutlet UITableView *tbUserDetail;

@property(nonatomic, strong) NSArray *visitorArray;

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnItsMe;
- (IBAction)onItsMeBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

- (IBAction)onCancel:(id)sender;

@property (retain, nonatomic) NSString *navTitle;

@end
