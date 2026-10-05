//
//  BRLMPrintSettingsValidateViewController.h
//  SDK_Sample_Ver2
//
//  Created by Yu Matsuo on 27/2/20.
//

#import <UIKit/UIKit.h>
//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRLMPrinterKit.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#endif

NS_ASSUME_NONNULL_BEGIN

@interface BRLMPrintSettingsValidateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) BRLMValidatePrintSettingsReport* report;
@end

NS_ASSUME_NONNULL_END
