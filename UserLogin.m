//
//  VisitorSignInStepTwoVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "UserLogin.h"
#import "UserRegistrationVC.h"
#import "UserDetailsVC.h"
#import "UserList.h"
#import "SiteRegister.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "AsyncImageView.h"
#import "MeetingWithVC.h"
#import "VisitorBehaviourVC.h"
#import "VisitorInductionVC.h"
#import "TakePhotoVC.h"

@interface UserLogin ()

@end

@implementation UserLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"User login" parameters:@{@"onload": @"48"}];
    _lblHeader.textColor = kGetHomeLabelColor;
    if (![Common appDelegate].isIpad)
    {
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,(self.view.frame.size.height>750?self.view.frame.size.height:750));
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,self.contentView.frame.size.height);
    }
    
    [_btnSearch applyBlueShedow];
    [_btnNewUser applyBlueShedow];
    [_btnCancel applyGrayTheme];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];

    _orLable.clipsToBounds=YES;
    _orLable.layer.cornerRadius=3.0f;
    
    if ([Common appDelegate].isIpad)
    {
        [_tfFirstName applyGrayBorderTheme];
        [_tfLastName applyGrayBorderTheme];
        [_tfPhoneNo applyGrayBorderTheme];
    }
    else
    {
        [_tfFirstName applyGrayBorderTheme];
        [_tfLastName applyGrayBorderTheme];
        [_tfPhoneNo applyGrayBorderTheme];
    }
    
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.navTitle;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(upadteTime)
                                             name:N_UpdateTime
                                           object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [self upadteTime];
    
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
//    AsyncImageView *imageView = ((AsyncImageView *)[self.view viewWithTag:3301]);
//    CGFloat deviceWidth = [UIScreen mainScreen].bounds.size.width;
//    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}


#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==_tfFirstName || textField==_tfLastName)
    {
        _tfPhoneNo.text=@"";
    }
    else
    {
        _tfFirstName.text=@"";
        _tfLastName.text=@"";
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length]>0)
    {
        [self onSearch:nil];
    }
    
    return true;
}


#pragma mark - Click Listner

- (IBAction)onSideMenuClick:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

- (IBAction)onCancel:(id)sender {
     [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onNewUser:(id)sender
{
    UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
    vc.visitorDetails=nil;
    vc.isUpdate=NO;
    vc.navTitle = self.navTitle;
    [self.navigationController pushViewController:vc animated:YES];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];

    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

    return [string isEqualToString:filtered];
    
//    return YES;
}


- (IBAction)onSearch:(id)sender{
    

    NSString *txtFirstName = [Common removeWhiteSpace:_tfFirstName.text];
    
    NSString *txtLastName = [Common removeWhiteSpace:_tfLastName.text];
    
    NSString *txtPhone = [Common removeWhiteSpace:_tfPhoneNo.text];
    
    
    if ([txtPhone length]>0)
    {
        if(![Common isNumberValid:txtPhone])
        {
            [Common showAlert:@"Enter valid phone" :@"Phone number should be 6 to 14 digit"];
            return;
        }
    }
    
    
    
    [self.view endEditing:YES];
    
    if (![self isValidSubmition]) {
        return;
    }
    
    if ([txtFirstName containsString:@"’"])
    {
        txtFirstName = [txtFirstName stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    if ([txtLastName containsString:@"’"])
    {
        txtLastName = [txtLastName stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    if ([txtPhone containsString:@"’"])
    {
        txtPhone = [txtPhone stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    }
    
    NSMutableDictionary *dicParameters =[[NSMutableDictionary alloc] init];
    [dicParameters setObject:txtFirstName forKey:@"firstName"];
    [dicParameters setObject:txtLastName forKey:@"lastName"];
    [dicParameters setObject:txtPhone forKey:@"phone"];
    
    [Common callAPI:dicParameters Request:REQUEST_SEARCH_REGISTER ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSArray *personData = [responseObject valueForKey:@"results"];
            if ([personData count] > 0)
            {
                if([personData count] == 1)
                {
                    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[personData objectAtIndex:0]];
                    [data setObject:@"1" forKey:KEY_FROM_SEARCH];
                    UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
                    vc.visitorDetails = data;
//                    vc.isUpdate = YES;
                    vc.notFoundUser = NO;
                    vc.navTitle = self.navTitle;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    [self geToUserList:personData];
                }
            }
            else
            {
                UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
                vc.visitorDetails=dicParameters;
                vc.isUpdate=NO;
                vc.notFoundUser=YES;
                vc.navTitle = self.navTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }
         }
        else
        {
            NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}
//------when more then 1 users are have same number
- (void)geToUserList:(NSArray *)visitorArray
{
    UserList *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserList"];
    vc.visitorArray = visitorArray;
    vc.navTitle = self.navTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (Boolean)isValidSubmition
{
    NSString *txtFirstName = [Common removeWhiteSpace:_tfFirstName.text];
    
    NSString *txtLastName = [Common removeWhiteSpace:_tfLastName.text];
    
    NSString *txtPhone = [Common removeWhiteSpace:_tfPhoneNo.text];
    
    if((txtFirstName.length == 0 || txtLastName.length == 0) && txtPhone.length == 0 )
    {
        [Common showAlert:@"Invalid Input" :@"Please enter either First Name and Last Name, OR Phone Number"];
        return false;
    }
    else if(txtFirstName.length > 0 && txtLastName.length > 0 && txtPhone.length > 0)
    {
        [Common showAlert:@"Invalid input" :@"Please remove unnecesarry filter"];
        return false;
    }
    else if(txtFirstName.length > 0 || txtLastName.length > 0)
    {
        if (txtPhone.length>0) {
            [Common showAlert:@"Invalid input" :@"Please remove phone number"];
            return false;
            
        }
        else{
            return true;
        }
    }
    else if (txtPhone.length>0) {
        
        return true;
    }
    
    
    
    return false;
}






@end
