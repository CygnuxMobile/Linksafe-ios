//
//  ExceptionVC.m
//  LinkSafe
//
//  Created by uday on 06/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "ExceptionVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "FTIndicator.h"

#define Scale [UIScreen mainScreen].scale
@interface ExceptionVC ()
{
    NSMutableArray *exceptionArray;
    UIDatePicker *datePicker;
    NSDate *dateNow;
    BOOL isWorkPermitPasswordVisible;
    BOOL isWorkPermitPasswordInstruction;
  //  HSDatePickerViewController *hsdpvc;
    NSDateFormatter *displayformatter;
}

@property (nonatomic, retain) SiteConfig *config;

@end

@implementation ExceptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Exception" parameters:@{@"onload": @"28"}];
    self.config = [Common appDelegate].config;
    
    [self getWorkPermitQuestion];
    exceptionArray=[[NSMutableArray alloc] init];
    
    [_btnCancel applyGrayTheme];
    [_btnContinue applyBlueShedow];
    [_btnDateTime applyWhiteTheme];
//    [_tfPassword applyFlatTheme];
    
    _btnDateTime.backgroundColor = kThemeGreyValue(249.0);
    _btnDateTime.layer.cornerRadius = 3.0;
    [_btnDateTime.layer setBorderWidth:1.0f];
    [_btnDateTime.layer setBorderColor:kThemeGreyValue(197.0).CGColor];
    [_btnDateTime.layer setMasksToBounds:NO];
    
    if ([[Common appDelegate] isIpad])
    {
        [_tfPassword applyGrayBorderTheme];
    }
    else
    {
        [_tfPassword applyGrayBorderTheme];
    }
    
    _tfPassword.placeholder = self.config.workPermitPasswordLabel;
    self.lbTitleMsg.text = _titlemassage;
    self.lbTitleMsg.textColor = kGetHomeLabelColor;
    displayformatter = [[NSDateFormatter alloc] init];
    [displayformatter setDateFormat:@"HH:mm"];
    //[_btnDateTime setTitle:[@"Select time   " uppercaseString] forState:UIControlStateNormal];
    [_btnDateTime setTitle:[@"" uppercaseString] forState:UIControlStateNormal];

   // hsdpvc = [[HSDatePickerViewController alloc] init];
    
    _passwordIntructView.hidden=YES;
    _passwordIntructView.textColor = kGetHomeLabelColor;
    if (self.config.workPermitConfirmationMessage) {
        if ([self.config.workPermitConfirmationMessage length]>0)
        {
            _passwordIntructView.hidden=NO;
            isWorkPermitPasswordInstruction=YES;
            _passwordIntructView.text=self.config.workPermitConfirmationMessage;
        }
    }
    
    _uiTableException.layer.cornerRadius=3.0;
    _uiTableException.clipsToBounds=YES;
    [Common ApplyUIViewBoeder:_uiTableException];
    
//    hsdpvc.mainColor=kGetThemeColor;
//    hsdpvc.date=[NSDate date];
//    hsdpvc.delegate=self;
//    hsdpvc.minDate=dateNow;
//    hsdpvc.dateFormatter=displayformatter;
//
//    hsdpvc.confirmButtonTitle=@"Done";
//    hsdpvc.backButtonTitle=@"Back";
    
    datePicker = [[UIDatePicker alloc] init];
    CGRect rect = _btnDateTime.frame;
    datePicker.frame = CGRectMake((rect.size.width-100), (rect.size.height-40)/2, 100, 40.0f); // set frame as your need
    rect.origin.y = (rect.size.height - 22 )/2;
  //  datePicker.frame = rect;
   // datePicker.backgroundColor = [UIColor yellowColor];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
  //  [datePicker tool];
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];

    [toolBar setTintColor:[UIColor grayColor]];

