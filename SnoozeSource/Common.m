//
//  Common.m
//  LinkSafe
//
//  Created by Hitesh Gs on 7/9/16.
//  Copyright © 2016 CygnusSoftTech All rights reserved.
//

#import "Common.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "FTIndicator.h"
#import "MFSideMenu.h"

@implementation Common



+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark Validate_Email_Address

+ (BOOL)validateEmailAddress:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark Validate_Email_Address
+ (BOOL)validateSkinTemperature:(NSString*)strTemperature
{
    SiteConfig *config = [Common appDelegate].config;
    if (strTemperature.length == 0) {
        return NO;
    }
    double temperature = [strTemperature doubleValue];
    if (temperature < config.skinTemperature.minimum || temperature > config.skinTemperature.maximum) {
        return NO;
    }
    return YES;
}

#pragma mark Remove_White_Space

+(NSString *)removeWhiteSpace :(NSString *)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return str;
}

#pragma mark Remove_zero_From_Phone_String

+(NSString*)getPhoneNumber:(NSString *)txtPhone {
    NSString *strPhone = [Common removeWhiteSpace:txtPhone];
    if([strPhone hasPrefix:@"0"]) {
        strPhone = [strPhone substringFromIndex:1];
    }
    return strPhone;
}

#pragma mark Show_Alert

+(void)showAlert :(NSString *)title :(NSString *)message
{
    //    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    //
    //    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //    }];
    //    [controller addAction:alertAction];
    //    [[self appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
    //    }];
    
    [FTIndicator showErrorWithMessage:[NSString stringWithFormat:@"%@\n%@",title,message]];
}

+(void)showWarning :(NSString *)title :(NSString *)message
{
    [FTIndicator showInfoWithMessage:[NSString stringWithFormat:@"%@\n%@",title,message]];
}

+(void)showSuccess :(NSString *)title :(NSString *)message
{
    [FTIndicator showSuccessWithMessage:[NSString stringWithFormat:@"%@\n%@",title,message]];
}

#pragma mark - Call_API
+(NSString *)GetWebServiceURL
{
    enum TEST_ENVIRONMENT_OPTION testOption = [self GetTestEnviromentWithOption];
    if (testOption == TestEnvironmentOptionWantToTesting || testOption == TestEnvironmentOptionGoneWithTesting) {
        return TESTING_WEB_SERVICE_URL;
    }
    return WEB_SERVICE_URL;
}

//+(NSString *)GetWebServiceURLForUser:(NSString *)username
//{
//    if ([username hasPrefix:@"test_"]) {
//        return TESTING_WEB_SERVICE_URL;
//    }
//    
//    
//    return WEB_SERVICE_URL;
//}

+(void)SetTestEnviromentWithOption:(enum TEST_ENVIRONMENT_OPTION) testOption
{
    [USER_DEFAULT setObject:[NSNumber numberWithInt:testOption] forKey:KEY_ENVIRONMENT_OPTION];
    [USER_DEFAULT synchronize];
}
+(enum TEST_ENVIRONMENT_OPTION)GetTestEnviromentWithOption
{
    enum TEST_ENVIRONMENT_OPTION testOption=TestEnvironmentOptionNotAvailable;
    
    if ([USER_DEFAULT valueForKey:KEY_ENVIRONMENT_OPTION]) {
        NSNumber *testOptionSaved=[USER_DEFAULT valueForKey:KEY_ENVIRONMENT_OPTION];
        if ([testOptionSaved intValue]==0)testOption=TestEnvironmentOptionNotAvailable;
        else if ([testOptionSaved intValue]==1)testOption=TestEnvironmentOptionAvailable;
        else if ([testOptionSaved intValue]==2)testOption=TestEnvironmentOptionWantToTesting;
        else if ([testOptionSaved intValue]==3)testOption=TestEnvironmentOptionGoneWithTesting;
    }
    return testOption;
}
//KIRAN START
+(void)callVisitorSignInAPI:(NSMutableDictionary *)parameters ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler
{
    if ([Common appDelegate].config.isSignInAcceptanceScreenVisible && [Common appDelegate].config.signInAcceptanceMessage.length > 0)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[Common appDelegate].config.signInAcceptanceMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [parameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
            [Common callAPI:parameters Request:REQUEST_VISITORSIGN ShowProgress:YES WithCompletionHandler:^(id responseObject)
             {
                handler(responseObject);
            }];
        }];
        [controller addAction:alertAction];
        
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UINavigationController *navController = (UINavigationController *)[Common appDelegate].window.rootViewController;
            if ([navController isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                MFSideMenuContainerViewController *containerVC = (MFSideMenuContainerViewController *)navController;
                UINavigationController *navigationController = containerVC.centerViewController;
                [navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [navController popToRootViewControllerAnimated:YES];
            }
        }];
        [controller addAction:alertActionCancel];
        
        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
        }];
    }
    else
    {
        [parameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
        [Common callAPI:parameters Request:REQUEST_VISITORSIGN ShowProgress:YES WithCompletionHandler:^(id responseObject)
         {
            handler(responseObject);
        }];
    }
}

