//
//  BRWLANPrintOperation.m
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

#import "UserDefaults.h"
#import "BRWLANPrintOperation.h"
//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRLMPrinterKit.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#endif

@interface BRWLANPrintOperation ()
{
}
@property(nonatomic, assign) BOOL isExecutingForWLAN;
@property(nonatomic, assign) BOOL isFinishedForWLAN;


@property(nonatomic, strong) BRLMChannel    *channel;
@property(nonatomic, strong) BRLMPrinterDriver    *ptp;
@property(nonatomic, strong) id<BRLMPrintSettingsProtocol> printInfo;
@property(nonatomic, strong) NSArray *imagePathArray;
@property(nonatomic, strong) NSString           *ipAddress;
@property(nonatomic, strong) NSString           *customPaperFilePath;
@end

@implementation BRWLANPrintOperation

- (id)initWithOperation:(BRLMChannel *)targetPtp
              printInfo:(id<BRLMPrintSettingsProtocol>)targetPrintInfo
                 images:(NSArray *)targetImgPathArray
              ipAddress:(NSString *)targetIPAddress
{
    self = [super init];
    if (self) {
        self.channel        = targetPtp;
        self.printInfo      = targetPrintInfo;
        self.imagePathArray = targetImgPathArray;
        self.ipAddress      = targetIPAddress;
    }
    
    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key
{
    if ([key isEqualToString:@"communicationResultForWLAN"] ||
        [key isEqualToString:@"isExecutingForWLAN"]         ||
        [key isEqualToString:@"isFinishedForWLAN"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)start
{
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.isExecutingForWLAN = YES;
    
    BRLMPrinterDriverGenerateResult* result = [BRLMPrinterDriverGenerator openChannel:self.channel];
    
    if (result.error.code == BRLMOpenChannelErrorCodeNoError) {
        self.ptp = result.driver;
        
        NSString *selectedPDFFilePath = [userDefaults objectForKey:kSelectedPDFFilePath];
        BRLMPrintError* error;
        if (![selectedPDFFilePath isEqualToString:@"0"]) {
            error = [self.ptp printPDFWithURL:[NSURL fileURLWithPath:selectedPDFFilePath] settings:self.printInfo];
        }
        else if (self.imagePathArray) {
            if (self.imagePathArray.count == 1) {
                NSString *path = [self.imagePathArray objectAtIndex:0];
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                error = [self.ptp printImageWithImage:image.CGImage settings:self.printInfo];
            } else if (self.imagePathArray.count > 1) {
                NSMutableArray* urlArray = [NSMutableArray array];
                for (NSString* path in self.imagePathArray) {
                    [urlArray addObject:[NSURL fileURLWithPath:path]];
                }
                error = [self.ptp printImageWithURLs:urlArray settings:self.printInfo];
            }
        }
        NSString* printResult = error.description;
        [userDefaults setObject:[NSString stringWithFormat:@"%@", printResult] forKey:kPrintResultForWLAN];
        [userDefaults synchronize];
        NSLog(@"Unimplemented");
        /*
        BRPtouchPrinterStatus *resultstatus;
        BOOL result = [self.ptp getStatus:&resultstatus];
        if (result) {
            [userDefaults setObject:[NSString stringWithFormat:@"%d/%d(AC=%zd)",
                                     resultstatus.batteryResidualQuantityLevel,
                                     resultstatus.maxOfBatteryResidualQuantityLevel,
                                     resultstatus.isACConnected] forKey:kPrintStatusBatteryPowerForWLAN];
            [userDefaults synchronize];
        }
        else if (!result) {
            // Error
        }
         */
        
        if ([self.delegate respondsToSelector:@selector(showPrintResultForWLAN)]) {
            [self.delegate showPrintResultForWLAN];
        }
        [self.ptp closeChannel];
    }
    if (self.isExecutingForWLAN != NULL) {
        self.isExecutingForWLAN = NO;
    }
    if (self.isFinishedForWLAN != NULL) {
        self.isFinishedForWLAN = YES;
    }
}

@end
