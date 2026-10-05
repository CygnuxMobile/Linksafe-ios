//
//  BRSearchDeviceByWiFiViewControllerTableViewController.m
//  SDK_Sample_Ver2
//
//  Copyright (c) 2018 Brother Industries, Ltd. All rights reserved.
//

#import "UserDefaults.h"
#import "BRSearchDeviceByBLETableViewController.h"
//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRPtouchBLEManager.h>
//#else
//#import <BRLMPrinterKitW/BRPtouchBLEManager.h>
//#endif
#import <BRLMPrinterKit/BRLMPrinterKit.h>

@interface BRSearchDeviceByBLETableViewController ()
@property (nonatomic, strong) BRBLEManagerSearchCompletionHandler searchCompleionHandler;

@end

@implementation BRSearchDeviceByBLETableViewController
{
    NSMutableArray* deviceList;
    BRPtouchBLEManager* bleManager;
    UIActivityIndicatorView* indicator;
    UIView* loadingView;
}

- (void)searchPrinterAndUpdateTableView {
    [deviceList removeAllObjects];
    NSString* printListPath = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    NSDictionary* printerDict = [NSDictionary dictionaryWithContentsOfFile:printListPath];
    NSArray* supportPrintLists = printerDict.allKeys;
    
    // Start search.
    BRPtouchBLEManager *ptouchManager = [BRPtouchBLEManager sharedManager];
    [ptouchManager startSearchWithCompletionHandler:^(BRPtouchDeviceInfo *deviceInfo) {
        if (deviceInfo && deviceInfo.strModelName) {
            if ([supportPrintLists containsObject:deviceInfo.strModelName]) {
                [deviceList addObject:deviceInfo];
            }
        }
    }];

    // Wait for update deviceinformation.
    const NSTimeInterval pollingTime = 5.0;
    [NSThread sleepForTimeInterval:pollingTime];
    
    // Stop search.
    [bleManager stopSearch];
    
    // Update tableView.
    dispatch_async(dispatch_get_main_queue(), ^{
        [indicator stopAnimating];          //  stop indicator animation
        [indicator removeFromSuperview];    //  remove indicator view (indicator)
        [loadingView removeFromSuperview];  //  remove indicator view (view)
        
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    deviceList = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Create indicator View
    loadingView = [[UIView alloc] initWithFrame:[self.parentViewController.view bounds]];
    [loadingView setBackgroundColor:[UIColor blackColor]];
    [loadingView setAlpha:0.5];
    [self.parentViewController.view addSubview:loadingView];
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(140.0, 200, 40.0, 40.0);
    [self.parentViewController.view addSubview:indicator];
    
    // Start indicator animation
    [indicator startAnimating];
    
    // Start printer search(Sub thread)
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self searchPrinterAndUpdateTableView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    static NSString *eaAccessoryCellIdentifier = @"brotherDeviceCellIdentifier";
    
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:eaAccessoryCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:eaAccessoryCellIdentifier];
    }
    
    NSString *brotherDeviceName = [(BRPtouchDeviceInfo *)[deviceList objectAtIndex:row] strModelName];
    if (!brotherDeviceName || [brotherDeviceName isEqualToString:@""]) {
        brotherDeviceName = @"unknown";
    }
    
    [[cell textLabel] setText:brotherDeviceName];
    [[cell detailTextLabel] setText:[(BRPtouchDeviceInfo *)[deviceList objectAtIndex:row] strBLEAdvertiseLocalName]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    BRPtouchDeviceInfo *_selectedAccessory = (BRPtouchDeviceInfo *)[deviceList objectAtIndex:row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_selectedAccessory.strModelName forKey:kSelectedDevice];
    [userDefaults setObject:@"" forKey:kIPAddress];
    [userDefaults setObject:@"" forKey:kSerialNumber];
    [userDefaults setObject:_selectedAccessory.strBLEAdvertiseLocalName forKey:kAdvertiseLocalName];
    [userDefaults setObject:@"0" forKey:kIsWiFi];
    [userDefaults setObject:@"0" forKey:kIsBluetooth];
    [userDefaults setObject:@"1" forKey:kIsBLE];
    [userDefaults setObject:@"Search device from Wi-Fi" forKey:kSelectedDeviceFromWiFi];
    [userDefaults setObject:@"Search device from Bluetooth" forKey:kSelectedDeviceFromBluetooth];
    [userDefaults setObject:_selectedAccessory.strModelName forKey:kSelectedDeviceFromBLE];
    [userDefaults synchronize];
    
    /* Store Model Name and Serial Number */
    NSLog(@"Accessory.modelName[%@]", _selectedAccessory.strModelName);
    NSLog(@"Accessory.advertiseLocalName[%@]", _selectedAccessory.strBLEAdvertiseLocalName);
    
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