+(void)callContractorSignInAPI:(NSMutableDictionary *)dicPic ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler
{
    NSMutableDictionary *dicParameters = [[NSMutableDictionary alloc] init];
    [dicParameters setObject:[USER_DEFAULT valueForKey:KEY_CONTRACTOR_PIN] forKey:KEY_PIN];
    
    SiteConfig *config = [Common appDelegate].config;
    if (config.isPhotoRequiredSignInContractor)
    {
        [dicParameters setObject:[dicPic valueForKey:@"photoUri"] forKey:@"photoUri"];
    }
    
    if (config.isSignatureRequiredContractor)
    {
        [dicParameters setObject:[dicPic valueForKey:@"guestSignatureUri"] forKey:@"guestSignatureUri"];
    }
    
    if (config.isWorkPermitsEnabled && [[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_WORKPERMIT_FORM_ID]] intValue]>0)
    {
        [dicParameters setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_WORKPERMIT_FORM_ID]] intValue]] forKey:KEY_WORKPERMIT_FORM_ID];
    }
    if ([dicPic valueForKey:KEY_WORK_OrderID])
    {
        [dicParameters setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_WORK_OrderID]] intValue]] forKey:KEY_WORK_OrderID];
    }
    
    if ([dicPic valueForKey:KEY_WORK_Location])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_WORK_Location]] forKey:KEY_WORK_Location];
    }
    
    if ([dicPic valueForKey:KEY_SignInHandle])
    {
        [dicParameters setObject:[dicPic valueForKey:KEY_SignInHandle] forKey:KEY_SignInHandle];
    }
    
    if ([dicPic valueForKey:KEY_CONTACT_ID])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_CONTACT_ID]] forKey:KEY_CONTACT_ID];
    }
    
    if ([dicPic valueForKey:@"approverName"])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:@"approverName"]] forKey:@"approverName"];
    }
    
    if ([dicPic valueForKey:@"approverSignatureUri"])
    {
        [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:@"approverSignatureUri"]] forKey:@"approverSignatureUri"];
    }
    
    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_WORK_ENABLED]];
    
    if([strIsSpotCheckUser isEqualToString:@"true"]){
        NSDictionary *dict = [[NSDictionary alloc]init];
        NSUserDefaults *userContractorWork = [NSUserDefaults standardUserDefaults];
        dict = [userContractorWork valueForKey:@"userContractorWork"];
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        arr = [dict objectForKey:@"workTypeID"];
        NSString *str = [dict valueForKey:@"workTypeOther"];
        
        [dicParameters setObject:str forKey:@"workTypeOther"];
        [dicParameters setObject:arr forKey:@"workTypeID"];
    }
    
    NSString *api = @"";
    if ([[NSString stringWithFormat:@"%@",[dicPic objectForKey:@"isCompliant"]] boolValue])
    {
        api = REQUEST_SIGN_IN_CONTRACTOR;
        [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    }
    else
    {
        api = REQUEST_SignInException;
        if ([dicPic valueForKey:KEY_AuthorizedBy])
        {
            [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_AuthorizedBy]] forKey:KEY_AuthorizedBy];
        }
        
        if ([dicPic valueForKey:KEY_Notes])
        {
            [dicParameters setObject:[NSString stringWithFormat:@"%@",[dicPic valueForKey:KEY_Notes]] forKey:KEY_Notes];
        }
        
        [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    }
    
    if ([dicPic valueForKey:KEY_CUSTOM_QUE_ANS])
    {
        [dicParameters setObject:[dicPic valueForKey:KEY_CUSTOM_QUE_ANS] forKey:KEY_CUSTOM_QUE_ANS];
    }
    
    if ([dicPic valueForKey:KEY_CUSTOM_QUE_TEXT])
    {
        [dicParameters setObject:[dicPic valueForKey:KEY_CUSTOM_QUE_TEXT] forKey:KEY_CUSTOM_QUE_TEXT];
    }
    if ([dicParameters valueForKey:KEY_CONTACT_ID]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:[NSString stringWithFormat:@"%@",[dicParameters valueForKey:KEY_CONTACT_ID]]];
        [dicParameters setObject:myNumber forKey:KEY_CONTACT_ID];
    }
    if ([Common appDelegate].config.isSignInAcceptanceScreenVisible && [Common appDelegate].config.signInAcceptanceMessage.length > 0)
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@",[Common appDelegate].config.signInAcceptanceMessage] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSMutableDictionary *dicTempParameters = [Common TurnNumberOrNull:dicParameters];
            
            [Common callAPI:dicTempParameters Request:api ShowProgress:YES WithCompletionHandler:^(id responseObject)
             {
                handler(responseObject);
            }];
        }];
        [controller addAction:alertAction];
        
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UINavigationController *navController = (UINavigationController *)[Common appDelegate].window.rootViewController;
            if ([navController isKindOfClass:[MFSideMenuContainerViewController class]])
            {
                MFSideMenuContainerViewController *containerVC = (MFSideMenuContainerViewController *)navController;
                UINavigationController *navigationController = containerVC.centerViewController;
                [navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [navController popToRootViewControllerAnimated:YES];
            }
        }];
        [controller addAction:alertActionCancel];
        
        [[Common appDelegate].window.rootViewController presentViewController:controller animated:YES completion:^{
        }];
    }
    else
    {
        [Common callAPI:dicParameters Request:api ShowProgress:YES WithCompletionHandler:^(id responseObject)
         {
            handler(responseObject);
        }];
    }
}
+(void)callContractorSignOutAPI:(NSMutableDictionary *)dicParameters ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id))handler
{
    [dicParameters setObject:[Common getAcknowledgedMessageBoards] forKey:KEY_MESSAGE_BOARDS];
    
    [Common callAPI:dicParameters Request:API_SIGN_OUT_CONTRACTOR ShowProgress:YES WithCompletionHandler:^(id responseObject)
     {
        handler(responseObject);
    }];
}

