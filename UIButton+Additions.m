//
//  UIButton+Additions.m
//  Cygnus
//
//  Created by HiteshGs on 09/08/14.
//  Copyright (c) 2014 Cygnus. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (void)applyBlueShedow
{
    self.backgroundColor = kGetThemeColor;
    [self setTitleColor:kThemeGreyValue(255.0) forState:UIControlStateNormal];
    [self applyCustomeSize];
    self.layer.cornerRadius = 3.0;
    [self.layer setBorderWidth:0.0f];
    [self.layer setMasksToBounds:NO];
    [self setHighlightedColor:kThemeBGGrey];
}
- (void)applyBlueBorderShedow {
    self.backgroundColor = kThemeGreyValue(255.0);
    [self setTitleColor:kGetThemeColor forState:UIControlStateNormal];
    [self applyCustomeSize];
    self.layer.cornerRadius = 3.0;
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:kGetThemeColor.CGColor];
    [self.layer setMasksToBounds:NO];
    [self setHighlightedColor:kThemeBGGrey];
}
- (void)applyGrayTheme {
    self.backgroundColor = kThemeGreyButtom;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self applyCustomeSize];
    self.layer.cornerRadius = 3.0;
    [self.layer setMasksToBounds:NO];
    [self setHighlightedColor:[UIColor lightGrayColor]];
}
- (void)applyWhiteTheme {
    self.backgroundColor = [UIColor whiteColor];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self applyCustomeSize];
    self.layer.cornerRadius = 3.0;
    [self.layer setMasksToBounds:NO];
    [self setHighlightedColor:[UIColor lightGrayColor]];
}

- (void)applyGrayUnderLine {
    UIView *uiline=[[UIView alloc] initWithFrame:CGRectMake(((self.frame.size.width-150)/2), self.frame.size.height-1,150, 1)];
    uiline.backgroundColor=[UIColor lightGrayColor];
    [self addSubview:uiline];
}


- (void)applyCustomeSize
{
    if ([[Common appDelegate] isIpad])
    {
        [self.titleLabel setFont:kThemeRegularFonts(30.0)];
    }
    else
    {
        [self.titleLabel setFont:kThemeRegularFonts(14.0)];
    }
}
- (void)setHighlightedColor:(UIColor *)highlightColor {
    [self setBackgroundImage:[self setBackgroundImageByColor:highlightColor cornerRadius:3]
                    forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
- (UIImage *)setBackgroundImageByColor:(UIColor *)backgroundColor cornerRadius:(float)radius {
    UIView *tcv = [[UIView alloc] initWithFrame:self.frame];
    [tcv setBackgroundColor:backgroundColor];
    
    CGSize gcSize = tcv.frame.size;
    UIGraphicsBeginImageContext(gcSize);
    [tcv.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    const CGRect RECT = CGRectMake(0, 0, image.size.width, image.size.height);;
    [[UIBezierPath bezierPathWithRoundedRect:RECT cornerRadius:radius] addClip];
    [image drawInRect:RECT];
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageNew;
}

@end