/* Here we are adding a done button so that we can close our picker after date selection */

    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dateChanged:)];

    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    [_btnDateTime addSubview: datePicker];
    
    
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
    int needhight=568;
    if ([Common appDelegate].isIpad)
    {
        needhight=self.view.frame.size.height-64;
    }
    isWorkPermitPasswordVisible=self.config.isWorkPermitPasswordVisible;
    if(!isWorkPermitPasswordVisible)
    {
        _tfPassword.hidden=YES;
        if([[Common appDelegate] isIpad])
        {
            CGRect btnDate=_btnDateTime.frame;
            btnDate.origin.x=(self.view.frame.size.width-btnDate.size.width)/2;
            _btnDateTime.frame=btnDate;
            
            btnDate=_lbDateTimePlaceholder.frame;
            btnDate.origin.x=(self.view.frame.size.width-btnDate.size.width)/2;
            _lbDateTimePlaceholder.frame=btnDate;
            
        }
        else
        {
            CGRect viewFrame=_viewdatepasscontainer.frame;
            if (isWorkPermitPasswordInstruction)
            {
                viewFrame.size.height=100;
                needhight=720;
            }
            else
            {
                viewFrame.size.height=50;
            }
            _viewdatepasscontainer.frame=viewFrame;
        }
    }
    else
    {
        _tfPassword.hidden=NO;
    }
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height-64>needhight?self.view.frame.size.height-64:needhight);
    self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
}
- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    dateNow = datePicker.date;
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [NSDate dateWithTimeInterval:10 sinceDate:dateNow];

    NSLog(@"----%@",[formatter stringFromDate:correctDate]);
    
 //   NSString *currentTime = [dateFormatter stringFromDate: datePicker.date];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.navTitle;//@"CONTRACTOR SIGN IN";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)getWorkPermitQuestion
{
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setValue:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",self.workPermitTypeID] intValue]] forKey:KEY_PERMIT_TYPE_ID];
    [Common callAPI:dicParameters Request:GET_WORK_PERMIT_QUESTIONS ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            self->exceptionArray = [responseObject valueForKeyPath:@"questions"];
            [self.uiTableException reloadData];
            for (int i=0; i<[self->exceptionArray count]; i++)
            {
                [[self->exceptionArray objectAtIndex:i] setObject:@"0" forKey:VAL_SWITCH];
            }
            int neededHight=(int)[self->exceptionArray count]*50;
            CGRect tblRect=self.uiTableException.frame;
            tblRect.size.height=neededHight;
            self.uiTableException.frame=tblRect;
            
            if ([Common appDelegate].isIpad)
            {
                neededHight=300+neededHight;
            }
            else
            {
                neededHight=330+neededHight;
            }
          
            if(![[Common appDelegate] isIpad])
            {
                neededHight=neededHight-50;
                CGRect viewFrame=self.viewdatepasscontainer.frame;
                
                if (self->isWorkPermitPasswordInstruction)
                {
                    neededHight=neededHight+50;
                    viewFrame.origin.y=self.btnContinue.frame.origin.y-110;
                }
                else
                {
                    if(self->_tfPassword.hidden)
                    {
                    viewFrame.origin.y=self.btnContinue.frame.origin.y-60;
                        }
                    else
                    {
                        viewFrame.origin.y=self.btnContinue.frame.origin.y-100;
                    }
                }
                self.viewdatepasscontainer.frame=viewFrame;
            }

            self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height-64>neededHight?self.view.frame.size.height-64:neededHight);
            self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,self.contentView.frame.size.height);
        }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg.length>0?errorMsg:@"Please try again." : @""];
        }
    }
     ];
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [exceptionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    UISwitch *defaultSwitch;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    defaultSwitch= (UISwitch *) [cell.contentView viewWithTag:(21000 + indexPath.row)];
    
    if (defaultSwitch==nil)
    {
        defaultSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 100, 0, 0 )];
        defaultSwitch.backgroundColor = [UIColor whiteColor];
        defaultSwitch.onTintColor =[UIColor whiteColor];
        defaultSwitch.clipsToBounds = true;
        defaultSwitch.layer.cornerRadius = 16;
        
        
        defaultSwitch.tag = (21000 + indexPath.row);
        [defaultSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = defaultSwitch;
    }
    UILabel *lbPermission= (UILabel *) [cell.contentView viewWithTag:1001];
    [lbPermission applyUITheme:kThemeGreyValue(24.0)];
    
    if ([[exceptionArray objectAtIndex:indexPath.row] valueForKey:VAL_SWITCH])
    {
        defaultSwitch.on=[[[exceptionArray objectAtIndex:indexPath.row] valueForKey:VAL_SWITCH] boolValue];
    }
    else
    {
        defaultSwitch.on=NO;
    }
    defaultSwitch.thumbTintColor = defaultSwitch.on ? [UIColor greenColor] : [UIColor redColor];
    lbPermission.text = [[exceptionArray objectAtIndex:indexPath.row] valueForKeyPath:@"text"];
    lbPermission.textColor=[UIColor whiteColor];
    
    
    return cell;
}