//KIRAN END
+(void)callAPI :(NSMutableDictionary *)parameters Request:(NSString *)api ShowProgress:(BOOL)isProgress WithCompletionHandler:(void(^)(id responseObject))handler
{
    if ([Common isInternetAvailable]) {
        if (isProgress) {
            [Common showProgress];
        }
        
        parameters = [Common addDefaultParameter:parameters];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        }
        NSString *jsonStringParam = @"";
        if (jsonData) {
            jsonStringParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"PARAMETERS : %@",jsonStringParam);
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
//        NSString *username = parameters[KEY_SiteUser];
//        NSString *serviceURL = [self GetWebServiceURLForUser:username];
//        
//        NSLog(@"username : %@", username);
        
   //     [manager POST:[serviceURL stringByAppendingString:api] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
        [manager POST:[[Common GetWebServiceURL] stringByAppendingString:api] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                               options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                 error:&error];
            NSLog(@"-----------API : %@",[[Common GetWebServiceURL] stringByAppendingString:api]);
            if ([api isEqualToString:API_GET_SIGN_OUT_DOCUMENTS]) {
                NSLog(@"PARAMETERS : %@",jsonStringParam);
            }
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"RESPONSE : %@",jsonString);
            }
            responseObject = [Common removeNullFromResponse:responseObject];
            if (operation.response.statusCode == 200)
            {
                if (![[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
                {
                    NSLog(@"Error : %@ : Request : %@ : %@",[responseObject valueForKey:@"errorNumber"],[responseObject valueForKey:@"errorMessage"],api);
                    
                    if (isProgress)
                    {
                        NSLog(@"Error occur in api --> %@  Response ---> %@",api,responseObject);
                        if (![api isEqualToString:REQUEST_VISITORSIGN])
                        {
                            if ([responseObject valueForKey:@"msg"]) {
                                [Common showAlert:@"Message" :[responseObject valueForKey:@"msg"]];
                            }
                            //                             else  if ([responseObject valueForKey:@"errorMessage"]) {
                            //                                [Common showAlert:@"Alert" :[responseObject valueForKey:@"errorMessage"]];
                            //                             }
                        }
                    }
                }
            } else {
                NSLog(@"Error occur in api --> %@  Response ---> %@",api,responseObject);
                [Common showAlert:@"Error" :[responseObject valueForKey:@"msg"]];
            }
            
            handler(responseObject);
            
            if (isProgress) {
                [Common hideProgress];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (isProgress) {
                [Common hideProgress];
            }
            NSLog(@"API Direct failur occur in api --> %@  Response ---> %@",api,error.localizedDescription);
            [Common showAlert:@"Error" :error.localizedDescription];
        }];
    }
    
}

+(NSMutableDictionary *) removeNullFromResponse:(NSDictionary*)sourceDictionary
{
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:sourceDictionary];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    [sourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        object = [sourceDictionary objectForKey:key];
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *innerDict = object;
            [replaced setObject:[self removeNullFromResponse:innerDict] forKey:key];
            
        }
        else if([object isKindOfClass:[NSArray class]]){
            NSMutableArray *nullFreeRecords = [NSMutableArray array];
            for (id record in object) {
                
                if([record isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *nullFreeRecord = [self removeNullFromResponse:record];
                    [nullFreeRecords addObject:nullFreeRecord];
                }
                else if([record isKindOfClass:[NSString class]])
                {
                    [nullFreeRecords addObject:record];
                }
            }
            [replaced setObject:nullFreeRecords forKey:key];
        }
        else
        {
            if(object == nul) {
                [replaced setObject:blank forKey:key];
            }
        }
    }];
    
    return replaced;
}

#pragma mark - Progress
+(void)showProgress
{
    NSLog(@"------------------------------------showProgress");
    [Common appDelegate].window.userInteractionEnabled = false;
    [SVProgressHUD show];
}

