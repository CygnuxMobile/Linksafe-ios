//
//  VisitorBehaviourVC.m
//  LinkSafe
//
//  Created by Maulikkumar Desai on 10/07/19.
//  Copyright © 2019 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorBehaviourVC.h"
#import "UIButton+Additions.h"
#import "UITextField+Additions.h"
#import "BEMCheckBox.h"
#import "TakePhotoVC.h"
#import "VisitorInductionVC.h"
#import "VisitorCustomQuestionVC.h"
#import "SiteApproverScreenVC.h"

@interface VisitorBehaviourVC ()
{
    NSString *strType;
}

@end

@implementation VisitorBehaviourVC{
    BOOL isScrolledToBottom;
    NSMutableArray *arrOptionSelected;
    NSMutableArray *arrAnswers;
    int selIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor Behaviour" parameters:@{@"onload": @"14"}];
    arrOptionSelected = [[NSMutableArray alloc]init];
    arrAnswers = [[NSMutableArray alloc]init];
    
    _lblQuestion.textColor = kGetHomeLabelColor;
    
    [_btnNext applyBlueShedow];
    
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
    
    _lblQuestion.text = [NSString stringWithFormat:@"%@",[_visitorBehave valueForKey:@"questionText"]];
    strType = [NSString stringWithFormat:@"%@",[_visitorBehave valueForKey:@"mode"]];
    arrAnswers = [_visitorBehave objectForKey:@"options"];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;//@"VISITOR INDUCTION";
    isScrolledToBottom = NO;
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
    
    if([arrOptionSelected count] == 0){
        [Common showAlert:@"Alert" :@"Please select at least one option"];
    }
    else{
        
        [_visitorDetails setObject:arrOptionSelected forKey:KEY_VISITORTYPEID];

        
        NSMutableDictionary *parameteres = [[NSMutableDictionary alloc] init];
        [parameteres setObject:[_visitorDetails objectForKey:@"phone"] forKey:@"phone"];
        [parameteres setObject:arrOptionSelected forKey:KEY_VISITORTYPEID];
        
        [Common callAPI:parameteres Request:API_GET_INDUCTION_CONFIG ShowProgress:YES WithCompletionHandler:^(id responseObject)
         {
             if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
             {
                 if ([[responseObject objectForKey:@"isInductionEnabled"] boolValue])
                 {
                     [_visitorDetails setObject:[responseObject objectForKey:@"inductionHandle"] forKey:@"inductionHandle"];
                     NSMutableArray *arr = [[NSMutableArray alloc]init];
                     arr = [responseObject objectForKey:@"slides"];
                     VisitorInductionVC *visitorInductionVC = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorInductionVC"];
                     visitorInductionVC.visitorDetails = self.visitorDetails;
                     visitorInductionVC.arrSlides = arr;
                     visitorInductionVC.arrVisitorTypeID = arrOptionSelected;
                     visitorInductionVC.navTitle = self.navTitle;
                     visitorInductionVC.inductionHandle = [responseObject objectForKey:@"inductionHandle"];
                     [self.navigationController pushViewController:visitorInductionVC animated:YES];
                 }
                 else
                 {
                     if ([Common appDelegate].config.customQuestionScreen.visitor.isEnabled) {
                         VisitorCustomQuestionVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"VisitorCustomQuestionVC"];
                         vc.visitorDetails = _visitorDetails;
                         vc.navTitle = self.navTitle;
                         [self.navigationController pushViewController:vc animated:YES];
                     }
                     else if ([Common appDelegate].config.isPhotoRequiredSignInVisitor || [Common appDelegate].config.isSignatureRequiredVisitor)
                     {
                         TakePhotoVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"TakePhotoVC"];
                         vc.visitorDetails = self.visitorDetails;
                         vc.navTitle = self.navTitle;
                         vc.isContractor = NO;
                         [self.navigationController pushViewController:vc animated:YES];
                     }
                     else if ([Common appDelegate].config.signInApprovalScreen.visitor.isEnabled)
                     {
                         SiteApproverScreenVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SiteApproverScreenVC"];
                         vc.visitorDetails = self.visitorDetails;
                         vc.navTitle = self.navTitle;
                         vc.isContractor = NO;
                         [self.navigationController pushViewController:vc animated:YES];
                     }
                     else
                     {
                         [self onValideLogin];
                     }
                 }
             }
             else
             {
                 NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
                 [Common showAlert:errorMsg : @""];
             }
         }];
    }
}

