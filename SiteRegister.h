//
//  SiteRegister.h
//  LinkSafe
//
//  Created by Wish on 26/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiteRegister : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UITableView *siteListview;
@property (weak, nonatomic) IBOutlet UILabel *noData;
@property(nonatomic, strong) NSArray *siteArray;
@property(nonatomic, strong) NSString *sitePassword;


@end
