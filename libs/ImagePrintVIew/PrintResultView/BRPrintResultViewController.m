//
//  BRPrintResultViewController.m
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

//#ifndef WLAN_ONLY
#import <BRLMPrinterKit/BRLMPrinterKit.h>
#import <BRLMPrinterKit/BRPtouchPrinter.h>
#import <BRLMPrinterKit/BRPtouchBluetoothManager.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#import <BRLMPrinterKitW/BRPtouchPrinter.h>
//#endif
#import <BRLMPrinterKit/BRLMPrinterKit.h>
#import "UserDefaults.h"
#import "BRLMUserDefaults.h"
#import "BRPrintResultViewController.h"
#import "BRWLANPrintOperation.h"
#import "BRBluetoothPrintOperation.h"
#import "UIButton+Additions.h"
#import "BRFileManager.h"

@interface BRPrintResultViewController ()
{
    BRLMChannel	*_ptp;
//    BRPtouchPrinter *_ptp;
    NSTimer *timer;
    int waitSecond;
    NSString *successString;
    NSMutableArray *base64Image;
    int nextPrintIndex;
}
@property(nonatomic, weak) IBOutlet UILabel *communicationResultLabel;
@property(nonatomic, weak) IBOutlet UILabel *sendDataLabel;
@property(nonatomic, weak) IBOutlet UILabel *printResultLabel;
@property(nonatomic, weak) IBOutlet UILabel *batteryPowerLabel;

@property(nonatomic, strong) NSOperationQueue           *queueForWLAN;
@property(nonatomic, strong) BRWLANPrintOperation       *operationForWLAN;
@property(nonatomic, strong) NSOperationQueue           *queueForBT;
@property(nonatomic, strong) BRBluetoothPrintOperation  *operationForBT;

@property(nonatomic, strong) NSString *bytesWrittenMessage;
@property(nonatomic, strong) NSNumber *bytesWritten;
@property(nonatomic, strong) NSNumber *bytesToWrite;

@property(nonatomic, assign) BRLMChannelType type;

@end

@implementation BRPrintResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.hidesBackButton = YES;
    //OLD START//
    //card//
    waitSecond=11;
    [Common loadLogo:((AsyncImageView *)[self.view viewWithTag:3301])];
    if ([[Common appDelegate] isIpad])
    {
        _vadidateButton.titleLabel.font = [UIFont systemFontOfSize:30.0];
    }
    else
    {
        _vadidateButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        if(_vadidateButton.frame.size.width<=320)
        {
            _vadidateButton.titleLabel.font=[_vadidateButton.titleLabel.font fontWithSize:10];
        }
    }
    //FIXME: Crash related to iOS 15
    _vadidateButton.tintColor = [UIColor whiteColor];
    [_homeButton applyBlueShedow];
    
    if (self.isReprint)
    {
        successString = [NSString stringWithFormat:@"Please collect your visiting card from the printer.\n\nRedirecting back to main screen in…"];
    }
    else
    {
        successString = [NSString stringWithFormat:@"%@\n\nRedirecting back to main screen in…",[[Common SiteData] valueForKey:KEY_SignInCompletionMessage]];
    }
    
    
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height-64>540?self.view.frame.size.height-64:540);
    self.tpscrollview.contentSize = CGSizeMake(self.view.frame.size.width,_contentView.frame.size.height);
    
    _lbInstruction.font=kThemeRegularFonts([Common appDelegate].isIpad?24:14);
    _lbInstruction.text=successString;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
    
    [Common ApplyUIViewTheme:[self.view viewWithTag:5502]];
    [self.view viewWithTag:5502].backgroundColor=kThemeBGGrey;
    [Common applyThemeColorToPowerdBy:self.view];
    
    base64Image=[[NSMutableArray alloc] init];
    NSArray *base64Arr = self.isReprint ? [_visitorDetails valueForKey:@"bitmaps"] : [_visitorDetails valueForKey:@"stickerBitmaps"];
    
    if ([_visitorDetails valueForKey:@"istest"])
    {
        [base64Image addObject:[UIImage imageNamed:@"testprint.png"]];
    }
    else
    {
        for (int i=0; i<[base64Arr count]; i++)
        {
            UIImage *img=[Common decodeBase64ToImage:[base64Arr objectAtIndex:i]];
            [base64Image addObject:img];
        }
    }
    self.imagePathArray = [[NSMutableArray alloc] init];
    for (UIImage *image in base64Image) {
        NSString *path;
        BOOL success = [self saveImage:image path:&path];
        if (success) {
            [self.imagePathArray addObject:path];
        }
    }
    //card end//
    if ([base64Image count]<=0)
    {
        [_vadidateButton setImage:nil forState:UIControlStateNormal];
        [_vadidateButton setTitle:self.isReprint ? @"Reprinting Sticker" : @"Sign in successful." forState:UIControlStateNormal];
    }
    else
    {
        nextPrintIndex=0;
        [self proceedForPrinter];
    }
    self.menuContainerViewController.panMode=MFSideMenuPanModeNone;
    [Common setBgImage:self.view useDefault:YES];
    //OLD END//
}

