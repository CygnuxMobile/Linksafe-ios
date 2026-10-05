//
//  ContractorWorkFlowVC.m
//  LinkSafe
//
//  Created by Maulikkumar Desai on 16/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import "ContractorWorkFlowVC.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "TakePhotoVC.h"
#import "ContractorSignInVC.h"

@interface ContractorWorkFlowVC ()
{
    NSString *strType;
    NSMutableArray *arrMessages;
    NSMutableDictionary *messageBoardParameters;
}

@end

@implementation ContractorWorkFlowVC{
    NSMutableArray *arrOptionSelected;
    NSMutableArray *arrAnswers;
    int selIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Contractor Work Flow" parameters:@{@"onload": @"23"}];
    arrOptionSelected = [[NSMutableArray alloc]init];
    arrAnswers = [[NSMutableArray alloc]init];
    
    _lblQuestion.textColor = kGetHomeLabelColor;
    _lblOtherWork.textColor = kGetHomeLabelColor;
    
    [_btnNext applyBlueShedow];
    
    _txtOtherWork.delegate = self;
    _txtOtherWork.text = @"Enter Text..";
    
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    [Common updateTime:self.view];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
    [[self.view viewWithTag:5501].layer setBorderWidth:1];
    [[self.view viewWithTag:5501].layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    //55501
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:55501]];
    [[self.view viewWithTag:55501].layer setBorderWidth:1];
    [[self.view viewWithTag:55501].layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    
    arrAnswers = [[Common SiteData] valueForKey:KEY_WORK_TYPE];
    
    
    _lblQuestion.text = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_WORK_TYPE_QUESTION_TEXT]];
    
//    for(int i = 0; i<[arr count]; i++){
//        NSDictionary *dict = [arr objectAtIndex:i];
//        NSString *str = [NSString stringWithFormat:@"%@",[dict valueForKey:@"displayText"]];
//        [arrAnswers addObject:str];
//    }
    
    int needHight=0;
    if ([Common appDelegate].isIpad)
    {
        needHight = 700;
        int viewHeight = self.view.frame.size.height-64;
        self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, needHight>viewHeight?needHight:viewHeight);
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    }
    else
    {
        int viewHeight = self.view.frame.size.height-64;
        self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 667>viewHeight?667:viewHeight);
        self.tpKeyBoard.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    }
    
    
    
    
    [arrOptionSelected addObject:@"1"];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;//@"VISITOR INDUCTION";
    //isScrolledToBottom = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (IBAction)onNextClicked:(id)sender {
    NSString *strWork = [Common removeWhiteSpace:_txtOtherWork.text];
    if (strWork.length == 0 || [strWork isEqualToString:@"Enter Text.."] || arrOptionSelected.count == 0)
    {
        [Common showAlert:@"Error" :@"Please select or add work"];
    }
    else{
        NSUserDefaults *userContractorWork = [NSUserDefaults standardUserDefaults];
        
        NSString *str = _txtOtherWork.text;
        if ([strWork isEqualToString:@"Enter Text.."]){
            [str stringByReplacingOccurrencesOfString:@"Enter Text.." withString:@""];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:arrOptionSelected forKey:@"workTypeID"];
        [dict setValue:str forKey:@"workTypeOther"];
        
        [userContractorWork setValue:dict forKey:@"userContractorWork"];
        
        
        NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_SPOT_CHECKUSER]];
        
        if([strIsSpotCheckUser isEqualToString:@"true"] && [_registrationType isEqualToString:@"Contractor"]){
            ContractorSignInVC *contractorSignInVC = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"ContractorSignInVC"];
            contractorSignInVC.navTitle = _btnTitleType;
            contractorSignInVC.isSpotUser = YES;
            [self.navigationController pushViewController:contractorSignInVC animated:YES];
        }
        else{
            NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
            [parameters setObject:_registrationType forKey:KEY_REGISTRATION_TYPE];
            [parameters setObject:_eventType forKey:KEY_EVENT_TYPE];
            messageBoardParameters = parameters;
            [Common callAPI:parameters Request:REQUEST_GET_MESSAGE_BOARDS ShowProgress:YES WithCompletionHandler:^(id responseObject)
             {
                 if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                 {
                     self->arrMessages = [[responseObject objectForKey:@"messages"] mutableCopy];
                     //            [arrMessages addObject:@"<html><body>Hi, here’s a sign-in message for you 1!</body></html>"];
                     //            [arrMessages addObject:@"<html><body>Hi, here’s a sign-in message for you 2!</body></html>"];
                    // [self showMessagBoard];
                 }
                 else
                 {
                     NSString *errorMsg =[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                     [Common showAlert:errorMsg : @""];
                 }
             }];
        }
        
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([[Common removeWhiteSpace:textView.text] isEqualToString:@"Enter Text.."])
    {
        textView.text = @"";
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([Common removeWhiteSpace:textView.text].length == 0)
    {
        textView.text = @"Enter Text..";
    }
}


#pragma mark - Table View Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrAnswers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContractorWorkFlowTVC";
    
    ContractorWorkFlowTVC *cell = [tableView dequeueReusableCellWithIdentifier:
                                    cellIdentifier];
    
    NSDictionary *dict = [arrAnswers objectAtIndex:indexPath.row];
    cell.lblAnswer.text = [dict valueForKey:@"displayText"];
    NSString *strSelected = [dict valueForKey:@"id"];
    
    [cell.btnCheckBox setImage:[UIImage imageNamed:@"check-box-empty"] forState:UIControlStateNormal];
    [cell.btnCheckBox setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    
    
    if([arrOptionSelected containsObject:strSelected]){
        cell.btnCheckBox.selected = YES;
    }
    else{
        cell.btnCheckBox.selected = NO;
    }
    
    [cell.btnCheckBox addTarget:self action:@selector(onbtnAnswerClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)onbtnAnswerClicked:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblVisitorBehaviour];
    NSIndexPath *index = [_tblVisitorBehaviour indexPathForRowAtPoint:buttonPosition];
    
    NSString *StrIndex = [NSString stringWithFormat:@"%ld",index.row + 1];
    
    
    if([strType isEqualToString:@"Single"]){
        arrOptionSelected = [[NSMutableArray alloc]init];
        [arrOptionSelected addObject:StrIndex];
    }
    else{
        if([arrOptionSelected containsObject:StrIndex]){
            [arrOptionSelected removeObject:StrIndex];
        }
        else{
            [arrOptionSelected addObject:StrIndex];
        }
    }
    
    [self.tblVisitorBehaviour reloadData];
}

@end
