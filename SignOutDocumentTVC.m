//
//  SignOutDocumentTVC.m
//  LinkSafe
//
//  Created by CygNuxiOS on 21/09/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import "SignOutDocumentTVC.h"

@implementation SignOutDocumentTVC

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.viewBG.layer.cornerRadius = 8.0f;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
  
}

@end
