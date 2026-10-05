//
//  SettingView.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 24/11/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SettingView : UIViewController<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lbCamera;
@property (strong, nonatomic) IBOutlet UILabel *lbQRCode;
@property (strong, nonatomic) IBOutlet UILabel *lbPrinter;
@property (strong, nonatomic) IBOutlet UILabel *lbPrinterIp;
@property (strong, nonatomic) IBOutlet UIView *viewSetting;
@property (strong, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UIView *viewTouchID;
@property (weak, nonatomic) IBOutlet UISwitch *swichTouchID;

- (IBAction)onSwitchCamera:(id)sender;
- (IBAction)onSelectBarcode:(id)sender;
- (IBAction)onSelectPrinter:(id)sender;

- (IBAction)onSwitchClicked:(id)sender;
- (IBAction)ChangedOnOff:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *viewPrinters;

@end
