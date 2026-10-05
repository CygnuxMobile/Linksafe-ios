//
//  ContractorWhomToMeetingVC.m
//  LinkSafe
//
//  Created by Kiran on 23/08/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorWhomToMeetingVC.h"
#import "UILabel+Additions.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"

@interface ContractorWhomToMeetingVC () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *arrContacts;
@property(nonatomic, strong) NSMutableArray *arrTempAllContacts;

@end

@implementation ContractorWhomToMeetingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor WhomTo Meeting" parameters:@{@"onload": @"31"}];
    // Do any additional setup after loading the view.
    
    [self getAllContacts];
    
    [self.txtSearch applyGrayBorderTheme];
    self.txtSearch.returnKeyType = UIReturnKeyDone;
    
    [_btnNext applyBlueShedow];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    self.lblHeading.textColor = kGetHomeLabelColor;
    [[self.view viewWithTag:5501].layer setBorderWidth:1];
    [[self.view viewWithTag:5501].layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    _siteListview.hidden = YES;
    _siteListview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.txtSearch.delegate = self;
    self.txtSearch.placeholder = @"Search name here...";
    [self.txtSearch addTarget:self action:@selector(textFieldDidChangeValue:) forControlEvents:UIControlEventEditingChanged];
    
//    self.siteListview.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (app.isIpad) {
        self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width,((self.view.frame.size.height-64)>704?(self.view.frame.size.height-64):704));
        self.tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.arrContacts count] > 0)
    {
        _noData.hidden = YES;
    }
    else
    {
        _noData.hidden = NO;
    }
    return [self.arrContacts count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *contact = [self.arrContacts objectAtIndex:indexPath.row];
    
    UILabel *lbFirstName= (UILabel *) [cell.contentView viewWithTag:1001];
    [lbFirstName applyUITheme:kThemeGreyValue(0.0)];
    lbFirstName.font=kThemeRegularFonts([Common appDelegate].isIpad ? 24 : 16);
    
    NSString *lableText = [NSString stringWithFormat:@"%@%@",[contact valueForKey:@"name"],([NSString stringWithFormat:@"%@",[contact valueForKey:@"position"]].length > 0 ? [NSString stringWithFormat:@" (%@)",[NSString stringWithFormat:@"%@",[contact valueForKey:@"position"]]] : @"")];
    
    if ([lbFirstName respondsToSelector:@selector(setAttributedText:)])
    {
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName: lbFirstName.textColor,
                                  NSFontAttributeName: lbFirstName.font
                                  };
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:lableText attributes:attribs];
        NSRange textRange = [[lableText lowercaseString] rangeOfString:[self.txtSearch.text lowercaseString]];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:textRange];
        lbFirstName.attributedText = attributedText;
    }
    else
    {
        lbFirstName.text = lableText;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = kGetThemeColor;
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _siteListview.hidden = YES;
    _dicSelectedJob = [self.arrContacts objectAtIndex:indexPath.row];
    self.txtSearch.text = [NSString stringWithFormat:@"%@%@",[_dicSelectedJob valueForKey:@"name"],([NSString stringWithFormat:@"%@",[_dicSelectedJob valueForKey:@"position"]].length > 0 ? [NSString stringWithFormat:@" (%@)",[NSString stringWithFormat:@"%@",[_dicSelectedJob valueForKey:@"position"]]] : @"")];
    [self.txtSearch resignFirstResponder];
}

