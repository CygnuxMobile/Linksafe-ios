//
//  YourInformationVC.m
//  LinkSafe
//
//  Created by Wish on 20/10/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "UserList.h"
#import "UserDetailsVC.h"
#import "UIButton+Additions.h"
#import "UserRegistrationVC.h"
#import "TakePhotoVC.h"
#import "UILabel+Additions.h"
#import "MeetingWithVC.h"
#import "VisitorBehaviourVC.h"
#import "VisitorInductionVC.h"


@interface UserList ()
{
    NSDictionary *visitorDetails;
    NSMutableArray *visitorDetailArr;
    int selIndex;
}
@end

@implementation UserList

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"User List" parameters:@{@"onload": @"11"}];
    [_btnNewVIsitor applyBlueShedow];
    [_btnCancel applyGrayTheme];
    _lblHeader.textColor = kGetHomeLabelColor;
    
    if ([Common appDelegate].isIpad)
    {
        [self.view viewWithTag:5502].frame=CGRectMake(10, 100,self.view.frame.size.width/2-20,self.view.frame.size.height-186);
        
        _userPic.layer.cornerRadius=3.0f;
        _userPic.clipsToBounds=YES;
        
        [_btnContiue applyBlueShedow];
        visitorDetailArr=[[NSMutableArray alloc] init];
        
        [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
        [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
        
        CGRect bvf=[self.view viewWithTag:5501].frame;
        bvf.origin.x=self.view.frame.size.width/2+10;
        bvf.size.width=self.view.frame.size.width/2-20;
        [self.view viewWithTag:5501].frame=bvf;
        
        CGRect btncontframe=_btnNewVIsitor.frame;
        btncontframe.origin.x=self.view.frame.size.width/2+10;
        btncontframe.size.width=self.view.frame.size.width/2-20;
        _btnNewVIsitor.frame=btncontframe;
        
        CGRect btncancelframe=_btnCancel.frame;
        btncancelframe.origin.x=self.view.frame.size.width/2+10;
        btncancelframe.size.width=self.view.frame.size.width/2-20;
        _btnCancel.frame=btncancelframe;
        visitorDetails=[_visitorArray objectAtIndex:0];
        [self genrateArray:visitorDetails];

//        [_tbInfoList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    [Common setBgImage:self.view useDefault:YES];
    [Common applyThemeColorToPowerdBy:self.view];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;//@"VISITOR SIGN IN";
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

- (IBAction)onNewVisitor:(id)sender
{
    UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
    vc.visitorDetails=nil;
    vc.isUpdate=NO;
    vc.navTitle = self.navTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCancelClick:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    
    if (tableView.tag==101)
    {
        return [_visitorArray count];
    }
    else
    {
        return [visitorDetailArr count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (tableView.tag==101)
    {
        static NSString *cellIdentifier = @"cellID";
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:
                    UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UILabel *lbFirstName= (UILabel *) [cell.contentView viewWithTag:1001];
        UILabel *lbOrganisation= (UILabel *) [cell.contentView viewWithTag:1002];
        lbFirstName.text = [NSString stringWithFormat:@"%@ %@",[[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"firstName"],[[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"lastName"]];
        lbOrganisation.text = [[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"organisation"];
        
        UIButton *btnSelect= (UIButton *) [cell.contentView viewWithTag:1003];
        [btnSelect applyBlueBorderShedow];
        [btnSelect addTarget:self action:@selector(selectOnclick:) forControlEvents:UIControlEventTouchUpInside];
        if ([Common appDelegate].isIpad)
        {
            if (selIndex==indexPath.row)
            {
                [btnSelect applyBlueShedow];
            }
            else
            {
                [btnSelect applyBlueBorderShedow];
            }
        }
        [btnSelect.titleLabel setFont:kThemeRegularFonts(14.0)];
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        static NSString *cellIdentifier = @"CellDetialID";
        cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:
                    UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UILabel *lbTitle= (UILabel *) [cell.contentView viewWithTag:1101];
        UILabel *lbValue= (UILabel *) [cell.contentView viewWithTag:1102];
        int viewWidth=tableView.frame.size.width;
        int cellHight=40;
        lbTitle.frame=CGRectMake(20,0, viewWidth*0.5-20,cellHight);
        lbValue.frame=CGRectMake(lbTitle.frame.origin.x+lbTitle.frame.size.width,0, viewWidth*0.5,cellHight);
        
        
        [lbTitle applyUITheme:kThemeGreyValue(255.0)];
        [lbValue applyUITheme:kThemeGreyValue(255.0)];
        
        lbTitle.text = [[visitorDetailArr objectAtIndex:indexPath.row] valueForKey:@"title"];
        lbValue.text = [[visitorDetailArr objectAtIndex:indexPath.row] valueForKey:@"value"];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)selectOnclick:(id)sender {
    
    UIView *aView = (UIView *)sender;
    while(aView != nil) {
        if([aView isKindOfClass:[UITableViewCell class]]) {
            
            UITableViewCell  *cell = (UITableViewCell *) aView;
            NSIndexPath * indexpath = [self.tbInfoList indexPathForCell:cell];
            
            if ([Common appDelegate].isIpad) {
                visitorDetails=[_visitorArray objectAtIndex:indexpath.row];
                selIndex=(int)indexpath.row;
                [self genrateArray:visitorDetails];
                [self.tbInfoList reloadData];
            }
            else {
                visitorDetails = [_visitorArray objectAtIndex:(long)indexpath.row];
                [self moveToNextPage:visitorDetails];
            }
            break;
        }
        aView = aView.superview;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (tableView.tag==101)
    {
        visitorDetails=[_visitorArray objectAtIndex:indexPath.row];
        selIndex=(int)indexPath.row;
        [self genrateArray:visitorDetails];
        if ([Common appDelegate].isIpad)
        {
            [tableView reloadData];
        }
//        UITableViewCell *cell=[_tbInfoList cellForRowAtIndexPath:indexPath];
//        [cell.contentView setBackgroundColor:[UIColor clearColor]];
//        [cell setBackgroundColor:[UIColor clearColor]];
//        [_tbInfoList setBackgroundColor:[UIColor clearColor]];
//        [_tbInfoList performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
    }
}
- (IBAction)onContinue:(id)sender {
    
    [self moveToNextPage:visitorDetails];
}
- (void)genrateArray:(NSDictionary *)userDic
{
    [visitorDetailArr removeAllObjects];
    [self getKeyValueDic:userDic andKey:@"firstName" needKey:@"First Name:"];
    [self getKeyValueDic:userDic andKey:@"lastName" needKey:@"Last Name:"];
    [self getKeyValueDic:userDic andKey:@"organisation" needKey:@"Company:"];
    [self getKeyValueDic:userDic andKey:@"phone" needKey:@"Phone:"];
    [self getKeyValueDic:userDic andKey:@"vehicleRegistrationNumber" needKey:@"Vehicle:"];
    if ([userDic objectForKey:@"photoUri"])
    {
        _userPic.image=[Common decodeBase64ToImage:[userDic objectForKey:@"photoUri"]];
    }
    [_tbUserDetail reloadData];
    [_tbUserDetail performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
}
-(void)getKeyValueDic:(NSDictionary *)sourceDic andKey:(NSString *)key needKey:(NSString *)displayKey
{
    if ([sourceDic valueForKey:key])
    {
        NSString *val = [sourceDic valueForKey:key];
        NSString *newVal = [Common GetMaskedIfPhone:[sourceDic valueForKey:key] forKay:key];
        [visitorDetailArr addObject:@{@"title": displayKey, @"value": newVal}];
     //   [visitorDetailArr addObject:[[NSDictionary alloc] initWithObjectsAndKeys:displayKey,@"title",val,@"value", nil]];
    }
}

-(void)moveToNextPage:(NSDictionary *)visitorDetails {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:visitorDetails];
    [data setObject:@"1" forKey:KEY_FROM_SEARCH];
    UserRegistrationVC *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"UserRegistrationVC"];
    vc.visitorDetails = data;
//    vc.isUpdate=YES;
    vc.navTitle = self.navTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
