//
//  LockVC.m
//  LinkSafe
//
//  Created by Maulikkumar Desai on 08/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import "LockVC.h"

@interface LockVC ()

@end

@implementation LockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Lock" parameters:@{@"onload": @"40"}];
    // Do any additional setup after loading the view.
}

- (IBAction)onUnlockClicked:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{ // Correct
        [JZTouchID openTouchId:NO];
    });
    
}


@end
