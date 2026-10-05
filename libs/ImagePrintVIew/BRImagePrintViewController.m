//
//  BRImagePrintViewController.m
//  SDK_Sample_Ver2
//
//  Copyright © 2015 Brother Industries, Ltd. All rights reserved.
//

//#ifndef WLAN_ONLY
//#import <BRLMPrinterKit/BRLMPrinterKit.h>
//#else
//#import <BRLMPrinterKitW/BRLMPrinterKit.h>
//#endif

#import "UserDefaults.h"
#import "BRImagePrintViewController.h"
#import "BRImagePrintTablesViewItem.h"
#import "BRImagePrintTablesViewItemCreator.h"
#import "BRWLANPrintOperation.h"
#import "BRBluetoothPrintOperation.h"
#import "BRPrintResultViewController.h"
//#import "BRFileManager.h"

#define kSearchDeviceByWiFiSegue    @"searchDeviceByWiFiSegue"
#define kSearchDeviceByMFiSegue     @"searchDeviceByMFiSegue"
#define kSearchDeviceByBLESegue     @"searchDeviceByBLESegue"
#define kPrintSettingsSegue         @"printSettingsSegue"

@interface BRImagePrintViewController ()
{
	BRLMChannel	*_ptp;
}
@property(nonatomic, weak) IBOutlet UITableView     *deviceSearchTableView;
@property(nonatomic, weak) IBOutlet UITableView     *rootPrintSettingTableView;

@property(nonatomic, strong) BRImagePrintTablesViewItemCreator *imagePrintTablesViewItemCreator;
@property(nonatomic, strong) NSMutableArray *imagePathArray;

@property (nonatomic, strong) BRPrintResultViewController *printResultViewController;

@end

@implementation BRImagePrintViewController

