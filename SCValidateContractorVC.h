//
//  SCValidateContractorVC.h
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCValidateContractorVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containtView;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgTakePhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileNo;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;
@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UIImageView *imgDropdown;
@property (weak, nonatomic) IBOutlet UIButton *btnValidate;

@property (retain, nonatomic) NSMutableDictionary *userDetails;
@property (retain, nonatomic) NSString *strSelectedSiteId;

+(SCValidateContractorVC *)viewController;

@end
