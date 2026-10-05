//
//  BRLMUserDefaults.h
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRLMPrinterKit.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#endif

NS_ASSUME_NONNULL_BEGIN

@interface BRLMUserDefaults : NSObject

@property (nonatomic, nullable) BRLMQLPrintSettings* qlSettings;
@property (nonatomic, nullable) BRLMPTPrintSettings* ptSettings;
@property (nonatomic, nullable) BRLMPJPrintSettings* pjSettings;
@property (nonatomic, nullable) BRLMMWPrintSettings* mwSettings;
@property (nonatomic, nullable) BRLMTDPrintSettings* tdSettings;
@property (nonatomic, nullable) BRLMRJPrintSettings* rjSettings;

+ (BRLMUserDefaults*) sharedDefaults;
@end

NS_ASSUME_NONNULL_END
