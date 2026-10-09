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

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

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
    dispatch_queue_t _sessionQueue;   // all AVCaptureSession configuration + start/stop happen here
    BOOL _sessionConfigured;          // only touched on _sessionQueue
    BOOL _isVisible;
    BOOL _showDeniedAlertOnAppear;
    id _rotationCoordinator; // AVCaptureDeviceRotationCoordinator (iOS 17+)
}

static void *ScannerRotationCoordinatorContext = &ScannerRotationCoordinatorContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"Scanner" parameters:@{@"onload": @"37"}];
    
    // -[AVCaptureSession startRunning]/stopRunning block; Apple requires them off the main thread.
    _sessionQueue = dispatch_queue_create("com.linksafe.scanner.session", DISPATCH_QUEUE_SERIAL);
    _captureSession = [[AVCaptureSession alloc] init];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = _previewView.bounds;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionWasInterrupted:)
                                                 name:AVCaptureSessionWasInterruptedNotification
                                               object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionInterruptionEnded:)
                                                 name:AVCaptureSessionInterruptionEndedNotification
                                               object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionRuntimeError:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:_captureSession];
    
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
    
    [self requestCameraAccessAndConfigure];
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
    _isVisible = YES;
    if (_showDeniedAlertOnAppear) {
        _showDeniedAlertOnAppear = NO;
        [self showCameraAccessDeniedAlert];
        return;
    }
    // The preview layer is in a window now, so its real interface orientation is known.
    [self setupRotationCoordinator];
    [self updatePreviewOrientation];
    [self startRunning];
    [self startScanLineAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isVisible = NO;
    self.navigationItem.title = @"";
    [self stopRunning];
    [self stopScanLineAnimation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewView.frame = self.view.bounds;
    _previewLayer.frame = self.previewView.bounds;
    [self updatePreviewOrientation];
    if (_running && !_hasScanned) {
        [self startScanLineAnimation];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_rotationCoordinator) {
        [_rotationCoordinator removeObserver:self forKeyPath:@"videoRotationAngleForHorizonLevelPreview" context:ScannerRotationCoordinatorContext];
    }
    AVCaptureSession *session = _captureSession;
    if (session.isRunning && _sessionQueue) {
        dispatch_async(_sessionQueue, ^{
            [session stopRunning];
        });
    }
}

#pragma mark - Camera permission

// Ask for camera access BEFORE configuring the session. Without this, a fresh install
// (e.g. a new iPad) can show a black preview after the user taps "Allow".
- (void)requestCameraAccessAndConfigure {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSLog(@"[Scanner] Camera authorization status: %ld", (long)status);
    if (status == AVAuthorizationStatusNotDetermined) {
        // Hold the session queue until the user answers, so configuration waits for access.
        dispatch_suspend(_sessionQueue);
        dispatch_queue_t queue = _sessionQueue;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            NSLog(@"[Scanner] Camera access granted: %@", granted ? @"YES" : @"NO");
            dispatch_resume(queue);
        }];
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        [weakSelf configureSessionOnSessionQueue];
    });
}

