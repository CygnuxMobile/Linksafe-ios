//
//  SCSearchResultTableViewCell.m
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import "SCSearchResultTableViewCell.h"

@implementation SCSearchResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCell:(NSDictionary *)worker {

    NSString *base64 = [NSString stringWithFormat:@"%@", [worker objectForKey:@"photoUri"]];
    _imgPhoto.image = [Common decodeBase64ToImage:base64];
    _lblName.text = [NSString stringWithFormat:@"%@", [worker objectForKey:@"name"]];
//    _lblOrganisation.text = [NSString stringWithFormat:@"%@", [worker objectForKey:@"organisation"]];
    _lblOrganisation.text = [worker valueForKey:@"organisation"];
}

@end
