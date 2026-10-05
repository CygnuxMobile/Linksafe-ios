//
//  SideMenuVC.h
//  Extreme_trip
//
//  Created by Hitesh Gs on 08/05/15.
//  Copyright (c) 2015 Hitesh Gs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView    *tblSideMenu;
    NSMutableArray          *sideMenuList;
}

@property(nonatomic,assign) NSInteger   lastSelectedOption;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;


@end
