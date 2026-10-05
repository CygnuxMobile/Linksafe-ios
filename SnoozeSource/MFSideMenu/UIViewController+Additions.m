//
//  UIViewController+Additions.m
//  Cygnus
//
//  Created by Cygnus on 28/04/14.
//  Copyright (c) 2014 Cygnus. All rights reserved.
//

#import "UIViewController+Additions.h"
#import "UIViewController+MFSideMenuAdditions.h"
#import "MFSideMenuContainerViewController.h"

@implementation UIViewController (Additions)

//- (void)setLeftBarButtonItemWithSelector:(SEL)selector {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                                 initWithImage:[UIImage imageNamed:@"menuToggleIcon"] style:UIBarButtonItemStyleBordered
//                                                 target:self
//                                                 action:selector];
//}

- (void)setRightMenuButtonItem {

    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"setRightBackButtonItem"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(_didTapOnMenuItem)];
    self.navigationItem.rightBarButtonItem = flipButton;
}
- (void)setLeftMenuButtonItem {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"setRightBackButtonItem"] style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(_didTapOnMenuItem)];
    
}

- (void)setLeftBackButtonItem
{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"previous_arrow"] style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(back)];
}
- (void)setRightBackButtonItem
{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"previous_arrow"] style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(back)];
}


- (void)_didTapOnMenuItem
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