#pragma mark - UITextField Delegate
-(IBAction)textFieldDidChangeValue:(UITextField *)textField
{
    NSString *substring = [NSString stringWithString:textField.text];
    
    if (substring.length == 0)
    {
        self.arrContacts = self.arrTempAllContacts;
        [self.siteListview reloadData];
    }
    else
    {
        [self searchAutocompleteEntriesWithSubstring:substring];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _siteListview.hidden = YES;
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return true;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];;
    _siteListview.hidden = YES;
    return true;
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autoCompleteArray
    // The items in this array is what will show up in the table view
    
//    NSMutableArray *elementArray = [self.arrContacts copy];
//    for (int i = 0 ; i < self.arrContacts.count ; i++)
//    {
//        NSDictionary *contact = [elementArray objectAtIndex:i];
//        NSString *curString = [[contact objectForKey:@"name"] lowercaseString];
//        NSRange substringRangeLowerCase = [curString rangeOfString:[substring lowercaseString]];
//
//        if (substringRangeLowerCase.length != 0)
//        {
//            [self.arrContacts removeObjectAtIndex:i];
//            [self.arrContacts insertObject:contact atIndex:0];
//        }
//    }
//
//    elementArray = [self.arrContacts copy];
//    for (int i = 0 ; i < elementArray.count ; i++)
//    {
//        NSDictionary *contact = [elementArray objectAtIndex:i];
//        NSString *curString = [[contact objectForKey:@"name"] lowercaseString];
//
//        if ([curString hasPrefix:[substring lowercaseString]])
//        {
//            [self.arrContacts removeObjectAtIndex:i];
//            [self.arrContacts insertObject:contact atIndex:0];
//        }
//    }
    
    NSMutableArray *elementArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < self.arrTempAllContacts.count ; i++)
    {
        NSDictionary *contact = [self.arrTempAllContacts objectAtIndex:i];
        NSString *curString = [[contact objectForKey:@"DisplayText"] lowercaseString];
        NSRange substringRangeLowerCase = [curString rangeOfString:[substring lowercaseString]];
        
        if (substringRangeLowerCase.length != 0)
        {
            [elementArray addObject:contact];
        }
    }
    self.arrContacts = elementArray;
    [self.siteListview reloadData];
    
    if (self.arrContacts.count > 0) {
        self.siteListview.hidden = NO;
    }
    else {
        self.siteListview.hidden = YES;
    }
}

/*
-(BOOL)checkIdPresentOrNot:(long)contactId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@", KEY_CONTACT_ID, contactId];
    
    NSArray *array = [self.arrContacts filteredArrayUsingPredicate:predicate];
    if (array.count == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
*/
#pragma mark - Next Click
-(IBAction)didClickNextButton:(id)sender
{
    if (_dicSelectedJob)
    {
        if ([_dicSelectedJob valueForKey:KEY_CONTACT_ID])
        {
            NSString *displayText = [_dicSelectedJob valueForKey:@"name"];
            NSString *posString = [_dicSelectedJob valueForKey:@"position"];
            displayText=[NSString stringWithFormat:@"%@%@",displayText,(posString.length>0?[NSString stringWithFormat:@" (%@)",posString]:@"")];
            
            if ([displayText isEqualToString:self.txtSearch.text])
            {
                [self.ContractorDetail setObject:[_dicSelectedJob valueForKey:KEY_CONTACT_ID] forKey:KEY_CONTACT_ID];
                [self.navigationController popViewControllerAnimated:NO];
                _didFinishWithContactSelection(_ContractorDetail);
                return;
            }
        }
    }
    
    [Common showAlert:@"Error" : @"Please select any contact first"];
}

#pragma mark - Get All Contacts
- (void)getAllContacts
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:@"Contractor" forKey:KEY_REGISTRATION_TYPE];
    [Common callAPI:dicParameters Request:REQUEST_GET_CONTACTS ShowProgress:YES WithCompletionHandler:^(id responseObject)
    {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSArray *contactData = [responseObject valueForKey:@"contacts"];
            if ([contactData count] > 0)
            {
                self.arrContacts = [[NSMutableArray alloc] init];
                for (int i = 0; i < contactData.count; i++)
                {
                    NSMutableDictionary *contact = [[contactData objectAtIndex:i] mutableCopy];
                    [contact setObject:[NSString stringWithFormat:@"%@%@",[contact valueForKey:@"name"],([NSString stringWithFormat:@"%@",[contact valueForKey:@"position"]].length > 0 ? [NSString stringWithFormat:@" (%@)",[NSString stringWithFormat:@"%@",[contact valueForKey:@"position"]]] : @"")] forKey:@"DisplayText"];
                    [self.arrContacts addObject:contact];
                }
                self.arrTempAllContacts = [self.arrContacts copy];
                [self.siteListview reloadData];
            }
            else
            {
                [Common showAlert:@"Ooopss.." : @"No contact found"];
            }
        }
        else
        {
            NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

@end