- (void)changeSwitch:(id)sender{
    UISwitch *swPermission = (UISwitch *)sender;
    swPermission.thumbTintColor = swPermission.on ? [UIColor greenColor] : [UIColor redColor];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((long)swPermission.tag - 21000) inSection:0];
    NSLog(@"Switch======%ld",(long)indexPath.row);
    [[exceptionArray objectAtIndex:indexPath.row] setObject:swPermission.on?@"1":@"0" forKey:VAL_SWITCH];
}

- (IBAction)onCancelClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
//- (IBAction)onDateClick:(id)sender {
//
//    [self presentViewController:hsdpvc animated:YES completion:nil];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([_tfPassword.text length]>0) {
        
        BOOL isAllCheck=YES;
        for (int i=0; i<[exceptionArray count]; i++)
        {
            if ([[exceptionArray objectAtIndex:i] valueForKey:VAL_SWITCH])
            {
                if (![[[exceptionArray objectAtIndex:i] valueForKey:VAL_SWITCH] boolValue])
                {
                    isAllCheck=NO;
                }
            }
        }
        if (isAllCheck)
        {
            [self onContinueClick:nil];
        }
        
    }
    
    return true;
}

- (IBAction)onContinueClick:(id)sender {
    
    if (dateNow==nil)
    {
        [Common showAlert:@"" :@"Please select time"];
        return;
    }
    if ([_tfPassword.text length]<=0 && isWorkPermitPasswordVisible) {
        [Common showAlert:@"" :@"Please enter password"];
        return;
    }
    BOOL isAtLeastOneCheck=YES;
    for (int i=0; i<[exceptionArray count]; i++)
    {
        if ([[exceptionArray objectAtIndex:i] valueForKey:VAL_SWITCH])
        {
            if (![[[exceptionArray objectAtIndex:i] valueForKey:VAL_SWITCH] boolValue])
            {
                isAtLeastOneCheck=NO;
                break;
            }
        }
    }
    if (isAtLeastOneCheck)
    {
        NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
        
        NSDateFormatter *formatter;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *correctDate = [NSDate dateWithTimeInterval:10 sinceDate:dateNow];
        [dicParameters setValue:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",self.workPermitFormID] intValue]] forKey:KEY_WORKPERMIT_FORM_ID];
        [dicParameters setValue:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",self.workPermitTypeID] intValue]] forKey:@"workPermitTypeID"];
        [dicParameters setValue:[formatter stringFromDate:correctDate] forKey:@"commencingOn"];
        [dicParameters setValue:[NSString stringWithFormat:@"%@",_tfPassword.text] forKey:@"password"];
        
        [Common callAPI:dicParameters Request:REQUEST_SaveWorkPermitSections ShowProgress:YES WithCompletionHandler:^(id responseObject) {
            
            if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
            {
                NSMutableDictionary *nsd =[[NSMutableDictionary alloc] init];
                [nsd setObject:self.workPermitTypeID forKey:@"workPermitTypeID"];
                [nsd setObject:@"1" forKey:self.workPermitTypeID];
                [self.navigationController popViewControllerAnimated:NO];
                _didFinishwithExceptionDetail(nsd);
            }
            else
            {
                NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                [Common showAlert:errorMsg.length>0?errorMsg:@"Please try again." : @""];
            }
        }];
    }
    else
    {
        [FTIndicator showErrorWithMessage:[NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_WorkPermitIncorrectAnswerMessage]].length > 0 ? [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_WorkPermitIncorrectAnswerMessage]] : @"A permit to work cannot be issued if any answers are No"];
    }
}
//#pragma date deligate
//- (void)hsDatePickerPickedDate:(NSDate *)date
//{
//    NSLog(@"===========%@",date);
//    dateNow=date;
//    [_btnDateTime setTitle:[NSString stringWithFormat:@"%@   ",[displayformatter stringFromDate:dateNow]] forState:UIControlStateNormal];
//}
//- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method
//{
//    NSLog(@"===========%lu",(unsigned long)method);
//    
//}
//- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method
//{
//    NSLog(@"===========%lu",(unsigned long)method);
//    
//}


@end