+(void)hideProgress
{
    NSLog(@"------------------------------------hideProgress");
    [Common appDelegate].window.userInteractionEnabled = true;
    [SVProgressHUD dismiss];
}

+(AppDelegate *)appDelegate
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate;
}

+(BOOL)isNumberValid:(NSString *)phoneSring
{
    NSString *mobileNumberPattern = @"^[0-9]{6,14}$";
    NSPredicate *mobileNumberPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileNumberPattern];
    
    return [mobileNumberPred evaluateWithObject:phoneSring];
}

#pragma mark Main_Storyboard

+(BOOL)isInternetAvailable{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [Common showAlert:@"Connection Error" :@"It seems you are not connected to the internet, Kindly connect and try again."];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark Check_Internet_Connection_Without_Message

+(BOOL)checkInternetConnectionWithoutMessage
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        
        return NO;
    } else {
        return YES;
    }
}

+(NSIndexPath *)getIndexPath :(UIButton *)sender :(UITableView *)tbl
{
    CGPoint a_pointButtonPosition = [sender convertPoint:CGPointZero toView:tbl];
    NSIndexPath *a_indexPath = [tbl indexPathForRowAtPoint:a_pointButtonPosition];
    return a_indexPath;
}

+(NSString*)getFilePath :(NSString *)fileName
{
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFilePath = [path stringByAppendingPathComponent:fileName];
    
    return pdfFilePath;
}
+ (void)ApplyClearUIViewTheme:(UIView *)myview
{
    myview.backgroundColor = [UIColor clearColor];
}
+ (void)ApplyUIViewTheme:(UIView *)myview
{
    if (myview==nil)
    {
        return;
    }
    
    if ([self appDelegate].isIpad)
    {
        myview.layer.cornerRadius = 3.0f;
        [myview.layer setShadowRadius:3.0f];
        [myview.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
        [myview.layer setBorderWidth:1.0f];
    }
    else
    {
        myview.layer.cornerRadius = 2.0f;
        [myview.layer setShadowRadius:2.0f];
        [myview.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
        [myview.layer setBorderWidth:0.0f];
    }
    
    [myview.layer setBorderColor:kThemeGreyValue(215.0).CGColor];
    [myview.layer setShadowColor:kThemeGreyValue(215.0).CGColor];
    [myview.layer setShadowOpacity:0.3f];
}

+(void)applyThemeColorToPowerdBy:(UIView *)view
{
    if ([Common appDelegate].isIpad)
    {
        if (![view viewWithTag:10001]) {
            return;
        }
        UILabel *lblPowerdBy = (UILabel *)[view viewWithTag:10001];
        lblPowerdBy.textColor = kGetHomeLabelColor;
        lblPowerdBy.text = @"";
        UIImageView *imgPowerdBy = (UIImageView *)[view viewWithTag:10002];
        if (imgPowerdBy) {
            imgPowerdBy.image = [imgPowerdBy.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            imgPowerdBy.tintColor = kGetHomeLabelColor;
        }
    }
    else
    {
        if (![view viewWithTag:10001]) {
            return;
        }
        UILabel *lblPowerdBy = (UILabel *)[view viewWithTag:10001];
        lblPowerdBy.textColor = kGetHomeLabelColor;
        lblPowerdBy.text = @"LinkSafe Site";
    }
}

+ (void)ApplyUIViewBoeder:(UIView *)myview
{
    if (myview==nil)
    {
        return;
    }
    
    myview.layer.cornerRadius = 3.0f;
    [myview.layer setShadowRadius:3.0f];
    [myview.layer setBorderWidth:1.0f];
    
    [myview.layer setBorderColor:kThemeGreyValue(255.0).CGColor];
    [myview.layer setShadowColor:kThemeGreyValue(215.0).CGColor];
    [myview.layer setShadowOpacity:0.0f];
}

+(void)removeLogoImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataPath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error)
    {
        NSLog(@"create dic %@",error);
        return;
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",dataPath,F_LOGOFileName];
    NSError *removeError;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
    if (success)
    {
        NSLog(@"remove logo");
    }
    else
    {
        NSLog(@"%s----Could not delete file -: %@ ",__PRETTY_FUNCTION__,[removeError localizedDescription]);
    }
}

+(void)removeHomeBackgroundImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataPath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error)
    {
        NSLog(@"create dic %@",error);
        return;
    }
    NSString *filePathHome = [NSString stringWithFormat:@"%@/%@",dataPath,F_BGFileName];
    NSError *removeError;
    BOOL successHome = [[NSFileManager defaultManager] removeItemAtPath:filePathHome error:&removeError];
    if (successHome)
    {
        NSLog(@"remove Home background");
    }
    else
    {
        NSLog(@"%s----Could not delete file -: %@ ",__PRETTY_FUNCTION__,[removeError localizedDescription]);
    }
}

