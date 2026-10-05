//
//  VisitorBehaviourVC.h
//  LinkSafe
//
//  Created by Maulikkumar Desai on 10/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitorBehaviourTVCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface VisitorBehaviourVC : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic, strong) NSMutableDictionary *visitorDetails;
@property(nonatomic, strong) NSMutableDictionary *visitorBehave;
@property (retain, nonatomic) NSString *navTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)onNextClicked:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tblVisitorBehaviour;

@end

NS_ASSUME_NONNULL_END
