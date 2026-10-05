//
//  VisitorBehaviourTVCell.h
//  LinkSafe
//
//  Created by Maulikkumar Desai on 11/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VisitorBehaviourTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblAnswer;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;

@property (weak, nonatomic) IBOutlet UIButton *btnSelection;


@end

NS_ASSUME_NONNULL_END
