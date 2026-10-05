//
//  SignOutVC.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 28/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface SignOutVC : UIViewController

@property (retain, nonatomic) NSString *strVisitor;
@property (retain, nonatomic) NSString *strContractor;

- (IBAction)onContractorButtonClick:(id)sender;
- (IBAction)onVisitorButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnVisitor;
@property (weak, nonatomic) IBOutlet UIButton *btnContractor;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;


@end
