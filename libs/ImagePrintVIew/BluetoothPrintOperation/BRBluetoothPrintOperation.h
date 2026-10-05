//
//  BRBluetoothPrintOperation.h
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

@protocol BRBluetoothPrintOperationDelegate <NSObject>
- (void) showPrintResultForBluetooth;
@end

@interface BRBluetoothPrintOperation : NSOperation
{
}
@property (nonatomic, weak)id<BRBluetoothPrintOperationDelegate> delegate;
@property(nonatomic, assign) BOOL communicationResultForBT;

- (id)initWithOperation:(BRLMChannel *)targetPtp
              printInfo:(id<BRLMPrintSettingsProtocol>)targetPrintInfo
                 images:(NSArray *)targetImgPathArray
           serialNumber:(NSString *)targetSerialNumber;

@end
