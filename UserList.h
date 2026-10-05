//
//  YourInformationVC.h
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserList : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tbInfoList;
@property (weak, nonatomic) IBOutlet UITableView *tbUserDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnNewVIsitor;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnContiue;
@property (weak, nonatomic) IBOutlet UIImageView *userPic;

@property(nonatomic, strong) NSArray *visitorArray;
@property (retain, nonatomic) NSString *navTitle;

@end
