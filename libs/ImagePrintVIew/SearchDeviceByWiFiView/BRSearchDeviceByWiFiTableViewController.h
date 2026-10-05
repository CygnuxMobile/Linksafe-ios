//
//  BRSearchDeviceByWiFiViewControllerTableViewController.h
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BRLMPrinterKit/BRPtouchNetworkManager.h>

typedef enum BRSearchMode : NSInteger
{
    BRSearchModeIPv4,
    BRSearchModeIPv6IPv4,
} BRSearchMode;

@interface BRSearchDeviceByWiFiTableViewController : UITableViewController <BRPtouchNetworkDelegate>

@property (assign, nonatomic) BRSearchMode mSearchMode;

@property(nonatomic,copy)callbackwithDic  didFinishwithSearch;

@end
