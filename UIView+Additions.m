//
//  UIView+Additions.m
//  Cygnus
//
//  Created by HiteshGs on 09/08/14.
//  Copyright (c) 2014 Cygnus. All rights reserved.

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)applyUIViewTheme {
    self.layer.cornerRadius = 3.0;
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:kThemeGreyValue(215.0).CGColor];
    [self.layer setShadowColor:kThemeGreyValue(215.0).CGColor];
    [self.layer setShadowOpacity:0.3f];
    [self.layer setShadowRadius:3.0f];
    self.layer.cornerRadius=3.0f;
    
}

@end
