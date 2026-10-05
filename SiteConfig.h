//
//  SiteConfig.h
//  LinkSafe
//
//  Created by Kiran on 22/08/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeWallpapers : NSObject

@property (nonatomic, retain) NSString *phoneUrl;
@property (nonatomic, retain) NSString *tabletUrl;
-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface InternalWallpapers : NSObject

@property (nonatomic, retain) NSString *phoneUrl;
@property (nonatomic, retain) NSString *tabletUrl;
-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface TemperatureRange : NSObject

@property (nonatomic) double minimum;
@property (nonatomic) double maximum;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface SkinTemperature : NSObject

@property (nonatomic) BOOL isTemperatureMandatoryContractor;
@property (nonatomic) BOOL isTemperatureMandatoryVisitor;
@property (nonatomic, retain) TemperatureRange *allowedTemperatureRange;
@property (nonatomic) double minimum;
@property (nonatomic) double maximum;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface CustomQuestion : NSObject

@property (nonatomic) BOOL isEnabled;
@property (nonatomic, retain) NSString *questionText;
@property (nonatomic) int maxLength;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface CustomQuestionScreen : NSObject

@property (nonatomic, retain) CustomQuestion *contractor;
@property (nonatomic, retain) CustomQuestion *visitor;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface SiteApprover : NSObject

@property (nonatomic) BOOL isEnabled;
@property (nonatomic, retain) NSString *instructions;
@property (nonatomic, retain) NSString *nameLabelText;
@property (nonatomic, retain) NSString *signatureLabelText;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface SiteApproverScreen : NSObject

@property (nonatomic, retain) SiteApprover *contractor;
@property (nonatomic, retain) SiteApprover *visitor;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

@interface SiteConfig : NSObject

@property (nonatomic, retain) NSString *siteName;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *homeScreenLogoUrl;
@property (nonatomic, retain) NSString *internalScreenLogoUrl;
@property (nonatomic, retain) NSString *homeScreenForegroundColor;
@property (nonatomic, retain) NSString *baseColor;
@property (nonatomic) BOOL isSiteRegisterEnabled;
@property (nonatomic) BOOL isSpotCheckUser;
@property (nonatomic) BOOL isPhotoRequiredSignInContractor;
@property (nonatomic) BOOL isPhotoRequiredSignInVisitor;
@property (nonatomic) BOOL isPhotoRequiredSignOutContractor;
@property (nonatomic) BOOL isPhotoRequiredSignOutVisitor;
@property (nonatomic) BOOL isSignatureRequiredContractor;
@property (nonatomic) BOOL isSignatureRequiredVisitor;
//@property (nonatomic) BOOL isContactSelectionEnabled;
@property (nonatomic) BOOL isContactSelectionEnabledContractor;
@property (nonatomic) BOOL isContactSelectionEnabledVisitor;
@property (nonatomic, retain) NSString *nonComplianceText;
@property (nonatomic) BOOL isContractorsButtonVisible;
@property (nonatomic, retain) NSString *contractorsButtonText;
@property (nonatomic) BOOL isVisitorsButtonVisible;
@property (nonatomic, retain) NSString *visitorsButtonText;
@property (nonatomic) BOOL isSignInByExceptionEnabled;
@property (nonatomic) BOOL isDeclineEntryEnabled;
@property (nonatomic) BOOL isWorkLocationScreenVisible;
@property (nonatomic) BOOL isWorkPermitsEnabled;
@property (nonatomic) BOOL isRiskAssessmentUploadMandatory;
@property (nonatomic) BOOL isSwmsUploadMandatory;
@property (nonatomic, retain) NSString *workPermitIncorrectAnswerMessage;
@property (nonatomic) BOOL isWorkPermitPasswordVisible;
@property (nonatomic, retain) NSString *workPermitConfirmationMessage;
@property (nonatomic, retain) NSString *workPermitPasswordLabel;
@property (nonatomic) BOOL isSignInAcceptanceScreenVisible;
@property (nonatomic, retain) NSString *signInAcceptanceMessage;
@property (nonatomic) BOOL isSignOutAcceptanceScreenVisible;
@property (nonatomic, retain) NSString *signOutAcceptanceMessage;
@property (nonatomic, retain) NSString *signInCompletionMessage;
@property (nonatomic, retain) NSArray *visitorFields;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, retain) InternalWallpapers *internalWallpapers;
@property (nonatomic, retain) NSString *internalWallpapersPhoneUrl;
@property (nonatomic, retain) NSString *internalWallpapersTabletUrl;
@property (nonatomic, retain) HomeWallpapers *homeWallpapers;
@property (nonatomic, retain) NSString *homeWallpapersPhoneUrl;
@property (nonatomic, retain) NSString *homeWallpapersTabletUrl;
@property (nonatomic, retain) NSNumber *errorNumber;
@property (nonatomic) BOOL success;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *token;
@property (nonatomic) BOOL rememberMe;
@property (nonatomic, retain) NSString *permitSelectionPreamble;
@property (nonatomic, retain) NSString *permitBypassPromptText;
@property (nonatomic, retain) SkinTemperature *skinTemperature;
@property (nonatomic, retain) CustomQuestionScreen *customQuestionScreen;
@property (nonatomic, retain) SiteApproverScreen *signInApprovalScreen;
@property (nonatomic, retain) NSArray *contractorIdentificationMethods;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *maximumPermitFileLength;
-(BOOL)isMobileLoginEnable;
-(instancetype)initWithDic:(NSDictionary *)dic;