- (BOOL)saveImage:(UIImage *)image path:(NSString **)path {
    BRFileManager *manager = BRFileManager.sharedManager;
    *path = [manager generateTemporaryPath:@"png"];
    return [manager saveImage:image path:*path];
}

- (void)removeSelectedImages {
    BRFileManager *manager = BRFileManager.sharedManager;
    for (NSString *path in self.imagePathArray) {
        [manager removeFile:path];
    }
    [self.imagePathArray removeAllObjects];
}

- (void)proceedForPrinter {
    NSLog(@"%s", __func__);
    if (nextPrintIndex>=[base64Image count] || nextPrintIndex==-2)
    {
        NSLog(@"Returned from: if (nextPrintIndex>=[base64Image count] || nextPrintIndex==-2)");
        return;
    }
    
    if (![[_visitorDetails valueForKey:kPrinterStatus] boolValue])
    {
        nextPrintIndex=-2;
        NSLog(@"Returned from: if (![[_visitorDetails valueForKey:kPrinterStatus] boolValue])");
        return;
    }

    self.communicationResultLabel.text = @"Communication Result : ";
    self.bytesWritten = [NSNumber numberWithInt:0];
    self.bytesToWrite = [NSNumber numberWithInt:0];
    self.sendDataLabel.text = [NSString stringWithFormat:@"Send Data : %@/%@",self.bytesWritten, self.bytesToWrite];
    self.printResultLabel.text = @"Print Result : ";
    self.batteryPowerLabel.text = @"Battery Power : ";
    self.type = BRLMChannelTypeWiFi;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedDevice = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths lastObject];
    
    NSString *ipAddress     = [userDefaults stringForKey:kIPAddress];
    NSString *serialNumber  = [userDefaults stringForKey:kSerialNumber];
    NSString *advertiseLocalName  = [userDefaults stringForKey:kAdvertiseLocalName];
    
    if ([userDefaults integerForKey:kIsWiFi] == 0 && [userDefaults integerForKey:kIsBluetooth] == 1 && [userDefaults integerForKey:kIsBLE] == 0){
        self.type = BRLMChannelTypeBluetoothMFi;
        selectedDevice = [NSString stringWithFormat:@"%@",[userDefaults stringForKey:kSelectedDeviceFromBluetooth]];
        _ptp = [[BRLMChannel alloc] initWithBluetoothSerialNumber:serialNumber];
    }
    else if ([userDefaults integerForKey:kIsWiFi] == 1 && [userDefaults integerForKey:kIsBluetooth] == 0 && [userDefaults integerForKey:kIsBLE] == 0){
        self.type = BRLMChannelTypeWiFi;
        selectedDevice = [NSString stringWithFormat:@"%@", [userDefaults stringForKey:kSelectedDeviceFromWiFi]];
        _ptp = [[BRLMChannel alloc] initWithWifiIPAddress:ipAddress];
    }
    else if ([userDefaults integerForKey:kIsWiFi] == 0 && [userDefaults integerForKey:kIsBluetooth] == 0 && [userDefaults integerForKey:kIsBLE] == 1){
        self.type = BRLMChannelTypeBluetoothLowEnergy;
        selectedDevice = [NSString stringWithFormat:@"%@", [userDefaults stringForKey:kSelectedDeviceFromBLE]];
        _ptp = [[BRLMChannel alloc] initWithBLELocalName:advertiseLocalName];
    }
    else{
//        NSAssert(false, @"BRLMChannelType error");
    }


    // PrintInfo
    id<BRLMPrintSettingsProtocol> setting = [self getPrintInfoWithDeviceName:selectedDevice];
