//
//  ViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//


#import "ScannerViewController.h"
#import "Barcode.h"
@import AVFoundation;   // iOS7 only import style

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface ScannerViewController ()

@property (strong, nonatomic) NSMutableArray * foundBarcodes;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@end

@implementation ScannerViewController
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
    BOOL _hasScanned;
    UIView *_scanLineView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Scanner" parameters:@{@"onload": @"37"}];

    [self setupCaptureSession];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    [_previewView.layer addSublayer:_previewLayer];
    self.foundBarcodes = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    self.allowedBarcodeTypes = [NSMutableArray new];
    [self.allowedBarcodeTypes addObject:@"org.iso.QRCode"];
    [self.allowedBarcodeTypes addObject:@"org.iso.PDF417"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.UPC-E"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Aztec"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39Mod43"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-13"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-8"];
    [self.allowedBarcodeTypes addObject:@"com.intermec.Code93"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code128"];
    
    _hasScanned = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.navTitle;//@"SCAN QRCODE";
    self.previewView.frame = self.view.bounds;
    _hasScanned = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
    [self startScanLineAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
    [self stopRunning];
    [self stopScanLineAnimation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewView.frame = self.view.bounds;
    _previewLayer.frame = self.previewView.bounds;
    if (_running && !_hasScanned) {
        [self startScanLineAnimation];
    }
}

#pragma mark - AV capture methods

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;

    NSString *qrCamSetting = [USER_DEFAULT valueForKey:KEY_QRCodeCam];
    if (qrCamSetting != nil && [[qrCamSetting uppercaseString] isEqualToString:[VALUE_CAMERA_REAR uppercaseString]])
    {
        _videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    else
    {
        // Default to front camera for iPad kiosk scanning
        _videoDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    
    // If preferred position is not found, fallback to the other position
    if (!_videoDevice) {
        if (qrCamSetting != nil && [[qrCamSetting uppercaseString] isEqualToString:[VALUE_CAMERA_REAR uppercaseString]]) {
            _videoDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            _videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    
    if (!_videoDevice) {
        _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc]
                   initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                     initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}
// make sure you have this method in your class
//
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    if (@available(iOS 10.0, *)) {
        NSMutableArray *deviceTypes = [NSMutableArray arrayWithObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
        if (@available(iOS 13.0, *)) {
            // Modern iPads (e.g. iPad 9th/10th gen, iPad Pro) use an Ultra Wide camera for Front
            [deviceTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
        }
        if (@available(iOS 11.1, *)) {
            [deviceTypes addObject:AVCaptureDeviceTypeBuiltInTrueDepthCamera];
        }
        
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
            discoverySessionWithDeviceTypes:deviceTypes
            mediaType:AVMediaTypeVideo
            position:AVCaptureDevicePositionUnspecified];
        
        for (AVCaptureDevice *device in discoverySession.devices)
        {
            if ([device position] == position)
                return device;
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
            return device;
    }
    return nil;
}
- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes =
    _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
}
- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
    if (!_hasScanned) {
        [self startScanLineAnimation];
    }
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
    [self stopScanLineAnimation];
}

#pragma mark - Scan Line Animation

- (void)startScanLineAnimation {
    if (_hasScanned) return;
    
    if (!_scanLineView) {
        _scanLineView = [[UIView alloc] init];
        _scanLineView.backgroundColor = [UIColor colorWithRed:1.0f green:0.12f blue:0.12f alpha:0.95f];
        _scanLineView.layer.cornerRadius = 2.0f;
        _scanLineView.layer.shadowColor = [UIColor colorWithRed:1.0f green:0.2f blue:0.2f alpha:1.0f].CGColor;
        _scanLineView.layer.shadowOffset = CGSizeZero;
        _scanLineView.layer.shadowRadius = 8.0f;
        _scanLineView.layer.shadowOpacity = 0.90f;
        _scanLineView.layer.masksToBounds = NO;
        _scanLineView.userInteractionEnabled = NO;
        [self.view addSubview:_scanLineView];
    }
    
    [self.view bringSubviewToFront:_scanLineView];
    
    CGFloat previewWidth = self.view.bounds.size.width;
    CGFloat previewHeight = self.view.bounds.size.height;
    if (previewWidth <= 0 || previewHeight <= 0) return;
    
    CGFloat margin = 24.0f;
    CGFloat lineWidth = previewWidth - (margin * 2.0f);
    if (lineWidth < 100.0f) {
        margin = 8.0f;
        lineWidth = previewWidth - (margin * 2.0f);
    }
    
    CGFloat startY = 60.0f;
    CGFloat endY = previewHeight - 60.0f;
    if (endY <= startY) {
        startY = 20.0f;
        endY = previewHeight - 20.0f;
    }
    
    _scanLineView.frame = CGRectMake(margin, startY, lineWidth, 3.5f);
    _scanLineView.hidden = NO;
    _scanLineView.alpha = 1.0f;
    
    [_scanLineView.layer removeAllAnimations];
    
    // 1. Smooth continuous up-and-down scanning animation over full preview area
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.fromValue = @(startY + 1.75f);
    scanAnimation.toValue = @(endY + 1.75f);
    scanAnimation.duration = 2.2;
    scanAnimation.autoreverses = YES;
    scanAnimation.repeatCount = HUGE_VALF;
    scanAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scanAnimation.removedOnCompletion = NO;
    [_scanLineView.layer addAnimation:scanAnimation forKey:@"redScanLineMove"];
    
    // 2. Subtle pulse/glow animation to clearly indicate active scanning
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.fromValue = @(0.60f);
    pulseAnimation.toValue = @(1.0f);
    pulseAnimation.duration = 0.8;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.removedOnCompletion = NO;
    [_scanLineView.layer addAnimation:pulseAnimation forKey:@"redScanLinePulse"];
}

- (void)stopScanLineAnimation {
    if (_scanLineView) {
        [_scanLineView.layer removeAllAnimations];
        _scanLineView.hidden = YES;
    }
}

#pragma mark - Delegate functions

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if (_hasScanned) return; // Prevent multiple scans
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_hasScanned) return; // Double-check on main thread
            
            [metadataObjects
             enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
                                          NSUInteger idx,
                                          BOOL *stop)
             {
                 if (self->_hasScanned) {
                     *stop = YES;
                     return;
                 }
                 if ([obj isKindOfClass:
                      [AVMetadataMachineReadableCodeObject class]])
                 {
                     if ([[obj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                         // 3
                         AVMetadataMachineReadableCodeObject *code =
                         (AVMetadataMachineReadableCodeObject*)
                         [self->_previewLayer transformedMetadataObjectForMetadataObject:obj];
                         if (!code) {
                             code = (AVMetadataMachineReadableCodeObject*)obj;
                         }
                         // 4
                         Barcode * barcode = [Barcode processMetadataObject:code];
                         
                         for(NSString * str in self.allowedBarcodeTypes){
                            if([barcode.getBarcodeType isEqualToString:str]){
                                *stop = YES;
                                [self validBarcodeFound:barcode];
                                return;
                            }
                         }
                     }
                 }
            }];
        });
    }
}

- (void) validBarcodeFound:(Barcode *)barcode{
    if (_hasScanned) return;
    _hasScanned = YES;
    [self stopRunning];
    [self stopScanLineAnimation];
    [self.foundBarcodes addObject:barcode];
    [self showBarcodeAlert:barcode];
}

- (void) showBarcodeAlert:(Barcode *)barcode{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"====>%@",barcode);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *nsd=[[NSMutableDictionary alloc] init];
            if (barcode==nil)
            {
                [nsd setObject:@"" forKey:@"QRCode"];
            }
            else
            {
                NSString *data = [barcode getBarcodeData];
                if (data != nil) {
                    data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                [nsd setObject:data ? data : @"" forKey:@"QRCode"];
            }
            if (self->_didFinishwithQRDetail) {
                self->_didFinishwithQRDetail(nsd);
            }
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        //Code for Done button
        // TODO: Create a finished view
    }
    if(buttonIndex == 1){
        //Code for Scan more button
        _hasScanned = NO;
        [self startRunning];
        [self startScanLineAnimation];
    }
}

- (void) settingsChanged:(NSMutableArray *)allowedTypes{
    for(NSObject * obj in allowedTypes){
        NSLog(@"%@",obj);
    }
    if(allowedTypes){
        self.allowedBarcodeTypes = [NSMutableArray arrayWithArray:allowedTypes];
    }
}
- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
        case UIInterfaceOrientationLandscapeRight: {
            return AVCaptureVideoOrientationLandscapeRight;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
        }
            default:
            return [Common appDelegate].isIpad?AVCaptureVideoOrientationLandscapeLeft:AVCaptureVideoOrientationPortrait;
    }
//    return [Common appDelegate].isIpad?AVCaptureVideoOrientationLandscapeLeft:AVCaptureVideoOrientationPortrait;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         [self videoOrientationFromCurrentDeviceOrientation:orientation];
         self.previewView.frame = self.view.bounds;
         self->_previewLayer.frame = self.previewView.bounds;
         if (self->_running && !self->_hasScanned) {
             [self startScanLineAnimation];
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if (self->_running && !self->_hasScanned) {
             [self startScanLineAnimation];
         }
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
@end
