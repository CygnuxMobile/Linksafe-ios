//
//  JZTouchIDManager.m
//  SynjonesPay
//
//  Created by Nestcode on 2018/1/5.
//  Copyright © 2018 Nestcode. All rights reserved.
//

#import "JZTouchIDManager.h"
#import <LocalAuthentication/LocalAuthentication.h>


static NSInteger login_count_error_time ;

static JZTouchIDManager * manager = nil;

@interface JZTouchIDManager()

@property (copy  ,readwrite, nonatomic) NSString *errorString;

@property (strong,nonatomic) LAContext* context;
@property (copy  ,readwrite,nonatomic) NSString * localString;

@end

@implementation JZTouchIDManager

@synthesize errorString = _errorString;

+ (instancetype)shareManager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [super allocWithZone:zone];
        });
    }
    return manager;
}

//- (LAContext *)context{
//    if (!_context){
//        _context = [[LAContext alloc] init];;
//    }
//    return _context;
//}

- (NSString *)localString{
    if (!_localString) {
        if (@available(iOS 11.0, *)) {
            if (self.context.biometryType == LABiometryTypeTouchID) {
                self.localString =  @"Fingerprint password";
            }else if (self.context.biometryType == LABiometryTypeFaceID){
                self.localString =  @"Face recognition";
            }
        } else {
            self.localString = @"Fingerprint password";
        }
    }
    return _localString;
}

- (BOOL)openTouchId:(BOOL)config{
    self.context = [[LAContext alloc] init];
    NSError* error = nil;
    if ([_context canEvaluatePolicy:1 error:&error]) {
        if (!error && !config) {
            [self touchId:_context andLockOut:NO];
        }
        return YES;
    }else{
        switch (error.code) {
            case LAErrorPasscodeNotSet:{
               NSLog(@"Authentication could not be started because the device does not have a password set.");
                break;
            }
            case LAErrorTouchIDNotEnrolled:{
                break;
            }
            case LAErrorTouchIDLockout:{
                [self touchId:_context andLockOut:YES];
                return YES;
                break;
            }
            default:{
                NSLog(@"TouchID is not available");
                break;
            }
        }

    }
    return NO;
}

- (void)touchId:(LAContext *)contxt andLockOut:(BOOL)lock{
    
    self.context.localizedFallbackTitle = !lock?@"Please try again":@"Use password";

    NSInteger lopli =  lock?LAPolicyDeviceOwnerAuthentication:LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    NSString * result_cn = !lock?@"Please verify the existing fingerprint":@"Error Require password to enable TouchID";

    [contxt evaluatePolicy:lopli localizedReason:result_cn reply:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Successful verification");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"Verified"
                 object:nil];
            });
        }else{
            switch (error.code) {
                case LAErrorSystemCancel:{
                    break;
                }
                case LAErrorUserCancel:{
                    NSLog(@"user cancelled");
                 //   [self touchId:contxt andLockOut:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]
                        postNotificationName:@"notVerified"
                        object:nil];
                    });
                    
                    break;
                }
                case LAErrorAuthenticationFailed:{
                    if ([error.localizedDescription isEqualToString:@"Application retry limit exceeded."]){
                        [self touchId:contxt andLockOut:NO];
                    }
                    break;
                }
                case LAErrorPasscodeNotSet:{
                    break;
                }
                case LAErrorTouchIDNotAvailable:{
                    break;
                }
                case LAErrorUserFallback:{
                     [self touchId:contxt andLockOut:NO];
                    break;
                }
                case LAErrorTouchIDLockout:{
                    if ([error.localizedDescription isEqualToString:@"Biometry is disabled for unlock."]){
                        [self touchId:contxt andLockOut:NO];
                    } else if ([error.localizedDescription isEqualToString:@"Biometry is locked out."]){
                        [self touchId:contxt andLockOut:YES];
                    }
                    break;
                }
                case LAErrorAppCancel:{
                    NSLog(@"cancelled");
                    break;
                }
                default:{
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    }];
                    break;
                }
            }
        }
    }];
}





@end