//    id<BRLMPrintSettingsProtocol> setting = [[brlsettings alloc] initDefaultPrintSettingsWithPrinterModel:model]
    [self initWithNotificationObserver];
    
    switch (self.type)
    {
        case BRLMChannelTypeWiFi:
        {
            self.queueForWLAN = [[NSOperationQueue alloc] init];
            self.operationForWLAN = [[BRWLANPrintOperation alloc] initWithOperation:_ptp
                                                                          printInfo:setting
                                                                             images:self.imagePathArray
                                                                          ipAddress:ipAddress];
            [self.operationForWLAN addObserver:self
                                    forKeyPath:@"isFinishedForWLAN"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
            
            [self.operationForWLAN addObserver:self
                                    forKeyPath:@"communicationResultForWLAN"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
            
            self.operationForWLAN.delegate = self;
            
            [self.queueForWLAN addOperation:self.operationForWLAN];
        }
            break;
            
        case BRLMChannelTypeBluetoothMFi:
//#ifndef WLAN_ONLY
        {
            NSArray *pairedDevices = [NSArray arrayWithArray:[[BRPtouchBluetoothManager sharedManager] pairedDevices]];
            if (pairedDevices == nil) {
                NSLog(@"No Bluetooth Device Connected !!");
            }
            else {
                self.queueForBT = [[NSOperationQueue alloc] init];
                self.operationForBT = [[BRBluetoothPrintOperation alloc] initWithOperation:_ptp
                                                                                 printInfo:setting
                                                                                    images:self.imagePathArray
                                                                              serialNumber:serialNumber];

                [self.operationForBT addObserver:self
                                      forKeyPath:@"isFinishedForBT"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
                
                [self.operationForBT addObserver:self
                                      forKeyPath:@"communicationResultForBT"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
                
                self.operationForBT.delegate = self;
                
                [self.queueForBT addOperation:self.operationForBT];
            }
        }
//#endif
            break;
            
        case BRLMChannelTypeBluetoothLowEnergy:
        {
            /*
            self.queueForBLE = [[NSOperationQueue alloc] init];
            self.operationForBLE = [[BRBLEPrintOperation alloc] initWithOperation:_ptp
                                                                        printInfo:setting
                                                                           images:self.imagePathArray
                                                               advertiseLocalName:advertiseLocalName];
            [self.operationForBLE addObserver:self
                                    forKeyPath:@"isFinishedForBLE"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
            
            [self.operationForBLE addObserver:self
                                    forKeyPath:@"communicationResultForBLE"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
            
            self.operationForBLE.delegate = self;
            
            [self.queueForBLE addOperation:self.operationForBLE];
            */
        }
            break;
            
        default:
            NSLog(@"self.type value not found. Called default function");
            break;
    }

}

-(void)updateBackground
{
    [Common setBgImage:self.view useDefault:YES];
}

- (id<BRLMPrintSettingsProtocol>)getPrintInfoWithDeviceName:(NSString*)selectedDevice {
    BRLMPrinterModel model = [BRLMPrinterClassifier transferEnumFromString:selectedDevice];
    BRLMPrinterClassifierSeries series = [BRLMPrinterClassifier classifyPrinterSerieseFromModel:model];
    id<BRLMPrintSettingsProtocol> setting;
    switch (series) {
        case BRLMPrinterClassifierSeriesMW:
            setting = [[BRLMUserDefaults sharedDefaults].mwSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMMWPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesPJ:
            setting = [[BRLMUserDefaults sharedDefaults].pjSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMPJPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesRJ:
            setting = [[BRLMUserDefaults sharedDefaults].rjSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMRJPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesTD:
            setting = [[BRLMUserDefaults sharedDefaults].tdSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMTDPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesPT:
            setting = [[BRLMUserDefaults sharedDefaults].ptSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMPTPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesQL:
            setting = [[BRLMUserDefaults sharedDefaults].qlSettings copyWithPrinterModel:model];
            if (setting == nil) {
                setting = [[BRLMQLPrintSettings alloc] initDefaultPrintSettingsWithPrinterModel:model];
            }
            break;
        case BRLMPrinterClassifierSeriesUnknown:
            NSAssert(false, @"BRLMPrinterClassifierSeriesUnknown");
            break;
    }

    return setting;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.navTitle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upadteTime)
                                                 name:N_UpdateTime
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBackground)
                                                 name:N_UpdateBackgroundImages
                                               object:nil];
    [self upadteTime];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotificationObserver];
    self.navigationItem.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateTime object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_UpdateBackgroundImages object:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)upadteTime
{
    [Common updateTime:self.view];
//    UILabel *lableTime=[mainVCView viewWithTag:5214];
//    if (lableTime) {
//        [lableTime setTextColor:kGetHomeLabelColor];
//    }
}

-(void)timerCalled
{
    NSLog(@"Timer %d",waitSecond);
    waitSecond--;
    
    if (waitSecond<0)
    {
        [self onHome:nil];
    }
    else
    {
        _lbInstruction.text=[NSString stringWithFormat:@"%@%d sec",successString,waitSecond];
        _lbInstruction.font=kThemeRegularFonts([Common appDelegate].isIpad?24:16);
        _lbInstruction.numberOfLines=10;
        
        NSString *dataString=[NSString stringWithFormat:@"%@%d sec",successString,waitSecond];
        NSRange range = [dataString rangeOfString:[NSString stringWithFormat:@"%d",waitSecond]];
        UIFont *font = kThemeRegularFonts([Common appDelegate].isIpad?24:16);
        UIColor *fontColor = kThemeBlueColor;
        NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:dataString];
        
        [dateAttributedString addAttribute:NSFontAttributeName
                                     value:fontColor
                                     range:range];
        [dateAttributedString addAttribute:NSFontAttributeName
                                     value:font
                                     range:range];
        _lbInstruction.attributedText=dateAttributedString;
    }
}

- (IBAction)onHome:(id)sender
{
    [timer invalidate];
    timer = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"isFinishedForWLAN"])
    {
        self.queueForWLAN = nil;
        [self.operationForWLAN removeObserver:self forKeyPath:@"isFinishedForWLAN"];
        [self.operationForWLAN removeObserver:self forKeyPath:@"communicationResultForWLAN"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.view reloadInputViews];
        });
    }
    else if ([keyPath isEqualToString:@"isFinishedForBT"])
    {
        self.queueForBT = nil;
        [self.operationForBT removeObserver:self forKeyPath:@"isFinishedForBT"];
        [self.operationForBT removeObserver:self forKeyPath:@"communicationResultForBT"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.view reloadInputViews];
        });
    }
    else if ([keyPath isEqualToString:@"isFinishedForBLE"])
    {
        /*
        self.queueForBLE = nil;
        [self.operationForBLE removeObserver:self forKeyPath:@"isFinishedForBLE"];
        [self.operationForBLE removeObserver:self forKeyPath:@"communicationResultForBLE"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.view reloadInputViews];
        });
        */
    }
    else if ([keyPath isEqualToString:@"communicationResultForWLAN"])
    {
        BOOL result = _operationForWLAN.communicationResultForWLAN;
        if (!result) {
            self.queueForWLAN = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.communicationResultLabel.text = [NSString stringWithFormat:@"Communication Result : %d",result];
            [self.view reloadInputViews];
        });
    }
    else if ([keyPath isEqualToString:@"communicationResultForBT"])
    {
        BOOL result = _operationForBT.communicationResultForBT;
        if (!result) {
            self.queueForBT = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.communicationResultLabel.text = [NSString stringWithFormat:@"Communication Result : %d",result];
            [self.view reloadInputViews];
        });
    }
    else if ([keyPath isEqualToString:@"communicationResultForBLE"])
    {
        /*
        BOOL result = _operationForBLE.communicationResultForBLE;
        if (!result) {
            self.queueForBLE = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.communicationResultLabel.text = [NSString stringWithFormat:@"Communication Result : %d",result];
            [self.view reloadInputViews];
        });
        */
    }
}