+(void)removeInternalBackgroundImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataPath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error)
    {
        NSLog(@"create dic %@",error);
        return;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",dataPath,F_InternalBGFileName];
    NSError *removeError;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
    if (success)
    {
        NSLog(@"remove internal background");
    }
    else
    {
        NSLog(@"%s----Could not delete file -: %@ ",__PRETTY_FUNCTION__,[removeError localizedDescription]);
    }
}

+(void)loadImagewithURL:(NSString *)imageUrl
{
    NSLog(@"logo start loading...");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        [self SaveLinkSafeBGImage:pngData withName:F_LOGOFileName];
    });
}

+(BOOL)SaveLinkSafeBGImage:(NSData *)pngData withName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataPath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (error)
    {
        NSLog(@"create dic %@",error);
        return false;
    }
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",dataPath,fileName];
    NSLog(@"logo load at path : %@",filePath);
    
    [pngData writeToFile:filePath atomically:YES];
    return true;
}

+(UIImage *)OpenLinkSafeFileOfName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],fileName];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [UIImage imageWithData:data];
}

+(void)setBgImage:(UIView *)view useDefault:(BOOL)isDefault
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([view viewWithTag:6601])
        {
            //            ((UIImageView *)[view viewWithTag:6601]).image = nil    ;
            //            return ;
            if ([Common OpenLinkSafeFileOfName:F_BGFileName] == NULL || isDefault)
            {
                UIImage *image = [Common OpenLinkSafeFileOfName:F_InternalBGFileName];
                ((UIImageView *)[view viewWithTag:6601]).image = image ? image : image;
            }
            else
            {
                ((UIImageView *)[view viewWithTag:6601]).image = [Common OpenLinkSafeFileOfName:F_BGFileName];
            }
        }
    });
}

+(UIStoryboard *)mainStoryboard
{
    AppDelegate *appDeligate=[Common appDelegate];
    if (appDeligate.isIpad)
    {
        return [UIStoryboard storyboardWithName:@"iPadMainStoryboard" bundle:[NSBundle mainBundle]];
    }
    else
    {
        return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
}

+(UIStoryboard *)constraintStoryboard
{
    AppDelegate *appDeligate = [Common appDelegate];
    if (appDeligate.isIpad) {
        return [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:[NSBundle mainBundle]];
    }
    else {
        return [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:[NSBundle mainBundle]];
    }
}


+(UIFont *)calibriFont :(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Calibri" size:fontSize];
}

+(NSDateFormatter *)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    formatter.timeZone = [NSTimeZone localTimeZone];
    return formatter;
}

+(void)storeSiteData:(NSMutableDictionary *)siteInfo
{
    [USER_DEFAULT setObject:siteInfo forKey:SITE_DATA];
    [USER_DEFAULT synchronize];
    [Common appDelegate].config = [[SiteConfig alloc] initWithDic:siteInfo];
}

+(NSMutableDictionary *)SiteData
{
    return [[USER_DEFAULT valueForKey:SITE_DATA] mutableCopy];
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)reSize:(UIImage *)originalImage
{
    CGRect rect = CGRectMake(0,0,200,200);
    UIGraphicsBeginImageContext( rect.size );
    [originalImage drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    return  [UIImage imageWithData:imageData];
}

+(NSMutableDictionary *)addDefaultParameter:(NSMutableDictionary *)parameter
{
    if ([USER_DEFAULT valueForKey:SITE_DATA])
    {
        if ([[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN])
        {
            [parameter setObject:[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] forKey:KEY_TOKEN];
        }
    }
    return parameter;
}

+(void)saveSiteToken :(NSString *)tokenInfo rememberMe:(NSString *)flagremember
{
    NSMutableDictionary *tokenDic = [[NSMutableDictionary alloc] init];
    [tokenDic setValue:tokenInfo forKey:KEY_TOKEN];
    [tokenDic setValue:flagremember forKey:KEY_REMMBERME];
    [USER_DEFAULT setObject:tokenDic forKey:SITE_DATA];
    [USER_DEFAULT synchronize];
}

+(BOOL)isSiteLogedIn
{
    if([USER_DEFAULT valueForKey:SITE_DATA])
    {
        if([[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] length]>0)
        {
            //            if ([[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_REMMBERME]] boolValue])
            //            {
            return YES;
            //            }
        }
        [USER_DEFAULT removeObjectForKey:kTimePassedAfterBGDownload];
        [USER_DEFAULT removeObjectForKey:SITE_DATA];
        [USER_DEFAULT synchronize];
        [Common removeHomeBackgroundImage];
        [Common removeInternalBackgroundImage];
    }
    return NO;
}

+(NSMutableArray *)getAcknowledgedMessageBoards {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([USER_DEFAULT valueForKey:KEY_MESSAGE_BOARDS]) {
        NSArray *ids = [USER_DEFAULT valueForKey:KEY_MESSAGE_BOARDS];
        [array addObjectsFromArray:ids];
    }
    return array;
}

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)removeSiteData
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([USER_DEFAULT valueForKey:SITE_DATA])
    {
        [USER_DEFAULT removeObjectForKey:kTimePassedAfterBGDownload];
        [USER_DEFAULT removeObjectForKey:SITE_DATA];
        [USER_DEFAULT synchronize];
        [USER_DEFAULT setBool:NO forKey:kNewLogin];
        [USER_DEFAULT synchronize];
    }
    [Common removeLogoImage];
    [Common removeHomeBackgroundImage];
    [Common removeInternalBackgroundImage];
    [appDelegate performSelector:@selector(startApp) withObject:Nil afterDelay:0.5];
}

