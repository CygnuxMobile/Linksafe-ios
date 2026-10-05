//
//  BRWLANPrintOperation.h
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
#import <BRLMPrinterKit/BRLMPrinterKit.h>
@protocol BRWLANPrintOperationDelegate <NSObject>
- (void) showPrintResultForWLAN;
@end

@interface BRWLANPrintOperation : NSOperation
{
}
@property (nonatomic, weak)id<BRWLANPrintOperationDelegate> delegate;
@property(nonatomic, assign) BOOL communicationResultForWLAN;

- (id)initWithOperation:(BRLMChannel *)targetPtp
              printInfo:(id<BRLMPrintSettingsProtocol>)targetPrintInfo
                 images:(NSArray *)targetImgPathArray
              ipAddress:(NSString *)targetIPAddress;

@end