- (void)showCameraAccessDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Access Required"
                                                                   message:@"Please allow camera access in Settings to scan QR codes."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self closeScanner];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        [self closeScanner];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)closeScanner {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - AV capture methods

// Runs on _sessionQueue.
- (void)configureSessionOnSessionQueue {
    if (_sessionConfigured) return;
    
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
        NSLog(@"[Scanner] Camera not authorized; not configuring session.");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_isVisible) {
                [self showCameraAccessDeniedAlert];
            } else {
                self->_showDeniedAlertOnAppear = YES;
            }
        });
        return;
    }
    
    NSString *qrCamSetting = [USER_DEFAULT valueForKey:KEY_QRCodeCam];
    BOOL preferRear = (qrCamSetting != nil && [[qrCamSetting uppercaseString] isEqualToString:[VALUE_CAMERA_REAR uppercaseString]]);
    // Default to front camera for iPad kiosk scanning; fall back to the other side if missing.
    AVCaptureDevicePosition preferred = preferRear ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    AVCaptureDevicePosition other = preferRear ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    NSMutableArray<AVCaptureDevice *> *candidates = [NSMutableArray array];
    [candidates addObjectsFromArray:[self camerasWithPosition:preferred]];
    [candidates addObjectsFromArray:[self camerasWithPosition:other]];
    AVCaptureDevice *defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (defaultDevice && ![candidates containsObject:defaultDevice]) {
        [candidates addObject:defaultDevice];
    }
    
    // Use the first camera whose input can actually be created and added to the session.
    AVCaptureDevice *device = nil;
    AVCaptureDeviceInput *input = nil;
    [_captureSession beginConfiguration];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    for (AVCaptureDevice *candidate in candidates) {
        NSError *error = nil;
        AVCaptureDeviceInput *candidateInput = [AVCaptureDeviceInput deviceInputWithDevice:candidate error:&error];
        if (candidateInput && [_captureSession canAddInput:candidateInput]) {
            [_captureSession addInput:candidateInput];
            device = candidate;
            input = candidateInput;
            break;
        }
        NSLog(@"[Scanner] Skipping camera %@ (%@): %@", candidate.localizedName, candidate.deviceType, error ?: @"cannot add input");
    }
    
    if (!device) {
        [_captureSession commitConfiguration];
        NSLog(@"[Scanner] No usable video camera on this device!");
        return;
    }
    NSLog(@"[Scanner] Using camera: %@ type=%@ position=%ld", device.localizedName, device.deviceType, (long)device.position);
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    } else {
        NSLog(@"[Scanner] Cannot add metadata output!");
    }
    
    // iPadOS can run apps in resizable windows / Stage Manager. Where supported, keep the
    // camera running instead of being interrupted when other apps are on screen.
    if (@available(iOS 16.0, *)) {
        if (_captureSession.isMultitaskingCameraAccessSupported) {
            _captureSession.multitaskingCameraAccessEnabled = YES;
        }
    }
    [_captureSession commitConfiguration];
    
    [self applyMetadataObjectTypes];
    
    // Continuous autofocus (where the camera supports it) keeps QR codes sharp.
    if ([device lockForConfiguration:nil]) {
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        [device unlockForConfiguration];
    }
    
    _sessionConfigured = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_videoDevice = device;
        self->_videoInput = input;
        if (self->_isVisible) {
            [self setupRotationCoordinator];
            [self updatePreviewOrientation];
        }
    });
}

// Runs on _sessionQueue. Only QR codes are handled below; asking for every available type also
// enables face/body/object detection. The available types are only known once the output is
// connected to a running-capable session, so this is re-checked after the session starts too.
- (void)applyMetadataObjectTypes {
    if (!_metadataOutput) return;
    if ([_metadataOutput.metadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) return;
    if ([_metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        _metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    } else {
        NSLog(@"[Scanner] QR metadata not available yet: %@", _metadataOutput.availableMetadataObjectTypes);
    }
}

// Cameras for a position, in preference order. Some iPads (e.g. iPad 10th gen, iPad Pro / Air
// with M-series chips) expose the front camera as Ultra Wide and/or TrueDepth only, and the
// discovery session's device order is not guaranteed, so pick explicitly by type.
- (NSArray<AVCaptureDevice *> *)camerasWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                             AVCaptureDeviceTypeBuiltInUltraWideCamera,
                             AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
                                                         discoverySessionWithDeviceTypes:deviceTypes
                                                         mediaType:AVMediaTypeVideo
                                                         position:position];
    NSMutableArray<AVCaptureDevice *> *result = [NSMutableArray array];
    for (AVCaptureDeviceType type in deviceTypes) {
        for (AVCaptureDevice *device in discoverySession.devices) {
            if ([device.deviceType isEqualToString:type] && ![result containsObject:device]) {
                [result addObject:device];
            }
        }
    }
    return result;
}

