//
//  SiteConfig.m
//  LinkSafe
//
//  Created by Kiran on 22/08/18.
//  Copyright © 2018 Vladislav Kovalyov. All rights reserved.
//

#import "SiteConfig.h"

@implementation HomeWallpapers

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    
    self.phoneUrl = [dic objectForKey:@"phoneUrl"];
    self.tabletUrl = [dic objectForKey:@"tabletUrl"];
    return self;
}

@end

@implementation InternalWallpapers

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    
    self.phoneUrl = [dic objectForKey:@"phoneUrl"];
    self.tabletUrl = [dic objectForKey:@"tabletUrl"];
    
    return self;
}

@end

@implementation TemperatureRange

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    self.maximum = [[dic valueForKey:@"maximum"] doubleValue];
    self.minimum = [[dic valueForKey:@"minimum"] doubleValue];
    
    return self;
}

@end

@implementation SkinTemperature

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    if ([[dic objectForKey:@"allowedTemperatureRange"] isKindOfClass:[NSDictionary class]] || [[dic objectForKey:@"allowedTemperatureRange"] isKindOfClass:[NSMutableDictionary class]]) {
        self.allowedTemperatureRange = [[TemperatureRange alloc] initWithDic:[dic objectForKey:@"allowedTemperatureRange"]];
        self.maximum = [[dic valueForKeyPath:@"allowedTemperatureRange.maximum"] doubleValue];
        self.minimum = [[dic valueForKeyPath:@"allowedTemperatureRange.minimum"] doubleValue];
    }
    self.isTemperatureMandatoryVisitor = [[dic objectForKey:@"isTemperatureMandatoryVisitor"] boolValue];
    self.isTemperatureMandatoryContractor = [[dic objectForKey:@"isTemperatureMandatoryContractor"] boolValue];
    return self;
}

@end

@implementation CustomQuestion

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    self.isEnabled = [[dic objectForKey:@"isEnabled"] boolValue];
    self.maxLength = [[dic objectForKey:@"maxLength"] intValue];
    self.questionText = [dic objectForKey:@"questionText"];
    return self;
}

@end

@implementation CustomQuestionScreen

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    if ([[dic objectForKey:@"contractor"] isKindOfClass:[NSDictionary class]] || [[dic objectForKey:@"contractor"] isKindOfClass:[NSMutableDictionary class]]) {
        self.contractor = [[CustomQuestion alloc] initWithDic:[dic objectForKey:@"contractor"]];
    }
    if ([[dic objectForKey:@"visitor"] isKindOfClass:[NSDictionary class]] || [[dic objectForKey:@"visitor"] isKindOfClass:[NSMutableDictionary class]]) {
        self.visitor = [[CustomQuestion alloc] initWithDic:[dic objectForKey:@"visitor"]];
    }
    return self;
}

@end

@implementation SiteApprover

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    self.isEnabled = [[dic objectForKey:@"isEnabled"] boolValue];
    self.instructions = [dic objectForKey:@"instructions"];
    self.nameLabelText = [dic objectForKey:@"nameLabelText"];
    self.signatureLabelText = [dic objectForKey:@"signatureLabelText"];
    return self;
}

@end

@implementation SiteApproverScreen

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (!self) {
        self = [super init];
    }
    if ([dic isKindOfClass:[NSString class]] || [dic isKindOfClass:[NSMutableString class]]) {
        return self;
    }
    if ([[dic objectForKey:@"contractor"] isKindOfClass:[NSDictionary class]] || [[dic objectForKey:@"contractor"] isKindOfClass:[NSMutableDictionary class]]) {
        self.contractor = [[SiteApprover alloc] initWithDic:[dic objectForKey:@"contractor"]];
    }
    if ([[dic objectForKey:@"visitor"] isKindOfClass:[NSDictionary class]] || [[dic objectForKey:@"visitor"] isKindOfClass:[NSMutableDictionary class]]) {
        self.visitor = [[SiteApprover alloc] initWithDic:[dic objectForKey:@"visitor"]];
    }
    return self;
}

@end

@implementation SiteConfig

-(instancetype)init
{
    if ( !self ) {
        self = [super init];
    }
    return self;
}

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if ( !self ) {
        self = [super init];
    }
    
    self.siteName = [dic objectForKey:@"siteName"];
    self.title = [dic objectForKey:@"title"];
    self.homeScreenLogoUrl = [dic objectForKey:@"homeScreenLogoUrl"];
    self.internalScreenLogoUrl = [dic objectForKey:@"internalScreenLogoUrl"];
    self.homeScreenForegroundColor = [dic objectForKey:@"homeScreenForegroundColor"];
    self.baseColor = [dic objectForKey:@"baseColor"];
    self.isSiteRegisterEnabled = [[dic objectForKey:@"isSiteRegisterEnabled"] boolValue];
    self.isSpotCheckUser = [[dic objectForKey:@"isSpotCheckUser"] boolValue];
    self.isPhotoRequiredSignInContractor = [[dic objectForKey:@"isPhotoRequiredSignInContractor"] boolValue];
    self.isPhotoRequiredSignInVisitor = [[dic objectForKey:@"isPhotoRequiredSignInVisitor"] boolValue];
    self.isPhotoRequiredSignOutContractor = [[dic objectForKey:@"isPhotoRequiredSignOutContractor"] boolValue];
    self.isPhotoRequiredSignOutVisitor = [[dic objectForKey:@"isPhotoRequiredSignOutVisitor"] boolValue];
    self.isSignatureRequiredContractor = [[dic objectForKey:@"isSignatureRequiredContractor"] boolValue];
    self.isSignatureRequiredVisitor = [[dic objectForKey:@"isSignatureRequiredVisitor"] boolValue];
