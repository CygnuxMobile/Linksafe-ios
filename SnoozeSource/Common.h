//
//  Common.h
//  LinkSafe
//
//  Created by Hitesh Gs on 7/9/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//


//Colors

#define kGetThemeColor ([[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"baseColor"] ? [Common colorFromHexString:[[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"baseColor"]] : kThemeBlueColor)

#define kThemeGreyButtom ([[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"baseColor"] ? [Common colorFromHexString:[[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"baseColor"]] : kThemeBGGrey)


#define kGetHomeLabelColor ([[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"homeScreenForegroundColor"] ? [Common colorFromHexString:[[USER_DEFAULT  valueForKey:SITE_DATA] valueForKey:@"homeScreenForegroundColor"]] : [UIColor whiteColor])

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGB(_r,_g,_b)               [UIColor colorWithRed:_r/255.0 green:_g/255.0 blue:_b/255.0 alpha:1.0]

#define RGBT(_r,_g,_b)              [UIColor colorWithRed:_r/255.0 green:_g/255.0 blue:_b/255.0 alpha:0.7]

//[UIColor colorWithPatternImage:[UIImage imageNamed:@"redColorImage.png"]]

#define kThemeBlueColor              RGB(26.0,180.0,144.0)
#define kThemeBlueShedowColor        RGB(137.0, 155.0, 191.0)

#define kThemeGreyValue(_amount)     RGB(_amount,_amount,_amount)
#define kThemeOrangeColor            RGB(239, 123.0, 54.0)

//#define kThemeGreyButtom            RGB(39.0, 55.0, 70.0)
#define kThemeBGGrey                RGBT(39.0, 55.0, 70.0)

//Fonts

//Myriad Pro    Font: MyriadPro-Regular

#define kThemeRegularFonts(_size)    [UIFont fontWithName:@"MyriadPro-Regular" size:_size]
//#define kThemeBoldFonts(_size)       [UIFont fontWithName:@"Myriad Pro-Bold" size:_size]


#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CheckNetworkConnection/Reachability.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "BRPrintResultViewController.h"
#import "UserDefaults.h"

typedef NS_ENUM(NSInteger, TEST_ENVIRONMENT_OPTION) {
    TestEnvironmentOptionNotAvailable = 0,
    TestEnvironmentOptionAvailable = 1,
    TestEnvironmentOptionWantToTesting = 2,
    TestEnvironmentOptionGoneWithTesting = 3
};

@interface Common : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (BOOL)validateEmailAddress:(NSString*)email;

+ (BOOL)validateSkinTemperature:(NSString*)strTemperature;

+(NSString *)removeWhiteSpace :(NSString *)str;

+(void)showAlert :(NSString *)title :(NSString *)message;

+(BOOL)isInternetAvailable;

+(BOOL)checkInternetConnectionWithoutMessage;

+(BOOL)isSiteLogedIn;

+(NSMutableArray *)getAcknowledgedMessageBoards;

+(void)callVisitorSignInAPI:(NSMutableDictionary *)parameters ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler;

+(void)callContractorSignInAPI:(NSMutableDictionary *)dicPic ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler;

+(void)callContractorSignOutAPI:(NSMutableDictionary *)dicParameters ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler;

+(void)callAPI :(NSMutableDictionary *)parameters Request:(NSString *)api ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id responseObject))handler;

//+(void)callAPIVersion_2:(NSMutableDictionary *)parameters Request:(NSString *)api ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id responseObject))handler;

//+(void)callApiInBackground :(NSMutableDictionary *)parameters Request:(NSString *)api ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler;

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;

+(NSIndexPath *)getIndexPath :(UIButton *)sender :(UITableView *)tbl;

+(NSString*)getFilePath :(NSString *)fileName;

+(void)updateTime :(UIView *)mainVCView;

+ (UIImage *)reSize:(UIImage *)originalImage;

+(void)applyThemeColorToPowerdBy:(UIView *)view;

+(void)showProgress;

+(void)hideProgress;

+(UIStoryboard *)mainStoryboard;

+(UIStoryboard *)constraintStoryboard;

+(UIFont *)calibriFont:(CGFloat)fontSize;

+(void)removeLogoImage;

+(void)removeHomeBackgroundImage;

+(void)removeInternalBackgroundImage;

+(NSDateFormatter *)dateFormatter;

+ (void)ApplyUIViewBoeder:(UIView *)myview;

+(void)removeSiteData;

+ (void)ApplyUIViewTheme:(UIView *)myview;

+ (void)ApplyClearUIViewTheme:(UIView *)myview;

+(void)saveSiteToken :(NSString *)tokenInfo rememberMe:(NSString *)flagremember;

+(NSMutableDictionary *)SiteData;

+(NSMutableDictionary *)addDefaultParameter:(NSMutableDictionary *)parameter;

+(void)storeSiteData:(NSMutableDictionary *)siteInfo;

+(AppDelegate *)appDelegate;

+(void)showWarning :(NSString *)title :(NSString *)message;

+(void)showSuccess :(NSString *)title :(NSString *)message;

+(BOOL)SaveLinkSafeBGImage:(NSData *)pngData withName:(NSString *)fileName;

+(UIImage *)OpenLinkSafeFileOfName:(NSString *)fileName;

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

+ (NSString *)encodeToBase64String:(UIImage *)image;

+ (NSString *)encodeToBase64StringPDF:(NSData *)fileData;

+(void)loadImagewithURL:(NSString *)imageUrl;

+(void)loadLogo:(AsyncImageView *)imageView;

+(void)setBgImage:(UIView *)view useDefault:(BOOL) Default;

+(BOOL)isNumberValid:(NSString *)phoneSring;

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;

//+ (BRPtouchPrinter *) prepareForPtp;

+ (BRLMChannel *) prepareForPtp;

+ (void) initWithUserDefault;

+ (NSString*)getPhoneNumber:(NSString *)txtPhone;

+ (void)SetTestEnviromentWithOption:(enum TEST_ENVIRONMENT_OPTION) testOption;

+(NSMutableDictionary *)TurnNumberOrNull:(NSMutableDictionary *)dicParameters;

+(NSString *)GetMaskedIfPhone:(NSString *)strPhone forKay:(NSString *) key;

@end
