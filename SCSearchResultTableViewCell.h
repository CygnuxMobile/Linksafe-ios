//
//  SCSearchResultTableViewCell.h
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSearchResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblOrganisation;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;

-(void)configureCell:(NSDictionary *)worker;

@end

NS_ASSUME_NONNULL_END
