//
//  UILabel+Additions.m
//  Cygnus
//
//  Created by HiteshGs on 09/08/14.
//  Copyright (c) 2014 Cygnus. All rights reserved.

#import "UITextField+Additions.h"

@implementation UILabel (Additions)

- (void)applyUITheme:(UIColor *)textColor {
    self.backgroundColor = [UIColor clearColor];
    self.textColor=textColor;
    if ([[Common appDelegate] isIpad])
    {
       [self setFont:kThemeRegularFonts(14.0)];
    }
    else
    {
        [self setFont:kThemeRegularFonts(12.0)];
    }
}
@end
