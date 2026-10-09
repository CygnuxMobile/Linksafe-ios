/*
     File: AVCamViewController.m
 Abstract: View controller for camera interface.
  Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"

#import <AVFoundation/AVFoundation.h>
// AssetsLibrary removed - deprecated framework

#import "AVCamPreviewView.h"
//#import "PhotoViewController.h"
#import "UIButton+Additions.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static void * RotationCoordinatorContext = &RotationCoordinatorContext;

@interface AVCamViewController () <AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate>


// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCapturePhotoOutput *photoOutput; // Replaces deprecated AVCaptureStillImageOutput

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (weak, nonatomic) IBOutlet UILabel *lblPhotoCount;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (nonatomic) BOOL isStartTimer;
@property (nonatomic) id rotationCoordinator; // AVCaptureDeviceRotationCoordinator (iOS 17+)

@end

@implementation AVCamViewController

//@synthesize strUserId,strUserName;
//
//@synthesize strPhotoUserOrPunch;

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

-(void)counterForPhoto
{
    if (!_isStartTimer)
    {
        [timerClock invalidate];
        timerClock = nil;
        return;
    }
    intCounter--;
    _lblPhotoCount.text =  [NSString stringWithFormat:@"%d",intCounter];
    if (intCounter <= 0)
    {
        [self CapturePhoto];
        [timerClock invalidate];
//        [self btnCaptureClick:nil];
        timerClock = nil;
    }
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    [FIRAnalytics logEventWithName:@"AVCam" parameters:@{@"onload": @"2"}];

	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
    _isStartTimer = YES;
    [self setupCaptureSession];
    _lblPhotoCount.hidden = YES;
    _btnCapture.hidden = NO;
    _btnChangeCamera.hidden = YES;
    _btnCancel.hidden = NO;
    
    [_btnCapture applyBlueShedow];
    [_btnChangeCamera applyBlueShedow];
    [_btnCancel applyBlueShedow];
    
    _lblPhotoCount.textColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    intCounter = 3;
//    timerClock = [NSTimer scheduledTimerWithTimeInterval:1 target: self
//                                   selector: @selector(counterForPhoto) userInfo: nil repeats: YES];
    
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		// Note: AVCapturePhotoOutput does not use capturingStillImage KVO
		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak AVCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			AVCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
			});
		}]];
		[[self session] startRunning];
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

// -willRotateToInterfaceOrientation:duration: is no longer called on current iOS versions, so the
// preview stayed 180° rotated when the iPad was in (or turned to) the other landscape side.
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	// The preview layer is in a window now, so (re)create the coordinator against its real orientation.
	AVCaptureDevice *device = [[self videoDeviceInput] device];
	if (device) {
		[self setRotationCoordinatorForDevice:device];
	} else {
		[self updatePreviewOrientation];
	}
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[self updatePreviewOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self updatePreviewOrientation];
	}];
}

- (void)dealloc
{
	if (_rotationCoordinator) {
		[_rotationCoordinator removeObserver:self forKeyPath:@"videoRotationAngleForHorizonLevelPreview" context:RotationCoordinatorContext];
	}
}

#pragma mark - Orientation

// iOS 17+: AVCaptureDeviceRotationCoordinator gives the right angle for this camera (front/back
// sensor mounting) and for the preview layer's real interface orientation.
// Must be called on the main queue.
- (void)setRotationCoordinatorForDevice:(AVCaptureDevice *)device
{
	if (@available(iOS 17.0, *)) {
		if (self.rotationCoordinator) {
			[self.rotationCoordinator removeObserver:self forKeyPath:@"videoRotationAngleForHorizonLevelPreview" context:RotationCoordinatorContext];
			self.rotationCoordinator = nil;
		}
		if (device) {
			AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)[[self previewView] layer];
			self.rotationCoordinator = [[AVCaptureDeviceRotationCoordinator alloc] initWithDevice:device previewLayer:previewLayer];
			[self.rotationCoordinator addObserver:self forKeyPath:@"videoRotationAngleForHorizonLevelPreview" options:NSKeyValueObservingOptionNew context:RotationCoordinatorContext];
		}
	}
	[self updatePreviewOrientation];
}

- (UIInterfaceOrientation)currentInterfaceOrientation
{
	UIWindowScene *windowScene = self.view.window.windowScene;
	if (!windowScene) {
		for (UIScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
			if ([scene isKindOfClass:[UIWindowScene class]]) {
				windowScene = (UIWindowScene *)scene;
				break;
			}
		}
	}
	return windowScene ? windowScene.interfaceOrientation : UIInterfaceOrientationUnknown;
}

- (void)updatePreviewOrientation
{
	AVCaptureConnection *connection = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection];
	if (!connection) return;
	
	if (@available(iOS 17.0, *)) {
		if (self.rotationCoordinator) {
			CGFloat angle = [(AVCaptureDeviceRotationCoordinator *)self.rotationCoordinator videoRotationAngleForHorizonLevelPreview];
			if ([connection isVideoRotationAngleSupported:angle]) {
				connection.videoRotationAngle = angle;
			}
			return;
		}
	}
	
	// iOS 15/16 fallback. UIInterfaceOrientation and AVCaptureVideoOrientation share raw values.
	UIInterfaceOrientation orientation = [self currentInterfaceOrientation];
	if (orientation == UIInterfaceOrientationUnknown) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	if (connection.isVideoOrientationSupported) {
		connection.videoOrientation = (AVCaptureVideoOrientation)orientation;
	}
#pragma clang diagnostic pop
}

// Rotates an output connection (photo / movie) so the captured image is upright.
- (void)applyCaptureOrientationToConnection:(AVCaptureConnection *)connection
{
	if (!connection) return;
	if (@available(iOS 17.0, *)) {
		if (self.rotationCoordinator) {
			CGFloat angle = [(AVCaptureDeviceRotationCoordinator *)self.rotationCoordinator videoRotationAngleForHorizonLevelCapture];
			if ([connection isVideoRotationAngleSupported:angle]) {
				connection.videoRotationAngle = angle;
			}
			return;
		}
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	AVCaptureVideoOrientation previewOrientation = [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation];
	if (connection.isVideoOrientationSupported) {
		connection.videoOrientation = previewOrientation;
	}
#pragma clang diagnostic pop
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == RecordingContext)
	{
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
	}
	else if (context == RotationCoordinatorContext)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updatePreviewOrientation];
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

-(void)setupCaptureSession
{
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    if ([Common appDelegate].isIpad)
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Setup the preview view
    [[self previewView] setSession:session];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    // Hold session setup until the user answers the camera prompt (first launch / new device);
    // otherwise the preview can stay black after tapping "Allow".
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined)
    {
        dispatch_suspend(sessionQueue);
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_resume(sessionQueue);
        }];
    }
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
        if ([[[USER_DEFAULT valueForKey:KEY_CAMERA] uppercaseString] isEqualToString:[VALUE_CAMERA_FRONT uppercaseString]])
        {
            position = AVCaptureDevicePositionFront;
        }
        else
        {
            position = AVCaptureDevicePositionBack;
        }
        
        AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:position];
        if (!videoDevice)
        {
            _isStartTimer = NO;
            NSLog(@"No video camera on this device!");
            return;
        }
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer's connection with other session manipulation.
                
                [self setRotationCoordinatorForDevice:videoDevice];
            });
        }
        
        // Fix: devicesWithMediaType: deprecated — use defaultDeviceWithMediaType: for audio
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = audioDevice ? [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error] : nil;
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            [self setMovieFileOutput:movieFileOutput];
        }
        
        // Fix: AVCaptureStillImageOutput deprecated in iOS 10, crashes on iOS 17+
        // Replaced with AVCapturePhotoOutput
        AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
        if ([session canAddOutput:photoOutput])
        {
            [session addOutput:photoOutput];
            [self setPhotoOutput:photoOutput];
        }
    });
}

#pragma mark - Actions
- (IBAction)btnCancelClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)btnRecordClick:(id)sender
{
//	[[self btnRecord] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		if (![[self movieFileOutput] isRecording])
		{
			[self setLockInterfaceRotation:YES];
			
			if ([[UIDevice currentDevice] isMultitaskingSupported])
			{
				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
			}
			
			// Update the orientation on the movie file output video connection before starting recording.
			[self applyCaptureOrientationToConnection:[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo]];
			
			// Start recording to a temporary file.
			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
		}
		else
		{
			[[self movieFileOutput] stopRecording];
		}
	});
}

- (IBAction)btnChangeCameraClick:(id)sender
{
//	[[self btnChangeCamera] setEnabled:NO];
//	[[self btnRecord] setEnabled:NO];
//	[[self btnCapture] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		AVCaptureDevice *activeDevice = [[self videoDeviceInput] device];
		dispatch_async(dispatch_get_main_queue(), ^{
			// The coordinator is per camera, so recreate it for the new one.
			[self setRotationCoordinatorForDevice:activeDevice];
//			[[self btnChangeCamera] setEnabled:YES];
//			[[self btnRecord] setEnabled:YES];
//			[[self btnCapture] setEnabled:YES];
		});
	});
}

- (IBAction)btnCaptureClick:(id)sender
{
    intCounter = 3;
    _lblPhotoCount.hidden = NO;
    _btnCapture.hidden = YES;
    _btnChangeCamera.hidden = YES;
    _btnCancel.hidden = YES;
    
    timerClock = [NSTimer scheduledTimerWithTimeInterval:1 target: self
                                                selector: @selector(counterForPhoto) userInfo: nil repeats: YES];
}

- (void)CapturePhoto
{
    [timerClock invalidate];
    
    _lblPhotoCount.hidden = YES;
    _btnCapture.hidden = NO;
    _btnChangeCamera.hidden = YES;
    _btnCancel.hidden = NO;
    
    // Fix: Use modern AVCapturePhotoOutput instead of deprecated AVCaptureStillImageOutput
    if (!self.photoOutput) {
        NSLog(@"Photo output not ready");
        return;
    }
    
    // Fix: Set the photo output connection's orientation to match the current
    // device/preview orientation BEFORE capturing. Without this, the captured
    // photo pixels are stored in the sensor's native orientation (landscape)
    // regardless of how the device is held, causing rotated photos.
    AVCaptureConnection *photoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (photoConnection) {
        [self applyCaptureOrientationToConnection:photoConnection];
        
        // Mirror for front camera so the photo matches what the user sees in preview
        AVCaptureDevicePosition currentPosition = [[self videoDeviceInput] device].position;
        if (photoConnection.isVideoMirroringSupported) {
            photoConnection.videoMirrored = (currentPosition == AVCaptureDevicePositionFront);
        }
    }
    
    // Capture photo using modern AVCapturePhotoOutput
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    // Flash Auto for still capture (AVCaptureDevice.flashMode is deprecated; it is set per photo now)
    if ([self.photoOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeAuto)]) {
        settings.flashMode = AVCaptureFlashModeAuto;
    }
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark - AVCapturePhotoCaptureDelegate

// Normalize image orientation so the pixel data matches the visual orientation.
// This is a safety net: the primary fix is setting videoOrientation on the
// photo output connection before capture (in CapturePhoto). This method
// handles any remaining edge cases where the EXIF flag doesn't match pixels.
- (UIImage *)fixImageOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) {
        return image; // Already correct, no need to redraw
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

// Modern replacement for AVCaptureStillImageOutput capture callback
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error API_AVAILABLE(ios(11.0))
{
    if (error) {
        NSLog(@"Error capturing photo: %@", error);
        return;
    }
    
    NSData *imageData = [photo fileDataRepresentation];
    if (!imageData) {
        NSLog(@"No image data captured");
        return;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    // Fix: Normalize orientation immediately so that reSize / encodeToBase64String
    // (which use UIImagePNGRepresentation) don't lose the EXIF orientation flag
    image = [self fixImageOrientation:image];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{}];
        if (_didFinishCapturingImage) {
            _didFinishCapturingImage(image);
        }
    });
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	if (error)
		NSLog(@"%@", error);
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
	
    // ALAssetsLibrary removed - just clean up temp file
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    if (backgroundRecordingID != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    // Some iPads (e.g. iPad 10th gen, iPad Pro / Air with M-series chips) expose the front camera
    // as Ultra Wide and/or TrueDepth only, so search those types too, in preference order.
    // (devicesWithMediaType: is deprecated; AVCaptureDeviceDiscoverySession works on all supported iOS versions.)
    NSArray *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera,
                             AVCaptureDeviceTypeBuiltInUltraWideCamera,
                             AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:deviceTypes
        mediaType:mediaType
        position:AVCaptureDevicePositionUnspecified];
    NSArray *devices = discoverySession.devices;
    
    for (AVCaptureDeviceType type in deviceTypes)
    {
        for (AVCaptureDevice *device in devices)
        {
            if ([device position] == position && [device.deviceType isEqualToString:type])
            {
                return device;
            }
        }
    }
    
    // Requested side not available: use any camera rather than none.
    return [devices firstObject] ?: [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				// UIAlertView is deprecated; use UIAlertController.
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Access"
																			   message:@"Camera permission is turned off. Please allow camera access in Settings."
																		preferredStyle:UIAlertControllerStyleAlert];
				[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
				[self presentViewController:alert animated:YES completion:nil];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

@end
