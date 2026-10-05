//
//  SCSearchResultVC.h
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSearchResultVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblUsers;
@property (weak, nonatomic) IBOutlet UIView *containtView;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnValidate;

@property (retain, nonatomic) NSArray *arrWorkers;
@property (nonatomic) NSInteger totalWorkers;
@property (retain, nonatomic) NSString *strSelectedSiteId;

+(SCSearchResultVC *)viewController;

@end

NS_ASSUME_NONNULL_END