#pragma mark - Notification (for Progress)

- (void) initWithNotificationObserver
{
    self.bytesWrittenMessage = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bytesWrittenNotification:)
                                                 name:BRWLanConnectBytesWrittenNotification
                                               object:nil];
    
//#ifndef WLAN_ONLY
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bytesWrittenNotification:)
                                                 name:BRBluetoothSessionBytesWrittenNotification
                                               object:nil];
//#endif
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(bytesWrittenNotification:)
//                                                 name:BRBLEBytesWrittenNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bytesWrittenNotification:)
                                                 name:BRPtouchPrinterKitMessageNotification
                                               object:nil];
}

- (void) removeNotificationObserver
{
    self.bytesWrittenMessage = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BRWLanConnectBytesWrittenNotification
                                                  object:nil];
    
//#ifndef WLAN_ONLY
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BRBluetoothSessionBytesWrittenNotification
                                                  object:nil];
//#endif
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:BRBLEBytesWrittenNotification
//                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BRPtouchPrinterKitMessageNotification
                                                  object:nil];
    
    self.queueForWLAN = nil;
    self.queueForBT = nil;
    @try {
        [self.operationForWLAN removeObserver:self forKeyPath:@"isFinishedForWLAN"];
        [self.operationForWLAN removeObserver:self forKeyPath:@"communicationResultForWLAN"];
        
        [self.operationForBT removeObserver:self forKeyPath:@"isFinishedForBT"];
        [self.operationForBT removeObserver:self forKeyPath:@"communicationResultForBT"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.view reloadInputViews];
        });
    }
    @catch(id anException) {
        
    }
}

