//
//  VisitorSignOutMultiUser.m
//  LinkSafe
//
//  Created by uday on 14/12/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import "VisitorSignOutMultiUser.h"
#import "VisitorSignOutMultiUserStepTwo.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"

@interface VisitorSignOutMultiUser ()
{
    NSDictionary *visitorDetails;
    NSMutableArray *visitorDetailArr;
    int selIndex;
}

@end

@implementation VisitorSignOutMultiUser

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Visitor SignOut Multi User" parameters:@{@"onload": @"44"}];
    self.lblHeader.textColor = kGetHomeLabelColor;
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    
    [Common setBgImage:self.view useDefault:YES];
    
    _tbUserDetail.layer.cornerRadius=3.0f;
    _tbUserDetail.clipsToBounds=YES;
    
    if ([Common appDelegate].isIpad)
    {
        [self.view viewWithTag:5502].frame=CGRectMake(10, 100,self.view.frame.size.width/2-20,self.view.frame.size.height-320);
        
        _imgUserPic.layer.cornerRadius=3.0f;
        _imgUserPic.clipsToBounds=YES;

        [_btnCancel applyGrayTheme];
        [_btnItsMe applyBlueShedow];
        
        visitorDetailArr=[[NSMutableArray alloc] init];
        
        [Common ApplyUIViewTheme:[self.view viewWithTag:5501]];
        [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
        
        CGRect bvf=[self.view viewWithTag:5501].frame;
        bvf.origin.x=self.view.frame.size.width/2+10;
        bvf.size.width=self.view.frame.size.width/2-20;
        [self.view viewWithTag:5501].frame=bvf;
        
        visitorDetails=[_visitorArray objectAtIndex:0];
        [self genrateArray:visitorDetails];
        
        [_tbUserDetail selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    else {
        [_btnCancel applyGrayTheme];
        [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
    }
    [Common applyThemeColorToPowerdBy:self.view];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=[NSString stringWithFormat:@"%@ SIGN OUT", self.navTitle];//@"VISITOR SIGN OUT";
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
-(void)upadteTime
{
    [Common updateTime:self.view];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
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
        NSString *firstName = [[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"firstName"];
        NSString *lastName = [[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"lastName"];
        if (firstName.length > 0 && lastName.length > 0) {
            lbFirstName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        else if (firstName.length > 0) {
            lbFirstName.text = firstName;
        }
        else if (lastName.length > 0) {
            lbFirstName.text = lastName;
        }
        else {
            lbFirstName.text = @"";
        }
        lbOrganisation.text = [[_visitorArray objectAtIndex:indexPath.row] valueForKey:@"organisation"];
        
        UIButton *btnSelect= (UIButton *) [cell.contentView viewWithTag:1003];
        [btnSelect addTarget:self action:@selector(selectOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [btnSelect applyBlueBorderShedow];
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
        
       // if(indexPath.row%2==0)
      //  {
      //      cell.contentView.backgroundColor=kThemeGreyValue(238.0);
      //  }
     //   else
     //   {
    //        cell.contentView.backgroundColor=kThemeGreyValue(249.0);
      //  }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
                visitorDetails=[[_visitorArray objectAtIndex:indexpath.row] mutableCopy];
                selIndex=(int)indexpath.row;
                [self genrateArray:visitorDetails];
                [self.tbInfoList reloadData];
            }
            else {
                VisitorSignOutMultiUserStepTwo *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOutMultiUserStepTwo"];
                vc.navTitle = self.navTitle;
                vc.visitorDetails = [[_visitorArray objectAtIndex:(long)indexpath.row] mutableCopy];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        aView = aView.superview;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==101)
    {
        visitorDetails=[[_visitorArray objectAtIndex:indexPath.row] mutableCopy];
        selIndex=(int)indexPath.row;
        [self genrateArray:visitorDetails];
        if ([Common appDelegate].isIpad)
        {
            [tableView reloadData];
        }
    }
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
        _imgUserPic.image=[Common decodeBase64ToImage:[userDic objectForKey:@"photoUri"]];
    }
    [_tbUserDetail reloadData];
    [_tbUserDetail performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
}

-(void)getKeyValueDic:(NSDictionary *)sourceDic andKey:(NSString *)key needKey:(NSString *)displayKey
{
    if ([sourceDic valueForKey:key])
    {
        NSString *newVal = [Common GetMaskedIfPhone:[sourceDic valueForKey:key] forKay:key];
        [visitorDetailArr addObject:@{@"title": displayKey, @"value": newVal}];
//        [visitorDetailArr addObject:[[NSDictionary alloc] initWithObjectsAndKeys:displayKey,@"title",[sourceDic valueForKey:key],@"value", nil]];
    }
}





- (IBAction)onItsMeBtnClick:(id)sender {
    
    VisitorSignOutMultiUserStepTwo *vc = [[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"VisitorSignOutMultiUserStepTwo"];
    vc.visitorDetails = [visitorDetails mutableCopy];
    vc.navTitle = self.navTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