+(void)updateTime :(UIView *)mainVCView
{
    if (![mainVCView viewWithTag:5214]) {
        return;
    }
    AppDelegate *appDelegate = [self appDelegate];
    UILabel *lableTime=[mainVCView viewWithTag:5214];
    if (appDelegate.isIpad)
    {
        NSString *dateTimeString=[appDelegate.dateFormatter stringFromDate:[NSDate date]];
        if (![dateTimeString containsString:@" AM"] && ![dateTimeString containsString:@" PM"])
        {
            if ([dateTimeString containsString:@"AM"])
            {
                dateTimeString=[dateTimeString stringByReplacingOccurrencesOfString:@"AM" withString:@" AM"];
            }
            else if ([dateTimeString containsString:@"PM"])
            {
                dateTimeString=[dateTimeString stringByReplacingOccurrencesOfString:@"PM" withString:@" PM"];
            }
        }
        
        NSArray *dateTimeArray= [dateTimeString componentsSeparatedByString:@" "];
        if ([dateTimeArray count]>=4)
        {
            dateTimeString=[NSString stringWithFormat:@"%@%@\n%@ %@",[dateTimeArray objectAtIndex:0],[dateTimeArray objectAtIndex:1],[dateTimeArray objectAtIndex:2],[dateTimeArray objectAtIndex:3]];
            NSRange range = [dateTimeString rangeOfString:[dateTimeArray objectAtIndex:0]];
            UIFont *font = kThemeRegularFonts(28);
            NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:dateTimeString];
            [hogan addAttribute:NSFontAttributeName value:font range:range];
            lableTime.attributedText=hogan;
        }
        else
        {
            UIFont *font = kThemeRegularFonts(28);
            lableTime.font=font;
            lableTime.text=dateTimeString;
        }
    }
    else
    {
        NSString *dateTimeString=[[self appDelegate].dateFormatter stringFromDate:[NSDate date]];
        UIFont *normalfont = kThemeRegularFonts(10);
        lableTime.font=normalfont;
        lableTime.text=dateTimeString;
    }
    
    if(appDelegate.isIpad){
        lableTime.frame = CGRectMake(10, mainVCView.frame.size.height - 65, 300, 65);
    }
    else {
        lableTime.frame = CGRectMake(10, 5, mainVCView.frame.size.width - 20, 20);
    }
    //    lableTime.textColor = [UIColor whiteColor];
    [lableTime setTextColor:kGetHomeLabelColor];
}

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSURL *url = [NSURL URLWithString:strEncodeData];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:imageData];
}

+ (NSData *)decodeBase64ToNSData:(NSString *)strEncodeData {
    NSURL *url = [NSURL URLWithString:strEncodeData];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return imageData;
}