- (void) initWithUserDefault
{
    // "UserDefault" Initialize
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults   = [NSMutableDictionary dictionary];
    
    [userDefaults removeObjectForKey:kPrintCustomPaperKey];
    [userDefaults removeObjectForKey:kSelectedPDFFilePath];
    [userDefaults synchronize];
    
    [defaults setObject:@""                                                 forKey:kExportPrintFileNameKey];
    [defaults setObject:@"1"                                                forKey:kPrintNumberOfPaperKey];
    [defaults setObject:[self defaultPaperSize]                             forKey:kPrintPaperSizeKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", Landscape]        forKey:kPrintOrientationKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", Fit]         forKey:kScalingModeKey];
    [defaults setObject:@"0.5"                                              forKey:kScalingFactorKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", ErrorDiffusion]           forKey:kPrintHalftoneKey];
    [defaults setObject:@"127"                                              forKey:kPrintBinaryThresholdKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", Left]             forKey:kPrintHorizintalAlignKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", Top]              forKey:kPrintVerticalAlignKey];
    //[defaults setObject:[NSString stringWithFormat:@"%d", PaperLeft]        forKey:kPrintPaperAlignKey];
    
    // nExtFlag
    [defaults setObject:[NSString stringWithFormat:@"%d", CodeOff]          forKey:kPrintCodeKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", CarbonOff]        forKey:kPrintCarbonKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", DashOff]          forKey:kPrintDashKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", NoFeed]           forKey:kPrintFeedModeKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", CurlModeOff]      forKey:kPrintCurlModeKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", Fast]             forKey:kPrintSpeedKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", BidirectionOn]    forKey:kPrintBidirectionKey];
    [defaults setObject:@"0"                                                forKey:kPrintFeedMarginKey];
    [defaults setObject:@"200"                                              forKey:kPrintCustomLengthKey];
    [defaults setObject:@"80"                                               forKey:kPrintCustomWidthKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", AutoCutOn]       forKey:kPrintAutoCutKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", CutAtEndOff]      forKey:kPrintCutAtEndKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", HalfCutOff]       forKey:kPrintHalfCutKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", SpecialTapeOn]   forKey:kPrintSpecialTapeKey];
    
    [defaults setObject:@""                                    forKey:kPrintCustomPaperKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", RotateOff]        forKey:kRotateKey];
    [defaults setObject:[NSString stringWithFormat:@"%d", PeelOff]          forKey:kPeelKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", CutMarkOff]       forKey:kPrintCutMarkKey];
    [defaults setObject:@"0"                                                forKey:kPrintLabelMargineKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", DensityMax5Level5]    forKey:kPrintDensityMax5Key];
    [defaults setObject:[NSString stringWithFormat:@"%d", DensityMax10Level10]   forKey:kPrintDensityMax10Key];
    
    [defaults setObject:@"0"     forKey:kPrintTopMarginKey];
    [defaults setObject:@"0"     forKey:kPrintLeftMarginKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", PJCutPaper]   forKey:kPJPaperKindKey];
    
    [defaults setObject:[NSString stringWithFormat:@"%d", Normal]   forKey:kPirintQuality];
    
    [defaults setObject:@"No Selected"                                      forKey:kSelectedDevice];
    [defaults setObject:@""                                                 forKey:kIPAddress];
    [defaults setObject:@"0"                                                forKey:kSerialNumber];
    [defaults setObject:@"Search device from Wi-Fi"                         forKey:kSelectedDeviceFromWiFi];
    [defaults setObject:@"Search device from Bluetooth"                     forKey:kSelectedDeviceFromBluetooth];
    [defaults setObject:@"Search device from BLE"                           forKey:kSelectedDeviceFromBLE];

    [defaults setObject:@"0"                                                forKey:kIsWiFi];
    [defaults setObject:@"0"                                                forKey:kIsBluetooth];
    
    [defaults setObject:@"0"                                                forKey:kSelectedPDFFilePath];
    [defaults setObject:@"1"                                                forKey:kPrintMode9];
    [defaults setObject:@"0"                                                forKey:kPrintRawMode];
    
    [userDefaults registerDefaults:defaults];
}

- (void)dealloc {
//    [self removeSelectedImages];
}

- (NSString *)defaultPaperSize
{
    NSString *result = nil;
    
    NSString *pathInPrintSettings   = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if (pathInPrintSettings) {
        NSDictionary *priterListArray = [NSDictionary dictionaryWithContentsOfFile:pathInPrintSettings];
        if (priterListArray) {
            result = [[[priterListArray objectForKey:@"Brother QL-720NW"] objectForKey:@"PaperSize"] objectAtIndex:0];
        }
    }
    return result;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithUserDefault];
    self.imagePrintTablesViewItemCreator = [[BRImagePrintTablesViewItemCreator alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedSearchTableRow = [self.deviceSearchTableView indexPathForSelectedRow];
    [self.deviceSearchTableView deselectRowAtIndexPath:selectedSearchTableRow animated:NO];
    
    NSIndexPath *selectedPrintTableRow = [self.rootPrintSettingTableView indexPathForSelectedRow];
    [self.rootPrintSettingTableView deselectRowAtIndexPath:selectedPrintTableRow animated:NO];
    
    [self.deviceSearchTableView     reloadData];
    [self.rootPrintSettingTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)previewImageFromPDF:(NSString *)pdfPath
{
    UIImage *image = nil;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:pdfPath]];
    CFDataRef dataRef = (__bridge CFDataRef)data;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(dataRef);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    CGDataProviderRelease(provider);
    CGPDFPageRef firstPageRef = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediarect = CGPDFPageGetBoxRect(firstPageRef, kCGPDFMediaBox);
    CGFloat scale = 600.0/mediarect.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(600.0, mediarect.size.height*scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, mediarect);
    CGContextTranslateCTM(context, 0.0, mediarect.size.height*scale);
    CGContextScaleCTM(context, 1.0*scale, -1.0*scale);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
    CGContextDrawPDFPage(context, firstPageRef);
    image = UIGraphicsGetImageFromCurrentImageContext();
    CGPDFDocumentRelease(pdf);
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Table View <Delegate Method>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    
    if (tableView.tag == 1) {
        numberOfSections = 3;
    }
    else if (tableView.tag == 2) {
        numberOfSections = 1;
    }
    
    return numberOfSections;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BRImagePrintTablesViewItem *item = [self.imagePrintTablesViewItemCreator selectedImagePrintTablesViewItem:tableView.tag
                                                                                                 tableSection:section];
    return item.sectionLabelName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (tableView.tag == 1) {
        numberOfRows = 1;
    }
    else if (tableView.tag == 2) {
        numberOfRows = 1;
    }
    
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRImagePrintTablesViewItem *item = [self.imagePrintTablesViewItemCreator selectedImagePrintTablesViewItem:tableView.tag
                                                                                                 tableSection:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:item.cellID];
    }
    cell.textLabel.text = item.cellLabelName;
    cell.detailTextLabel.text = item.cellLabelDetailName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        switch (indexPath.section) {
            case 0:
                NSLog(@"[Push] search device by Wi-Fi");
                break;
            case 1:
                NSLog(@"[Push] search device by MFi");
                break;
            case 2:
                NSLog(@"[Push] search device by BLE");
                break;
            default:
                //Error
                break;
        }
    }
    else if (tableView.tag == 2) {
        switch (indexPath.section) {
            case 0:
                NSLog(@"[Push] root print setting");
                break;
                
            default:
                //Error
                break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSearchDeviceByWiFiSegue]) {
        NSLog(@"[Segue] search device by Wi-Fi");
    }
    else if ([segue.identifier isEqualToString:kSearchDeviceByMFiSegue]) {
        NSLog(@"[Segue] search device by MFi");
    }
    else if ([segue.identifier isEqualToString:kSearchDeviceByBLESegue]) {
        NSLog(@"[Segue] search device by BLE");
    }
    else if ([segue.identifier isEqualToString:kPrintSettingsSegue]) {
        NSLog(@"[Segue] print settings");
    }
}

- (void) prepareForPtp
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedDevice = nil;
        
    if ([userDefaults integerForKey:kIsWiFi] == 0 && [userDefaults integerForKey:kIsBluetooth] == 1 && [userDefaults integerForKey:kIsBLE] == 0){
        selectedDevice = [NSString stringWithFormat:@"%@",[userDefaults stringForKey:kSelectedDeviceFromBluetooth]];
        _ptp = [[BRLMChannel alloc] initWithBluetoothSerialNumber:[userDefaults objectForKey:kSerialNumber]];
    }
    else if ([userDefaults integerForKey:kIsWiFi] == 1 && [userDefaults integerForKey:kIsBluetooth] == 0 && [userDefaults integerForKey:kIsBLE] == 0){
        selectedDevice = [NSString stringWithFormat:@"%@", [userDefaults stringForKey:kSelectedDeviceFromWiFi]];
        _ptp = [[BRLMChannel alloc] initWithWifiIPAddress:[userDefaults objectForKey:kIPAddress]];
    }
    else if ([userDefaults integerForKey:kIsWiFi] == 0 && [userDefaults integerForKey:kIsBluetooth] == 0 && [userDefaults integerForKey:kIsBLE] == 1){
        selectedDevice = [NSString stringWithFormat:@"%@", [userDefaults stringForKey:kSelectedDeviceFromBLE]];
        _ptp = [[BRLMChannel alloc] initWithBLELocalName:[userDefaults objectForKey:kAdvertiseLocalName]];
    }
    else{
//        NSAssert(false, @"BRLMChannelType error");
    }

}

