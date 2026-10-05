//
//  BRLMPrintSettingTableViewController.h
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRLMPrinterKit.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#endif

NS_ASSUME_NONNULL_BEGIN

@interface BRLMPrintSettingTableViewController : UITableViewController

@property (nonatomic) NSArray<NSString*>* properties;
@property (nonatomic) BRLMQLPrintSettings* qlSettings;
@property (nonatomic) BRLMPTPrintSettings* ptSettings;
@property (nonatomic) BRLMPJPrintSettings* pjSettings;
@property (nonatomic) BRLMMWPrintSettings* mwSettings;
@property (nonatomic) BRLMTDPrintSettings* tdSettings;
@property (nonatomic) BRLMRJPrintSettings* rjSettings;
@end

NS_ASSUME_NONNULL_END