- (void) bytesWrittenNotification: (NSNotification *)notification
{
    NSString *msgStr = [notification.userInfo objectForKey:@"message"];
    if (msgStr){
        self.bytesWrittenMessage = msgStr;
        NSLog(@"*** message = %@", self.bytesWrittenMessage);
    }
    
    if ([self.bytesWrittenMessage isEqualToString:@"MESSAGE_START_SEND_DATA"])
    {
        self.bytesWritten = [notification.userInfo objectForKey:@"bytesWritten"];
        self.bytesToWrite = [notification.userInfo objectForKey:@"bytesToWrite"];
        NSLog(@"Send Data: %d/%d(byte)", [self.bytesWritten intValue], [self.bytesToWrite intValue]);

        dispatch_async(dispatch_get_main_queue(), ^{
            self.sendDataLabel.text = [NSString stringWithFormat:@"Send Data : %d/%d", [self.bytesWritten intValue], [self.bytesToWrite intValue]];
            [self.view reloadInputViews];
        });
    }
    else if ([self.bytesWrittenMessage isEqualToString:@"MESSAGE_END_SEND_DATA"])
    {
            self.bytesWritten = 0;
            self.bytesToWrite = 0;
    }
    else if ([self.bytesWrittenMessage isEqualToString:@"MESSAGE_END_READ_PRINTER_STATUS"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController reloadInputViews];
        });
    }
    else if ([self.bytesWrittenMessage isEqualToString:@"MESSAGE_PRINT_ERROR"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.navigationController reloadInputViews];
        });
    }
}

- (void) showPrintResultForWLAN
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        if (self.type == BRLMChannelTypeWiFi) {
            self.printResultLabel.text  = [NSString stringWithFormat:@"Print Result  : %@", [userDefaults stringForKey:kPrintResultForWLAN]];
            self.batteryPowerLabel.text = [NSString stringWithFormat:@"Battery Power : %@", [userDefaults stringForKey:kPrintStatusBatteryPowerForWLAN]];
            [self.printResultLabel reloadInputViews];
            
//            nextPrintIndex=nextPrintIndex+1;
//            [self proceedForPrinter];
        }
    });
}

- (void) showPrintResultForBluetooth
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        if  (self.type == BRLMChannelTypeBluetoothMFi) {
            self.printResultLabel.text  = [NSString stringWithFormat:@"Print Result  : %@", [userDefaults stringForKey:kPrintResultForBT]];
            self.batteryPowerLabel.text = [NSString stringWithFormat:@"Battery Power : %@", [userDefaults stringForKey:kPrintStatusBatteryPowerForBT]];
            
//            nextPrintIndex=nextPrintIndex+1;
//            [self proceedForPrinter];
        }
    });
}

- (void) showPrintResultForBLE
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        if (self.type == BRLMChannelTypeBluetoothLowEnergy) {
            self.printResultLabel.text  = [NSString stringWithFormat:@"Print Result  : %@", [userDefaults stringForKey:kPrintResultForBLE]];
            self.batteryPowerLabel.text = [NSString stringWithFormat:@"Battery Power : %@", [userDefaults stringForKey:kPrintStatusBatteryPowerForBLE]];
            
//            nextPrintIndex=nextPrintIndex+1;
//            [self proceedForPrinter];
        }
    });
}

@end