- (void) prepareForPrintResultViewControllerNavigationItems
{
    /*
    self.printResultViewController = [self.storyboard instantiateViewControllerWithIdentifier: @"printResultViewController"];
    
    UIBarButtonItem *doneButton;
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(dismissModalView)];
    
    UIBarButtonItem *cancelButton;
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                 target:self
                                                                 action:@selector(cancelPrint)];
    
    self.printResultViewController.navigationItem.leftBarButtonItem = doneButton;
    self.printResultViewController.navigationItem.rightBarButtonItem = cancelButton;
    self.printResultViewController.imagePathArray = self.imagePathArray;
    self.printResultViewController.visitorDetails = [@{@"istest" : @"0", kPrinterStatus : @"0"} mutableCopy];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.printResultViewController];
//    [self presentViewController:nav
//                       animated:YES
//                     completion:nil];
    */

    self.printResultViewController = (BRPrintResultViewController *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier: @"BRPrintResultViewController"];
    self.printResultViewController.visitorDetails=[[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"istest", @"1", kPrinterStatus, nil] mutableCopy];
    [self.navigationController pushViewController:self.printResultViewController animated:YES];
}

- (void)dismissModalView {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancelPrint {
    NSLog(@"*** Cancel Print ***");
    NSLog(@"Unimplemented");
    //[_ptp cancelPrinting];
}

#pragma mark - IBAction

- (IBAction)printButton:(id)sender
{
    [self prepareForPtp];
    
    if (_ptp) {
        [self prepareForPrintResultViewControllerNavigationItems];
    }
}

- (void)showConnectionErrorAlert {
    [self showErrorAlert:@"Error" message:@"Communication Error"];
}

- (void)showFileSaveErrorAlert {
    [self showErrorAlert:@"Error" message:@"File Save Error"];
}

- (void)showErrorAlert:(NSString *)title message:(NSString *)message
{
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if(osVersion >= 8.0f) {
        UIAlertController * alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (osVersion < 8.0f && osVersion >= 6.0f) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else {
        // Non Support
    }
}

@end