//    self.isContactSelectionEnabled = [[dic objectForKey:@"isContactSelectionEnabled"] boolValue];
    self.isContactSelectionEnabledContractor = [[dic objectForKey:@"isContactSelectionEnabledContractor"] boolValue];
    self.isContactSelectionEnabledVisitor = [[dic objectForKey:@"isContactSelectionEnabledVisitor"] boolValue];
    self.nonComplianceText = [dic objectForKey:@"nonComplianceText"];
    self.isContractorsButtonVisible = [[dic objectForKey:@"isContractorsButtonVisible"] boolValue];
    self.contractorsButtonText = [dic objectForKey:@"contractorsButtonText"];
    self.isVisitorsButtonVisible = [[dic objectForKey:@"isVisitorsButtonVisible"] boolValue];
    self.visitorsButtonText = [dic objectForKey:@"visitorsButtonText"];
    self.isSignInByExceptionEnabled = [[dic objectForKey:@"isSignInByExceptionEnabled"] boolValue];
    self.isDeclineEntryEnabled = [[dic objectForKey:@"isDeclineEntryEnabled"] boolValue];
    self.isWorkLocationScreenVisible = [[dic objectForKey:@"isWorkLocationScreenVisible"] boolValue];
    self.isWorkPermitsEnabled = [[dic objectForKey:@"isWorkPermitsEnabled"] boolValue];
    self.isRiskAssessmentUploadMandatory = [[dic objectForKey:@"isRiskAssessmentUploadMandatory"] boolValue];
    self.isSwmsUploadMandatory = [[dic objectForKey:@"isSwmsUploadMandatory"] boolValue];
    self.workPermitIncorrectAnswerMessage = [dic objectForKey:@"workPermitIncorrectAnswerMessage"];
    self.isWorkPermitPasswordVisible = [[dic objectForKey:@"isWorkPermitPasswordVisible"] boolValue];
    self.workPermitConfirmationMessage = [dic objectForKey:@"workPermitConfirmationMessage"];
    self.workPermitPasswordLabel = [dic objectForKey:@"workPermitPasswordLabel"];
    self.isSignInAcceptanceScreenVisible = [[dic objectForKey:@"isSignInAcceptanceScreenVisible"] boolValue];
    self.signInAcceptanceMessage = [dic objectForKey:@"signInAcceptanceMessage"];
    self.isSignOutAcceptanceScreenVisible = [[dic objectForKey:@"isSignOutAcceptanceScreenVisible"] boolValue];
    self.signOutAcceptanceMessage = [dic objectForKey:@"signOutAcceptanceMessage"];
    self.signInCompletionMessage = [dic objectForKey:@"signInCompletionMessage"];
    self.visitorFields = [dic objectForKey:@"visitorFields"];
    self.errorMessage = [dic objectForKey:@"errorMessage"];
    self.errorNumber = [dic objectForKey:@"errorNumber"];
    self.success = [dic objectForKey:@"success"];
    self.permitSelectionPreamble = [dic objectForKey:@"permitSelectionPreamble"];
    self.permitBypassPromptText = [dic objectForKey:@"permitBypassPromptText"];
    
    self.homeWallpapers = [[HomeWallpapers alloc] initWithDic:[dic objectForKey:@"homeWallpapers"]];
    self.homeWallpapersPhoneUrl = _homeWallpapers.phoneUrl;
    self.homeWallpapersTabletUrl = _homeWallpapers.tabletUrl;
    
    self.internalWallpapers = [[InternalWallpapers alloc] initWithDic:[dic objectForKey:@"internalWallpapers"]];
    self.internalWallpapersPhoneUrl = _internalWallpapers.phoneUrl;
    self.internalWallpapersTabletUrl = _internalWallpapers.tabletUrl;
    
    self.skinTemperature = [[SkinTemperature alloc] initWithDic:[dic objectForKey:@"temperature"]];
    self.customQuestionScreen = [[CustomQuestionScreen alloc] initWithDic:[dic objectForKey:@"customQuestionScreen"]];
    self.signInApprovalScreen = [[SiteApproverScreen alloc] initWithDic:[dic objectForKey:@"signInApprovalScreen"]];
    
    self.contractorIdentificationMethods = [dic objectForKey:@"contractorIdentificationMethods"];
//    self.contractorIdentificationMethods = @[@"pin", @"qrcode", @"phone"];
    self.country = [dic objectForKey:@"country"];
    if (self.country == nil) {
        self.country = @"AU";
    }
    self.maximumPermitFileLength = [dic objectForKey:@"maximumPermitFileLength"];
//    //test
//    self.isSignOutAcceptanceScreenVisible = YES;
//    self.signOutAcceptanceMessage = @"Test sign out message.";
//    self.permitSelectionPreamble = @"Test\nHeader\nLine.";
//    self.permitBypassPromptText = @"Test bypass prompt text here.";
//    self.isRiskAssessmentUploadMandatory = NO;
//    self.isSwmsUploadMandatory = NO;
    
    return self;
}
-(BOOL)isMobileLoginEnable
{
    return [self.contractorIdentificationMethods containsObject:@"phone"]
    || [self.contractorIdentificationMethods containsObject:KEY_MOBILE];
//    return true;
}

@end