@end




/*
 {
 "isSignInAcceptanceScreenVisible" : true,
 "errorMessage" : null,
 "internalWallpapers" : {
 "phoneUrl" : "https:\/\/www.app.complyme.com.au\/Wallpaper.ashx?id=BDD0CD2B3A952B5EAD5AD36AF8FC5843&device=phone&size=fullsize",
 "tabletUrl" : "https:\/\/www.app.complyme.com.au\/Wallpaper.ashx?id=BDD0CD2B3A952B5EAD5AD36AF8FC5843&device=tablet&size=fullsize"
 },
 "workPermitPasswordLabel" : "password",
 "isPhotoRequiredSignOutContractor" : false,
 "homeScreenForegroundColor" : "#74828C",
 "isWorkPermitPasswordVisible" : true,
 "isWorkPermitsEnabled" : true,
 "errorNumber" : null,
 "isWorkLocationScreenVisible" : true,
 "isPhotoRequiredSignOutVisitor" : false,
 "isContractorsButtonVisible" : true,
 "isVisitorsButtonVisible" : true,
 "visitorsButtonText" : "VISITOR",
 "workPermitConfirmationMessage" : "",
 "contractorsButtonText" : "CONTRACTOR",
 "isPhotoRequiredSignInContractor" : true,
 "isSignInByExceptionEnabled" : false,
 "isSwmsUploadMandatory" : true,
 "visitorFields" : {
 "phone" : {
 "behaviour" : "Mandatory",
 "labelText" : "Phone"
 },
 "vehicleRegistrationNumber" : {
 "behaviour" : "Mandatory",
 "labelText" : "Vehicle Registration No."
 },
 "firstName" : {
 "behaviour" : "Mandatory",
 "labelText" : "First Name"
 },
 "custom1" : {
 "behaviour" : "Hidden",
 "labelText" : "Custom1"
 },
 "custom2" : {
 "behaviour" : "Hidden",
 "labelText" : "Custom2"
 },
 "title" : {
 "behaviour" : "Mandatory",
 "labelText" : "Title"
 },
 "custom3" : {
 "behaviour" : "Hidden",
 "labelText" : "Custom3"
 },
 "custom4" : {
 "behaviour" : "Hidden",
 "labelText" : "Custom4"
 },
 "custom5" : {
 "behaviour" : "Hidden",
 "labelText" : "Custom5"
 },
 "organisation" : {
 "behaviour" : "Mandatory",
 "labelText" : "Organisation"
 },
 "lastName" : {
 "behaviour" : "Mandatory",
 "labelText" : "Last Name"
 }
 },
 "signInCompletionMessage" : "custom message",
 "isRiskAssessmentUploadMandatory" : true,
 "isContactSelectionEnabled" : false,
 "isSignatureRequiredVisitor" : true,
 "internalScreenLogoUrl" : "https:\/\/api.linksafe.com.au\/1.0\/VisitorManagementApp\/LogoImage?action2=K7qbMS6uX2quO7azXwRnA%2FpIQYQSRP7unK03AYj%2B%2FH94Iz3S6SIGe8A5iD9b%2BFh3nqWCpAPZIAM%3D",
 "isDeclineEntryEnabled" : true,
 "workPermitIncorrectAnswerMessage" : "error message",
 "homeWallpapers" : {
 "phoneUrl" : "https:\/\/www.app.complyme.com.au\/Wallpaper.ashx?id=A102D1016907ECB620615B8BA2F342A8&device=phone&size=fullsize",
 "tabletUrl" : "https:\/\/www.app.complyme.com.au\/Wallpaper.ashx?id=A102D1016907ECB620615B8BA2F342A8&device=tablet&size=fullsize"
 },
 "isPhotoRequiredSignInVisitor" : true,
 "signInAcceptanceMessage" : "custom message",
 "homeScreenLogoUrl" : "https:\/\/api.linksafe.com.au\/1.0\/VisitorManagementApp\/LogoImage?action2=K7qbMS6uX2quO7azXwRnA%2FpIQYQSRP7unK03AYj%2B%2FH94Iz3S6SIGe5YQkOC5CN0F",
 "baseColor" : "#2779BA",
 "siteName" : "Test Site 4",
 "success" : true,
 "title" : "Verify Contractor",
 "isSiteRegisterEnabled" : true,
 "isSignatureRequiredContractor" : true,
 "nonComplianceText" : "Not Compliant. Please refer to the Facilities Manager"
 }
 */
