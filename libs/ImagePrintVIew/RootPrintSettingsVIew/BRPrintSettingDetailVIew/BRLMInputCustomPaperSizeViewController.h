//
//  BRLMInputCustomPaperSizeViewController.h
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

@interface BRLMInputCustomPaperSizeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) BRLMCustomPaperSize* defaultSize;
@property (nonatomic) void (^decisionHandler)(BRLMCustomPaperSize* customPaperSize);
@end

NS_ASSUME_NONNULL_END
