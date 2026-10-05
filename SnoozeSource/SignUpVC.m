//
//  SighnUpViewController.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import "SignUpVC.h"
#import "Common.h"
#import "LoginVC.h"

@interface SignUpVC ()

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Sign Up" parameters:@{@"onload": @"33"}];
    // Do any additional setup after loading the view.
    
    arrCity = [[NSMutableArray alloc] init];
    
    strCity = @"";
    
    [self getCity];
    
    [_btnTerms setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    
    [_btnPromotions setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"LinkSafe Site";

    self.navigationController.navigationBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

#pragma mark UITextFiled Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if (textField == _tfBD)
    {
        [self.view endEditing:true];
        [self callDP];
        return NO;
    }
    else if (textField == _tfCity)
    {
        [self.view endEditing:true];
        [self showCity];
        return NO;
    }
    
    return YES;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}


- (IBAction)clickOnLogin:(id)sender {
    
    LoginVC *objLoginVC = (LoginVC *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.navigationItem.title = @"";
    [self.navigationController pushViewController:objLoginVC animated:YES];
    
}

- (void)changeDate:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
}

- (void)removeViews:(id)object
{
    
    if ([self.view viewWithTag:10])
    {
        [[self.view viewWithTag:10] removeFromSuperview];
    }
    else
    {
        _pickerCity.hidden = YES;
    }
    
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker{
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, SCREEN_WIDTH, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, SCREEN_WIDTH, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];

    [self.view viewWithTag:9].alpha = 0;

    if ([self.view viewWithTag:10])
    {
        [self.view viewWithTag:10].frame = datePickerTargetFrame;
    }
    else
    {
        _pickerCity.frame = datePickerTargetFrame;
    }
    
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

-(IBAction)dismissPicker:(UIBarButtonItem *)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)[self.view viewWithTag:10];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    _tfBD.text = [formatter stringFromDate:datePicker.date];
    
    [self dismissDatePicker];
}

-(IBAction)removePicker:(UITapGestureRecognizer *)sender
{
    [self dismissDatePicker];
}

- (void)callDP
{
    if ([self.view viewWithTag:9]) {
        return;
    }
    
    CGRect datePickerTargetFrame = CGRectMake(0, (self.view.bounds.size.height-260)/2, SCREEN_WIDTH, 216);
    CGRect toolbarTargetFrame = CGRectMake(0, datePickerTargetFrame.size.height+datePickerTargetFrame.origin.y, SCREEN_WIDTH, 44);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, SCREEN_WIDTH, 216)];
    //  [datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    datePicker.maximumDate = [NSDate date];
    
    if (_tfBD.text.length>2)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yyyy"];
        datePicker.date = [formatter dateFromString:_tfBD.text];
    }
    
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.tag = 10;
    datePicker.datePickerMode = UIDatePickerModeDate;
    //[datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, SCREEN_WIDTH, 44)];
    toolBar.tag = 11;
    toolBar.barTintColor = kThemeBlueColor;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissPicker:)];
    
    [doneButton setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton,spacer1, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

- (void)showCity
{
    if ([self.view viewWithTag:9]) {
        return;
    }
    
    _pickerCity.alpha = 1;
    _pickerCity.hidden = NO;
    
    CGRect datePickerTargetFrame = CGRectMake(0, (self.view.bounds.size.height-260)/2, SCREEN_WIDTH, 216);
    CGRect toolbarTargetFrame = CGRectMake(0, datePickerTargetFrame.size.height+datePickerTargetFrame.origin.y, SCREEN_WIDTH, 44);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:darkView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, SCREEN_WIDTH, 44)];
    toolBar.tag = 11;
    toolBar.barTintColor = kThemeBlueColor;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(removePicker:)];
    
    [doneButton setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton,spacer1, nil]];
    [self.view addSubview:toolBar];
    
    [self.view bringSubviewToFront:_pickerCity];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    _pickerCity.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
    
}

#pragma mark UIPickerView Delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrCity.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _tfCity.text = [[arrCity objectAtIndex:row] valueForKey:@"city_name"];
    strCity = [[arrCity objectAtIndex:row] valueForKey:@"city_id"];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[arrCity objectAtIndex:row] valueForKey:@"city_name"];
}

#pragma mark Get City

-(void)getCity
{
    /*[Common callAPI:[[NSMutableDictionary alloc] initWithDictionary:@{}] Request:REQUEST_CITY_AREA ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[responseObject objectForKey:@"status"] isEqualToString:SUCCESS_STATUS])
        {
            arrCity = [[NSMutableArray alloc] initWithArray:[[responseObject valueForKey:@"data"] valueForKey:@"city"]];
            [_pickerCity reloadAllComponents];
        }
        
    }];*/
}

-(IBAction)onTermsAndCondition:(UIButton *)sender
{
    
    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"uncheck"]])
    {
        [sender setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }
    
}

-(IBAction)clickOnTC:(UIButton *)sender
{
    [self.view bringSubviewToFront:_vwTermsAndConditions];
    _vwTermsAndConditions.hidden = NO;
}

-(IBAction)onHideTCView:(UIButton *)sender
{
    _vwTermsAndConditions.hidden = YES;
}

@end
