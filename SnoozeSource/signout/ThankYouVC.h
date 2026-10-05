//
//  ThankYouVC.h
//  LinkSafe
//
//  Created by uday on 17/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThankYouVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbInstruction;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UIButton *btnSignOutSuccess;

@property(nonatomic, strong) NSDictionary *resultDictionary;

@end