+ (NSString *)encodeToBase64String:(UIImage *)image {
    
    NSString *base64String=[NSString stringWithFormat:@"data:image/jpeg;base64,%@",[UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    return base64String;
    
}

+ (NSString *)encodeToBase64StringPDF:(NSData *)fileData {
    NSString *str = [NSString stringWithFormat:@"%@",[fileData base64EncodedStringWithOptions:0]];
    NSString *base64String=[NSString stringWithFormat:@"data:application/pdf;base64,%@",str];
    
    return base64String;
    
}

+(void)loadLogo:(AsyncImageView *)imageView
{
    if (imageView!=NULL)
    {
        if ([self OpenLinkSafeFileOfName:F_LOGOFileName])
        {
            imageView.image=[self OpenLinkSafeFileOfName:F_LOGOFileName];
        }
        else
        {
            imageView.imageURL=[NSURL URLWithString:[[Common SiteData] valueForKey:KEY_LOGO]];
        }
        
        if([Common appDelegate].isIpad){
            [self setImageView:imageView.image imageView:imageView];
        }
        
    }
}

+(void)setImageView:(UIImage *)logoImage imageView:(AsyncImageView *)logoView
{
    if (logoImage==nil)
    {
        return;
    }
    logoView.image = logoImage;
    
    CGFloat width = logoImage.size.width;
    CGFloat height = logoImage.size.height;
    
    CGFloat aspectRatio = height/width;
    CGFloat newWidth = logoView.frame.size.height/aspectRatio;
    
    CGRect logoFrame = logoView.frame;
    logoFrame.size.width = newWidth;
    
    NSString *strPosition = [[Common SiteData] valueForKey:KEY_INTERNAL_SCREEN_LOGO_POSIITON];
    
    if([strPosition isEqualToString:@"right"]){
        logoFrame.origin.x = [UIScreen mainScreen].bounds.size.width - 15 - newWidth;
    }
    else if([strPosition isEqualToString:@"left"]){
        logoFrame.origin.x = 15;
    }
    else{
        logoFrame.origin.x = [UIScreen mainScreen].bounds.size.width/2 - newWidth/2;
    }
    
    
    logoView.frame = logoFrame;
}
/*
 + (BRPtouchPrinter *) prepareForPtp
 {
 
 BRPtouchPrinter	*ptp;
 
 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 NSString *selectedDevice = nil;
 
 CONNECTION_TYPE type = CONNECTION_TYPE_WLAN;
 
 if ([userDefaults integerForKey:kIsWiFi] == 0 && [userDefaults integerForKey:kIsBluetooth] == 1){
 type = CONNECTION_TYPE_BLUETOOTH;
 selectedDevice = [NSString stringWithFormat:@"Brother %@",[userDefaults stringForKey:kSelectedDeviceFromBluetooth]];
 }
 else if ([userDefaults integerForKey:kIsWiFi] == 1 && [userDefaults integerForKey:kIsBluetooth] == 0){
 type = CONNECTION_TYPE_WLAN;
 selectedDevice = [NSString stringWithFormat:@"%@", [userDefaults stringForKey:kSelectedDeviceFromWiFi]];
 }
 else{
 type = CONNECTION_ERROR;
 }
 
 if (selectedDevice) {
 ptp = [[BRPtouchPrinter alloc] initWithPrinterName:selectedDevice interface:type];
 switch (type) {
 case CONNECTION_TYPE_WLAN:
 [ptp setIPAddress:[userDefaults objectForKey:kIPAddress]];
 break;
 case CONNECTION_ERROR:
 // Error
 break;
 default:
 break;
 }
 }
 return ptp;
 }
 */

+ (BRLMChannel *) prepareForPtp
{
#if TARGET_OS_SIMULATOR
    // Brother SDK is not linked in simulator builds (no arm64-simulator slice); printing is device-only.
    return nil;
#else
    BRLMChannel *_ptp;
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
    return _ptp;
#endif
}


+ (void) setCustObject:(id)value forKey:(NSString *)key inDic:(NSMutableDictionary *)printerDic
{
    if (![USER_DEFAULT valueForKey:key])
    {
        [printerDic setObject:value forKey:key];
    }
    
}
+ (NSString *)defaultPaperSizeQL810WB
{
    NSString *result = nil;
    
#warning Temp "Brother QL-810WB"
    NSString *pathInPrintSettings   = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if (pathInPrintSettings) {
        NSDictionary *priterListArray = [NSDictionary dictionaryWithContentsOfFile:pathInPrintSettings];
        if (priterListArray) {
            result = [[[priterListArray objectForKey:@"Brother QL-810WB"] objectForKey:@"PaperSize"] objectAtIndex:6];
        }
    }
    return result;
}
+ (NSString *)defaultPaperSizeQL810W
{
    NSString *result = nil;
    
#warning Temp "Brother QL-810W"
    NSString *pathInPrintSettings   = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if (pathInPrintSettings) {
        NSDictionary *priterListArray = [NSDictionary dictionaryWithContentsOfFile:pathInPrintSettings];
        if (priterListArray) {
            result = [[[priterListArray objectForKey:@"Brother QL-810W"] objectForKey:@"PaperSize"] objectAtIndex:6];
        }
    }
    return result;
}
+ (NSString *)defaultPaperSizeQL720NW
{
    NSString *result = nil;
    
#warning Temp "Brother QL-720NW"
    NSString *pathInPrintSettings   = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if (pathInPrintSettings) {
        NSDictionary *priterListArray = [NSDictionary dictionaryWithContentsOfFile:pathInPrintSettings];
        if (priterListArray) {
            result = [[[priterListArray objectForKey:@"Brother QL-720NW"] objectForKey:@"PaperSize"] objectAtIndex:6];
        }
    }
    return result;
}

+ (void) initWithUserDefault
{
    // "UserDefault" Initialize
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults   = [NSMutableDictionary dictionary];
    
    [userDefaults removeObjectForKey:kPrintCustomPaperKey];
    [userDefaults removeObjectForKey:kSelectedPDFFilePath];
    [userDefaults synchronize];
    
    [self setCustObject:@"" forKey:@"" inDic:defaults];
    
    [self setCustObject:@""  forKey:kExportPrintFileNameKey inDic:defaults];
    [self setCustObject:@"1" forKey:kPrintNumberOfPaperKey inDic:defaults];
    [self setCustObject:[self defaultPaperSizeQL720NW] forKey:kPrintPaperSizeKey inDic:defaults];
    //  [self setCustObject:[self defaultPaperSizeQL810W] forKey:kPrintPaperSizeKey inDic:defaults];
    //  [self setCustObject:[self defaultPaperSizeQL810WB] forKey:kPrintPaperSizeKey inDic:defaults];
    
    [self setCustObject:[NSString stringWithFormat:@"%d", Landscape]        forKey:kPrintOrientationKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", Fit]         forKey:kScalingModeKey inDic:defaults];
    [self setCustObject:@"0.5" forKey:kScalingFactorKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", ErrorDiffusion]           forKey:kPrintHalftoneKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", Left]  forKey:kPrintHorizintalAlignKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", Top]   forKey:kPrintVerticalAlignKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", CodeOff]          forKey:kPrintCodeKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", CarbonOff]        forKey:kPrintCarbonKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", DashOff]          forKey:kPrintDashKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", NoFeed]           forKey:kPrintFeedModeKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", CurlModeOff]      forKey:kPrintCurlModeKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", Fast]  forKey:kPrintSpeedKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", BidirectionOn]    forKey:kPrintBidirectionKey inDic:defaults];
    [self setCustObject:@"0" forKey:kPrintFeedMarginKey inDic:defaults];
    [self setCustObject:@"200" forKey:kPrintCustomLengthKey inDic:defaults];
    [self setCustObject:@"80" forKey:kPrintCustomWidthKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", AutoCutOn]       forKey:kPrintAutoCutKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", CutAtEndOff]      forKey:kPrintCutAtEndKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", HalfCutOff]       forKey:kPrintHalfCutKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", SpecialTapeOn]   forKey:kPrintSpecialTapeKey inDic:defaults];
    [self setCustObject:@"" forKey:kPrintCustomPaperKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", RotateOff]        forKey:kRotateKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", PeelOff]          forKey:kPeelKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", CutMarkOff]       forKey:kPrintCutMarkKey inDic:defaults];
    [self setCustObject:@"0" forKey:kPrintLabelMargineKey inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", DensityMax5Level5]    forKey:kPrintDensityMax5Key inDic:defaults];
    [self setCustObject:[NSString stringWithFormat:@"%d", DensityMax10Level10]   forKey:kPrintDensityMax10Key inDic:defaults];
    [self setCustObject:@"0"     forKey:kPrintTopMarginKey inDic:defaults];
    [self setCustObject:@"0"     forKey:kPrintLeftMarginKey inDic:defaults];
    [self setCustObject:@"No Selected"  forKey:kSelectedDevice inDic:defaults];
    [self setCustObject:@"" forKey:kIPAddress inDic:defaults];
    [self setCustObject:@"0" forKey:kSerialNumber inDic:defaults];
    [self setCustObject:@"Search device from Wi-Fi"       forKey:kSelectedDeviceFromWiFi inDic:defaults];
    [self setCustObject:@"Search device from Bluetooth"   forKey:kSelectedDeviceFromBluetooth inDic:defaults];
    [self setCustObject:@"0" forKey:kIsWiFi inDic:defaults];
    [self setCustObject:@"0" forKey:kIsBluetooth inDic:defaults];
    [self setCustObject:@"0" forKey:kSelectedPDFFilePath inDic:defaults];
    
    [userDefaults registerDefaults:defaults];
}
+(NSDictionary *)TurnNumberOrNull:(NSMutableDictionary *)dicParameters{
    NSMutableDictionary *tempDicParameters = [[NSMutableDictionary alloc] initWithDictionary:dicParameters];
    for (NSString* key in dicParameters) {
        NSString *myString = [NSString stringWithFormat:@"%@",dicParameters[key]];
        if ([key isEqualToString:KEY_WORK_OrderID]
            || [key isEqualToString:KEY_CONTACT_ID]
            || [key isEqualToString:KEY_SignInHandle]
            || [key isEqualToString:KEY_WORKPERMIT_FORM_ID]) {
            if ([[NSString stringWithFormat:@"%@",[dicParameters valueForKey:key]] isEqualToString:@"0"])
            {
                [tempDicParameters setObject:[NSNull null] forKey:key];
            } else {
                [tempDicParameters setObject:[[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@",[dicParameters valueForKey:key]] intValue]] forKey:key];
            }
            NSString *myString = [NSString stringWithFormat:@"%@",tempDicParameters[key]];
            if ([myString length]>200) {
                NSLog(@"====%@-%@",key,[myString substringToIndex:100]);
            } else {
                NSLog(@"====%@-%@",key,myString);
            }
        }
    }
    return tempDicParameters;
}
+(NSString *)GetMaskedIfPhone:(NSString *)strPhone forKay:(NSString *) key{
    if ([key isEqualToString:@"phone"] && strPhone.length >= 3) {
        NSString *lastFourDigits = [strPhone substringFromIndex:strPhone.length - 3];
        NSString *maskedPhoneNumber = [NSString stringWithFormat:@"XXXXXXX%@", lastFourDigits];
        return maskedPhoneNumber;
    } else {
        return strPhone;
    }
}
@end
