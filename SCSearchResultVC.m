//
//  SCSearchResultVC.m
//  LinkSafe
//
//  Created by Kiran on 9/11/20.
//  Copyright © 2020 Vladislav Kovalyov. All rights reserved.
//

#import "SCSearchResultVC.h"
#import "UIButton+Additions.h"
#import "SCSearchResultTableViewCell.h"
#import "SCValidateContractorVC.h"

@interface SCSearchResultVC () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SCSearchResultVC

+(SCSearchResultVC *)viewController {
    
    SCSearchResultVC *vc = [[Common constraintStoryboard] instantiateViewControllerWithIdentifier:@"SCSearchResultVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Search" parameters:@{@"onload": @"18"}];
    // Do any additional setup after loading the view.
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    
    _lblHeader.textColor = kGetHomeLabelColor;
    
    [_btnValidate applyBlueShedow];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [Common applyThemeColorToPowerdBy:self.view];
    
    _tblUsers.delegate = self;
    _tblUsers.dataSource = self;
    _tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.totalWorkers > self.arrWorkers.count) {
        [Common showWarning:@"Your search returned too many results – please refine your search terms." :@""];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    [self upadteTime];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];
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

-(void)upadteTime
{
    [Common updateTime:self.view];
}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (IBAction)onValidateButtonClick:(id)sender {
    
}

#pragma mark - UITableView Datasource & Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrWorkers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SCSearchResultTableViewCell";
    SCSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [cell configureCell:[_arrWorkers objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SCValidateContractorVC *vc = [SCValidateContractorVC viewController];
    vc.strSelectedSiteId = _strSelectedSiteId;
    vc.userDetails = [_arrWorkers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:true];
}

@end
