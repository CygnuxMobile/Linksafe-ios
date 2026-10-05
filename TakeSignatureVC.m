//
//  TakeSignatureVC.m
//  LinkSafe
//
//  Created by Chirag Paneliya on 12/05/21.
//  Copyright © 2021 Vladislav Kovalyov. All rights reserved.
//

#import "TakeSignatureVC.h"
#import "UIButton+Additions.h"

@interface TakeSignatureVC ()

@end

@implementation TakeSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Take Signature" parameters:@{@"onload": @"36"}];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
    [_signDone applyBlueShedow];
    [_signCancel applyGrayTheme];
    [self setNavigationMenus];
}

-(void)setNavigationMenus {
    self.navigationItem.leftBarButtonItem = [self leftItem];
}

-(UIBarButtonItem *)leftItem
{
    return [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClicked:)];
}

-(void)leftButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)resetButtonPressed:(id)sender
{
    [_signtureView clearSignature];
}

-(IBAction)saveButtonPressed:(id)sender
{
    UIImage *capturedSignature = [_signtureView getSignatureImage];
    _didFinishWithCapturedSignature(capturedSignature);
    [self leftButtonClicked:nil];
}

@end