-(void)onValideLogin
{
    [_visitorDetails setObject:[_visitorDetails valueForKey:@"phone"] forKey:KEY_MOBILE];
    [Common callVisitorSignInAPI:_visitorDetails ShowProgress:YES WithCompletionHandler:^(id responseObject) {
        
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSLog(@"success");
            [self onPrint:[responseObject mutableCopy]];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[responseObject valueForKey:@"errorMessage"] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }];
}

- (void)onPrint:(NSMutableDictionary *)responceDic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:kSelectedPDFFilePath];
    BRLMChannel    *_ptp=[Common prepareForPtp];
    BRPrintResultViewController *printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    printResultViewController.visitorDetails=responceDic;
    [printResultViewController.visitorDetails setObject:@"0" forKey:kPrinterStatus];
    printResultViewController.navTitle = self.navTitle;
    if (_ptp)
    {
        
//        if ([_ptp isPrinterReady])
//        {
            [printResultViewController.visitorDetails setObject:@"1" forKey:kPrinterStatus];
//        }
//        else
//        {
//            [printResultViewController.visitorDetails setObject:@"Printer is not ready!" forKey:kPrinterMessage];
//        }
    }
    else
    {
        [printResultViewController.visitorDetails setObject:@"Please set printer properly!" forKey:kPrinterMessage];
    }
    [self.navigationController pushViewController:printResultViewController animated:YES];
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
    static NSString *cellIdentifier = @"VisitorBehaviourTVCell";
    
    VisitorBehaviourTVCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    
    NSDictionary *dict = [arrAnswers objectAtIndex:indexPath.row];
    cell.lblAnswer.text = [dict valueForKey:@"displayText"];
    NSString *strSelected = [dict valueForKey:@"id"];
    
    [cell.btnOption setImage:[UIImage imageNamed:@"radioNotSelected"] forState:UIControlStateNormal];
    [cell.btnOption setImage:[UIImage imageNamed:@"radioSelected"] forState:UIControlStateSelected];
    
    [cell.btnCheckBox setImage:[UIImage imageNamed:@"check-box-empty"] forState:UIControlStateNormal];
    [cell.btnCheckBox setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    
    if([strType isEqualToString:@"Single"]){
        cell.btnCheckBox.hidden = YES;
        cell.btnOption.hidden = NO;
    }
    else{
        cell.btnCheckBox.hidden = NO;
        cell.btnOption.hidden = YES;
    }
    
    
    if([arrOptionSelected containsObject:strSelected]){
        cell.btnCheckBox.selected = YES;
        cell.btnOption.selected = YES;
    }
    else{
        cell.btnCheckBox.selected = NO;
        cell.btnOption.selected = NO;
    }
    
//    [cell.btnCheckBox addTarget:self action:@selector(onbtnAnswerClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnOption addTarget:self action:@selector(onbtnAnswerClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [arrAnswers objectAtIndex:indexPath.row];
    NSString *strSelected = [dict valueForKey:@"id"];
    
    if([strType isEqualToString:@"Single"]){
        arrOptionSelected = [[NSMutableArray alloc]init];
        [arrOptionSelected addObject:strSelected];
    }
    else{
        if([arrOptionSelected containsObject:strSelected]){
            [arrOptionSelected removeObject:strSelected];
        }
        else{
            [arrOptionSelected addObject:strSelected];
        }
    }
    
    [self.tblVisitorBehaviour reloadData];
}

-(void)onbtnAnswerClicked:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblVisitorBehaviour];
    NSIndexPath *index = [_tblVisitorBehaviour indexPathForRowAtPoint:buttonPosition];
    
    NSString *StrIndex = [NSString stringWithFormat:@"%ld",index.row + 1];
    
}


@end