- (void)startRunning {
    if (_running || !_captureSession) return;
    _running = YES;
    AVCaptureSession *session = _captureSession;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !strongSelf->_sessionConfigured) return;
        if (!session.isRunning) {
            [session startRunning];
            NSLog(@"[Scanner] Session running: %@", session.isRunning ? @"YES" : @"NO");
        }
        [strongSelf applyMetadataObjectTypes];
    });
}
- (void)stopRunning {
    if (!_running || !_captureSession) return;
    _running = NO;
    AVCaptureSession *session = _captureSession;
    dispatch_async(_sessionQueue, ^{
        if (session.isRunning) {
            [session stopRunning];
        }
    });
}

#pragma mark - Session interruptions

- (void)sessionWasInterrupted:(NSNotification *)note {
    NSNumber *reason = note.userInfo[AVCaptureSessionInterruptionReasonKey];
    NSLog(@"[Scanner] Session interrupted, reason: %@", reason);
}

- (void)sessionInterruptionEnded:(NSNotification *)note {
    NSLog(@"[Scanner] Session interruption ended");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_isVisible && !self->_hasScanned) {
            self->_running = NO;
            [self startRunning];
        }
    });
}

- (void)sessionRuntimeError:(NSNotification *)note {
    NSLog(@"[Scanner] Session runtime error: %@", note.userInfo[AVCaptureSessionErrorKey]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_isVisible && !self->_hasScanned) {
            self->_running = NO;
            [self startRunning];
        }
    });
}

#pragma mark - Preview orientation

// iOS 17+: AVCaptureDeviceRotationCoordinator gives the correct rotation for this camera
// (front/back sensor mounting) and the preview layer's actual interface orientation.
- (void)setupRotationCoordinator {
    if (@available(iOS 17.0, *)) {
        if (_rotationCoordinator || !_videoDevice || !_previewLayer) return;
        _rotationCoordinator = [[AVCaptureDeviceRotationCoordinator alloc] initWithDevice:_videoDevice previewLayer:_previewLayer];
        [_rotationCoordinator addObserver:self
                               forKeyPath:@"videoRotationAngleForHorizonLevelPreview"
                                  options:NSKeyValueObservingOptionNew
                                  context:ScannerRotationCoordinatorContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ScannerRotationCoordinatorContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updatePreviewOrientation];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updatePreviewOrientation {
    AVCaptureConnection *connection = _previewLayer.connection;
    if (!connection) return;
    
    if (@available(iOS 17.0, *)) {
        if (_rotationCoordinator) {
            CGFloat angle = [(AVCaptureDeviceRotationCoordinator *)_rotationCoordinator videoRotationAngleForHorizonLevelPreview];
            if ([connection isVideoRotationAngleSupported:angle]) {
                connection.videoRotationAngle = angle;
            }
            return;
        }
    }
    
    // iOS 15/16: use the window scene's orientation (statusBarOrientation is deprecated and
    // unreliable with scenes, which made the iPad preview show 180° rotated).
    UIInterfaceOrientation orientation = [self currentInterfaceOrientation];
    if (orientation == UIInterfaceOrientationUnknown) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation:orientation];
    }
#pragma clang diagnostic pop
}

- (UIInterfaceOrientation)currentInterfaceOrientation {
    UIWindowScene *windowScene = self.view.window.windowScene;
    if (!windowScene) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                windowScene = (UIWindowScene *)scene;
                break;
            }
        }
    }
    return windowScene ? windowScene.interfaceOrientation : UIInterfaceOrientationUnknown;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    if (!_isVisible) return;
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

- (void) settingsChanged:(NSMutableArray *)allowedTypes{
    for(NSObject * obj in allowedTypes){
        NSLog(@"%@",obj);
    }
    if(allowedTypes){
        self.allowedBarcodeTypes = [NSMutableArray arrayWithArray:allowedTypes];
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// Used only on iOS 15/16 (AVCaptureVideoOrientation is deprecated from iOS 17).
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
#pragma clang diagnostic pop
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
        self.previewView.frame = self.view.bounds;
        self->_previewLayer.frame = self.previewView.bounds;
        [self updatePreviewOrientation];
        if (self->_running && !self->_hasScanned) {
            [self startScanLineAnimation];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
        [self updatePreviewOrientation];
        if (self->_running && !self->_hasScanned) {
            [self startScanLineAnimation];
        }
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
@end
