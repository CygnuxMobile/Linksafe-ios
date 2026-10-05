//
//  UITextField+Additions.m
//  Cygnus
//
//  Created by HiteshGs on 09/08/14.
//  Copyright (c) 2014 Cygnus. All rights reserved.

#import "UITextField+Additions.h"

@implementation UITextField (Additions)

- (void)applyUITextFieldTheme {
    self.backgroundColor = kThemeGreyValue(255.0);
    self.layer.cornerRadius = 3.0;
    self.textColor=[UIColor grayColor];
    if ([[Common appDelegate] isIpad])
    {
        [self.layer setBorderWidth:0.0f];
        [self.layer setBorderColor:[UIColor clearColor].CGColor];
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowOpacity:0.3f];
        [self.layer setShadowRadius:3.0f];
    }
    else
    {
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:kThemeGreyValue(215.0).CGColor];
        [self.layer setShadowColor:kThemeGreyValue(215.0).CGColor];
        [self.layer setShadowOpacity:0.3f];
        [self.layer setShadowRadius:3.0f];
    }
    
    [self.layer setShadowOffset:CGSizeMake(0.0f,2.0f)];
    [self.layer setMasksToBounds:NO];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)applyFlatTheme {
    self.backgroundColor = kThemeGreyValue(255);
    self.layer.cornerRadius = 3.0;
    self.textColor=[UIColor blackColor];
    [self.layer setMasksToBounds:NO];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.clipsToBounds=YES;
}

- (void)applyGrayBorderTheme {
    self.backgroundColor = kThemeGreyValue(249.0);
    self.layer.cornerRadius = 3.0;
    self.textColor=[UIColor blackColor];
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
    [self.layer setMasksToBounds:NO];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
