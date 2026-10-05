//
//  Aceess.h
//  LinkSafe
//
//  Created by uday on 17/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Aceess : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *acessImage;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSignOutSuccess;
@property (weak, nonatomic) IBOutlet UITableView *tblItems;
@property (weak, nonatomic) IBOutlet UITableView *tblCredential;
@property (weak, nonatomic) IBOutlet UILabel *lblcontractordetail;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPin;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UIView *contracotInfoView;
@property (weak, nonatomic) IBOutlet UIView *viewCredentials;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *tpScroll;
@property (weak, nonatomic) IBOutlet UIView *uiContainView;
@property (retain, nonatomic) NSString *navTitle;
@property (strong,nonatomic) NSMutableDictionary *contractorInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblSignedInTime;
@property (weak, nonatomic) IBOutlet UIView *viewLblSignedIn;

@property (weak, nonatomic) IBOutlet UILabel *lblActiveWorkers;
@property (weak, nonatomic) IBOutlet UIView *viewActiveWorkers;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblCredentialsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblItemsHeight;


@property(nonatomic) BOOL isSpotUser;

@end
