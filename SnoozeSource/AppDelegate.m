//
//  AppDelegate.m
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface AppDelegate ()

@property (strong,nonatomic) LAContext* context;
@property (retain, nonatomic) Reachability *reachability;
@property (atomic) BOOL isReachable;
@property (retain, nonatomic) NSTimer *noInternetTimer;

@end

@implementation AppDelegate{
    NSUserDefaults *userSpot;
    NSMutableArray *arrTouchData;
}

@synthesize homeVC,leftMenuViewController,container;

-(void)checkForReachability:(NSNotification *)notification {
    
    Reachability *networkReachability = notification.object;
    NetworkStatus remoteHostStatus = networkReachability.currentReachabilityStatus;
    [self checkAndUpdateNetwork:remoteHostStatus needToPopOnHome:NO];
}


-(void)checkAndUpdateNetwork:(NetworkStatus)remoteHostStatus needToPopOnHome:(BOOL)isNeedToPopToHome {
    switch (remoteHostStatus) {
        case NotReachable:
            NSLog(@"Not reachable");
            self.isReachable = NO;
            [self startNoInternetTimer];
            break;
        case ReachableViaWiFi:
            NSLog(@"Wifi");
            if (!self.isReachable && [USER_DEFAULT valueForKey:SITE_DATA]) {
                [self getConfig];
            }
            self.isReachable = YES;
            [self stopNoInternetTimer];
            break;
        case ReachableViaWWAN:
            NSLog(@"WLAN");
            if (!self.isReachable && [USER_DEFAULT valueForKey:SITE_DATA]) {
                [self getConfig];
            }
            self.isReachable = YES;
            [self stopNoInternetTimer];
            break;
        default:
            NSLog(@"Network status not found");
            self.isReachable = NO;
            [self startNoInternetTimer];
            break;
    }
    if (isNeedToPopToHome) {
        [self backToHomePage];
    }
}

-(void)startNoInternetTimer {
    
    self.noInternetTimer = [NSTimer scheduledTimerWithTimeInterval:300 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        NetworkStatus remoteHostStatus = self.reachability.currentReachabilityStatus;
        [self checkAndUpdateNetwork:remoteHostStatus needToPopOnHome:YES];
    }];
}

-(void)stopNoInternetTimer {
    [self.noInternetTimer invalidate];
    self.noInternetTimer = nil;
}

-(void)backToHomePage {
    
    UINavigationController *navController = self.container.centerViewController;
    UIViewController *vc = [navController visibleViewController];
    if (vc != nil) {
        [vc dismissViewControllerAnimated:false completion:^{
            [navController popToRootViewControllerAnimated:true];
        }];
    }
    else {
        [navController popToRootViewControllerAnimated:true];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //    [TestFairy setServerEndpoint:@"https://cygnusc8.testfairy.com"];
    //    [TestFairy begin:@"SDK-7rzDBMkf"];
    
    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForReachability:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    NetworkStatus remoteHostStatus = self.reachability.currentReachabilityStatus;
    [self checkAndUpdateNetwork:remoteHostStatus needToPopOnHome:NO];
    
    userSpot = [NSUserDefaults standardUserDefaults];
    
    arrTouchData = [[NSMutableArray alloc]init];
    
    arrTouchData = [USER_DEFAULT objectForKey:KEY_TOUCH_DATA];
    
    //kNewLogin
    [USER_DEFAULT setBool:YES forKey:kNewLogin];
    [USER_DEFAULT synchronize];
    
    _dateFormatter=[[NSDateFormatter alloc] init];
    if ( IDIOM == IPAD ) {
        _isIpad=YES;
        [_dateFormatter setDateFormat:@"hh:mm aa EEEE, dd-MMM-yyyy"];
    } else {
        _isIpad=NO;
        [_dateFormatter setDateFormat:@"dd-MMM-yyyy, hh:mm aa"];
    }
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [_dateFormatter setLocale:locale];
    
    if (![USER_DEFAULT boolForKey:@"kHasSetDefaultQRCameraToFront_v3"]) {
        [USER_DEFAULT setObject:VALUE_CAMERA_FRONT forKey:KEY_QRCodeCam];
        [USER_DEFAULT setBool:YES forKey:@"kHasSetDefaultQRCameraToFront_v3"];
        
        // Update any existing saved camera settings in arrSettings so stale Rear default is replaced
        NSMutableArray *arrCamSettings = [[USER_DEFAULT objectForKey:CAMERA_SETTINGS] mutableCopy];
        if (arrCamSettings.count > 0) {
            for (int i = 0; i < arrCamSettings.count; i++) {
                NSMutableDictionary *dic = [[arrCamSettings objectAtIndex:i] mutableCopy];
                [dic setObject:VALUE_CAMERA_FRONT forKey:KEY_QRCodeCam];
                [arrCamSettings replaceObjectAtIndex:i withObject:dic];
            }
            [USER_DEFAULT setObject:arrCamSettings forKey:CAMERA_SETTINGS];
        }
        [USER_DEFAULT synchronize];
    }
    
    [self setApplicationNavigationThemeColor];
    
    if ([Common isSiteLogedIn])
    {
        //        if([USER_DEFAULT boolForKey:kTouchID]){
        //            [JZTouchID openTouchId:NO];
        //        }
        
        NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[userSpot valueForKey:@"userSpot"]];
        
        if ([strIsSpotCheckUser isEqualToString:@"1"]) {
            [self setUpSideMenuSpotCheck];
        }
        else{
            [self setUpSideMenu];
        }
    }
    else
    {
        [Common removeSiteData];
        [self startApp];
    }
    return YES;
}

- (void)setApplicationNavigationThemeColor
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIFont *titleFont = [Common calibriFont:17.0f] ?: [UIFont systemFontOfSize:17.0f];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kGetThemeColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont}];
    
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    if (@available(iOS 15.0, *)) {
        [[UITableView appearance] setSectionHeaderTopPadding:0.0f];
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
        appearance.backgroundColor = kGetThemeColor;
        
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [checkJSONtimer invalidate];
    [checkImageDownloadedTimer invalidate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([Common isSiteLogedIn])
    {
        // User is logged in — allow biometric to unlock from background
        [USER_DEFAULT setBool:YES forKey:kNewLogin];
        [USER_DEFAULT synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkForTouchID" object:nil];
    }
    // If NOT logged in, do nothing — user must log in manually.
    // Triggering biometric when session is expired causes "User is already logged out" error.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    checkJSONtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateClock) userInfo:nil repeats:TRUE];
    checkImageDownloadedTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(downloadBackgroundImages) userInfo:nil repeats:TRUE];
    application.applicationIconBadgeNumber = 0;
}

- (void)updateClock {
    [[NSNotificationCenter defaultCenter] postNotificationName:N_UpdateTime object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [USER_DEFAULT setBool:NO forKey:kIsFromLoginScreen];
    [USER_DEFAULT synchronize];
}


-(void)startApp
{
    LoginVC *loginVC = (LoginVC *)[[Common mainStoryboard] instantiateViewControllerWithIdentifier:@"LoginVC"];
    UINavigationController *startUpNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = startUpNav;
    [self.window makeKeyAndVisible];
}

-(void)setUpSideMenu
{
    UIStoryboard *storyboard = [Common mainStoryboard];
    homeVC = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    leftMenuViewController = (SideMenuVC *)[storyboard instantiateViewControllerWithIdentifier:@"SideMenuVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    self.container = [MFSideMenuContainerViewController
                      containerWithCenterViewController:navController
                      leftMenuViewController:nil
                      rightMenuViewController:self.leftMenuViewController];
    self.window.rootViewController = self.container;
    [self.window makeKeyAndVisible];
    [USER_DEFAULT setBool:NO forKey:kIsFromLoginScreen];
    [USER_DEFAULT synchronize];
    [self getConfig];
}

-(void)setUpSideMenuSpotCheck
{
    UIStoryboard *storyboard = [Common mainStoryboard];
    _contractorSignInVC = (ContractorSignInSpotCheckVC *)[storyboard instantiateViewControllerWithIdentifier:@"ContractorSignInSpotCheckVC"];
    leftMenuViewController = (SideMenuVC *)[storyboard instantiateViewControllerWithIdentifier:@"SideMenuVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_contractorSignInVC];
    self.container = [MFSideMenuContainerViewController
                      containerWithCenterViewController:navController
                      leftMenuViewController:nil
                      rightMenuViewController:self.leftMenuViewController];
    self.window.rootViewController = self.container;
    [self.window makeKeyAndVisible];
    [USER_DEFAULT setBool:NO forKey:kIsFromLoginScreen];
    [USER_DEFAULT synchronize];
    [self getConfig];
}

-(void)showProgressWithSettinLabel
{
    [SVProgressHUD showWithStatus:@"Please wait while we load your settings."];
}

- (void)getConfig
{
    NSLog(@"*******************getConfig Called*******************");
    [Common callAPI:[[NSMutableDictionary alloc] init] Request:REQUEST_GET_CONFIG ShowProgress:NO WithCompletionHandler:^(id responseObject)
     {
        if ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_SUCCESS]] boolValue])
        {
            NSMutableDictionary *siteData = [Common SiteData];
            
            NSMutableDictionary *configDic = [responseObject mutableCopy];
            configDic = [Common addDefaultParameter:configDic];
            
            [configDic setObject:[siteData valueForKey:KEY_SiteUser] forKey:KEY_SiteUser];
            [configDic setObject:[siteData valueForKey:KEY_PASSWORD] forKey:KEY_PASSWORD];
            
            //[configDic setValue:@"#00FF00" forKey:@"baseColor"];
            
            NSMutableArray *arrSettings = [[USER_DEFAULT objectForKey:CAMERA_SETTINGS] mutableCopy];
            if (arrSettings == nil)
            {
                arrSettings = [[NSMutableArray alloc] init];
            }
            
            BOOL isCameraSettingSaved = NO;
            if (arrSettings.count > 0)
            {
                for (NSDictionary *dicSettings in arrSettings)
                {
                    if ([[NSString stringWithFormat:@"%@",[dicSettings objectForKey:KEY_SiteUser]] isEqualToString:[NSString stringWithFormat:@"%@",[configDic objectForKey:KEY_SiteUser]]])
                    {
                        isCameraSettingSaved = YES;
                        [USER_DEFAULT setObject:[configDic objectForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                        [USER_DEFAULT setObject:[dicSettings objectForKey:KEY_CAMERA] forKey:KEY_CAMERA];
                        [USER_DEFAULT setObject:[dicSettings objectForKey:KEY_QRCodeCam] forKey:KEY_QRCodeCam];
                        [USER_DEFAULT synchronize];
                        break;
                    }
                }
            }
            
            if (!isCameraSettingSaved)
            {
                NSMutableDictionary *dicSettings = [[NSMutableDictionary alloc] init];
                [dicSettings setObject:[configDic objectForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                [dicSettings setObject:VALUE_CAMERA_FRONT forKey:KEY_CAMERA];
                [dicSettings setObject:VALUE_CAMERA_FRONT forKey:KEY_QRCodeCam];
                
                [arrSettings addObject:dicSettings];
                [USER_DEFAULT setObject:arrSettings forKey:CAMERA_SETTINGS];
                // Also save directly to UserDefaults so ScannerViewController can read it
                [USER_DEFAULT setObject:[configDic objectForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                [USER_DEFAULT setObject:VALUE_CAMERA_FRONT forKey:KEY_CAMERA];
                [USER_DEFAULT setObject:VALUE_CAMERA_FRONT forKey:KEY_QRCodeCam];
                [USER_DEFAULT synchronize];
            }
            
            NSMutableArray *arrTouchData = [[USER_DEFAULT objectForKey:KEY_TOUCH_DATA] mutableCopy];
            
            if (arrTouchData == nil)
            {
                arrTouchData = [[NSMutableArray alloc] init];
            }
            
            BOOL isTouchSaved = NO;
            
            if(arrTouchData.count>0){
                for (NSDictionary *dict in arrTouchData){
                    if ([[NSString stringWithFormat:@"%@",[dict objectForKey:KEY_SiteUser]] isEqualToString:[NSString stringWithFormat:@"%@",[configDic objectForKey:KEY_SiteUser]]])
                    {
                        isTouchSaved = YES;
                        NSString *strTouch = [NSString stringWithFormat:@"%@",[dict objectForKey:kTouchID]];
                        if ([strTouch isEqualToString:@"0"]){
                            [USER_DEFAULT setBool:NO forKey:kTouchID];
                        }
                        else{
                            [USER_DEFAULT setBool:YES forKey:kTouchID];
                        }
                        [USER_DEFAULT synchronize];
                        break;
                    }
                }
            }
            
            if(!isTouchSaved){
                NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
                [dict1 setValue:[siteData valueForKey:KEY_SiteUser] forKey:KEY_SiteUser];
                [dict1 setValue:[siteData valueForKey:KEY_PASSWORD] forKey:KEY_PASSWORD];
                [dict1 setValue:@"0" forKey:kTouchID];
                [arrTouchData addObject:dict1];
                
                [USER_DEFAULT setObject:arrTouchData forKey:KEY_TOUCH_DATA];
                [USER_DEFAULT synchronize];
            }
            
            
            //test
            //             BOOL hasTouchID = NO;
            //             if ([LAContext class]) {
            //                 self.context = [[LAContext alloc] init];
            //
            //                 NSError *error = nil;
            //                 if ([_context canEvaluatePolicy:1 error:&error]) {
            //                     hasTouchID = YES;
            //                 }
            //                 else{
            //                     switch (error.code) {
            //                         case LAErrorPasscodeNotSet:{
            //                             hasTouchID = NO;
            //                             break;
            //                         }
            //                         case LAErrorTouchIDNotEnrolled:{
            //                             hasTouchID = NO;
            //                             break;
            //                         }
            //                         case LAErrorTouchIDLockout:{
            //                             hasTouchID = YES;
            //                             break;
            //                         }
            //                         default:{
            //                             hasTouchID = NO;
            //                             break;
            //                         }
            //                     }
            //                 }
            //                 if(![[[USER_DEFAULT dictionaryRepresentation] allKeys] containsObject:kTouchID]){
            //                     [USER_DEFAULT setBool:hasTouchID forKey:kTouchID];
            //                 }
            //                 [USER_DEFAULT synchronize];
            //            }
            [configDic setObject:@"0" forKey:KEY_REMMBERME];
            if([USER_DEFAULT valueForKey:SITE_DATA])
            {
                if([[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN]] length]>0)
                {
                    if ([[NSString stringWithFormat:@"%@",[[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_REMMBERME]] boolValue])
                    {
                        [configDic setObject:@"1" forKey:KEY_REMMBERME];
                    }
                }
            }
            if (![[siteData valueForKey:KEY_LOGO] isEqualToString:[configDic valueForKey:KEY_LOGO]])
            {
                [Common removeLogoImage];
            }
            [Common loadImagewithURL:[configDic valueForKey:KEY_LOGO]];
            
            //             //TEST
            //             [configDic setObject:@"1" forKey:@"isWorkOrdersScreenVisible"];
            //             [configDic setObject:@"1" forKey:@"isWorkLocationScreenVisible"];
            //             [configDic setObject:@"1" forKey:@"isWorkPermitsEnabled"];
            //             [configDic setObject:@"0" forKey:@"isSwmsUploadMandatory"];
            //             [configDic setObject:@"0" forKey:@"isRiskAssessmentUploadMandatory"];
            //             [configDic setObject:@"1" forKey:@"isContractorsButtonVisible"];
            //             [configDic setObject:@"1" forKey:@"isVisitorsButtonVisible"];
            //             [configDic setObject:@"1" forKey:@"isPhotoRequiredSignInContractor"];
            //             [configDic setObject:@"1" forKey:@"isPhotoRequiredSignInVisitor"];
            //             [configDic setObject:@"1" forKey:@"isPhotoRequiredSignOutContractor"];
            //             [configDic setObject:@"1" forKey:@"isPhotoRequiredSignOutVisitor"];
            //             [configDic setObject:@"1" forKey:@"isSignatureRequiredContractor"];
            //             [configDic setObject:@"1" forKey:@"isSignatureRequiredVisitor"];
            [Common storeSiteData:configDic];
            [self setApplicationNavigationThemeColor];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_UpdateSideMenuScreen object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_HomeUpdate object:nil];
            
            if (![[[siteData objectForKey:@"homeWallpapers"] objectForKey:@"tabletUrl"] isEqualToString:[[configDic objectForKey:@"homeWallpapers"] objectForKey:@"tabletUrl"]] || ![[[siteData objectForKey:@"homeWallpapers"] objectForKey:@"phoneUrl"] isEqualToString:[[configDic objectForKey:@"homeWallpapers"] objectForKey:@"phoneUrl"]])
            {
                [Common removeHomeBackgroundImage];
                [USER_DEFAULT removeObjectForKey:kTimePassedAfterBGDownload];
                [USER_DEFAULT synchronize];
            }
            
            if (![[[siteData objectForKey:@"internalWallpapers"] objectForKey:@"tabletUrl"] isEqualToString:[[configDic objectForKey:@"internalWallpapers"] objectForKey:@"tabletUrl"]] || ![[[siteData objectForKey:@"internalWallpapers"] objectForKey:@"phoneUrl"] isEqualToString:[[configDic objectForKey:@"internalWallpapers"] objectForKey:@"phoneUrl"]])
            {
                [Common removeInternalBackgroundImage];
                [USER_DEFAULT removeObjectForKey:kTimePassedAfterBGDownload];
                [USER_DEFAULT synchronize];
            }
            [self checkAndDownloadBackgroundImage];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadAllSites" object:nil];
            //             loadAllSites
        }
        else
        {
            NSString *errorMsg = [NSString stringWithFormat:@"%@",[responseObject objectForKey:KEY_ERROR_MESSAGE]];
            [Common showAlert:errorMsg : @""];
        }
    }];
}

-(void)downloadBackgroundImages
{
    if ([[USER_DEFAULT valueForKey:SITE_DATA] valueForKey:KEY_TOKEN] && self.isReachable)
    {
        NSInteger timeSaved = [USER_DEFAULT integerForKey:kTimePassedAfterBGDownload];
        NSInteger timeIntervalPassed = [[NSDate date] timeIntervalSince1970] - timeSaved;
        if (timeIntervalPassed > 3600 || timeSaved == 0)
        {
            [self getConfig];
        }
    }
}

-(void)checkAndDownloadBackgroundImage
{
    NSInteger timeSaved = [USER_DEFAULT integerForKey:kTimePassedAfterBGDownload];
    NSInteger timeIntervalPassed = [[NSDate date] timeIntervalSince1970] - timeSaved;
    if (timeIntervalPassed > 3600 || timeSaved == 0)
    {
        [Common removeHomeBackgroundImage];
        [Common removeInternalBackgroundImage];
        
        NSString *homeImageUrl;
        NSString *internalScreenImageUrl;
        
        if ([self isIpad])
        {
            homeImageUrl = self.config.homeWallpapersTabletUrl;
            internalScreenImageUrl = self.config.internalWallpapersTabletUrl;
        }
        else
        {
            homeImageUrl = self.config.homeWallpapersPhoneUrl;
            internalScreenImageUrl = self.config.internalWallpapersPhoneUrl;
        }
        
        //        homeImageUrl = [homeImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //        internalScreenImageUrl = [internalScreenImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        homeImageUrl = [homeImageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        internalScreenImageUrl = [internalScreenImageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        dispatch_async(queue2, ^{
            
            [Common removeHomeBackgroundImage];
            NSData *pngDataHome = [NSData dataWithContentsOfURL:[NSURL URLWithString:homeImageUrl]];
            [Common SaveLinkSafeBGImage:pngDataHome withName:F_BGFileName];
            
            [Common removeInternalBackgroundImage];
            NSData *pngDataInternal = [NSData dataWithContentsOfURL:[NSURL URLWithString:internalScreenImageUrl]];
            [Common SaveLinkSafeBGImage:pngDataInternal withName:F_InternalBGFileName];
            
            NSInteger timePassed = [[NSDate date] timeIntervalSince1970];
            [USER_DEFAULT setInteger:timePassed forKey:kTimePassedAfterBGDownload];
            
            if ([USER_DEFAULT boolForKey:kIsFromLoginScreen])
            {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [Common hideProgress];
                    NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@",[[Common SiteData] valueForKey:KEY_IS_SPOT_CHECKUSER]];
                    
                    if ([strIsSpotCheckUser isEqualToString:@"1"]) {
                        [userSpot setValue:@"1" forKey:@"userSpot"];
                        [self setUpSideMenuSpotCheck];
                    }
                    else{
                        [userSpot setValue:@"0" forKey:@"userSpot"];
                        [self setUpSideMenu];
                    }
                    [userSpot synchronize];
                });
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:N_UpdateBackgroundImages object:nil];
            }
        });
        
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        //        dispatch_async(queue, ^{
        //            [Common removeInternalBackgroundImage];
        //            NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:internalScreenImageUrl]];
        //            [Common SaveLinkSafeBGImage:pngData withName:F_InternalBGFileName];
        //
        //            NSInteger timePassed = [[NSDate date] timeIntervalSince1970];
        //            [USER_DEFAULT setInteger:timePassed forKey:kTimePassedAfterBGDownload];
        //
        //            [[NSNotificationCenter defaultCenter] postNotificationName:N_UpdateBackgroundImages object:nil];
        //        });
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([self isIpad])
        return UIInterfaceOrientationMaskLandscape;
    else  /* iphone */
        return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ([self isIpad])
        return UIInterfaceOrientationLandscapeRight;
    else  /* iphone */
        return UIInterfaceOrientationPortrait;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self isIpad])
        return UIInterfaceOrientationMaskLandscape;
    else  /* iphone */
        return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end

#pragma mark - InitialLaunchVC Implementation

@implementation InitialLaunchVC

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

@end

#pragma mark - UINavigationController Orientation Category

@implementation UINavigationController (Orientation)

- (BOOL)shouldAutorotate {
    if (self.topViewController) {
        return [self.topViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isIpad) {
        return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

@end

#pragma mark - SceneDelegate Implementation

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    appDelegate.window = self.window;
    
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    [appDelegate setApplicationNavigationThemeColor];
    
    if ([Common isSiteLogedIn]) {
        NSString *strIsSpotCheckUser = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpot"]];
        if ([strIsSpotCheckUser isEqualToString:@"1"]) {
            [appDelegate setUpSideMenuSpotCheck];
        } else {
            [appDelegate setUpSideMenu];
        }
    } else {
        [Common removeSiteData];
        [appDelegate startApp];
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate applicationDidBecomeActive:[UIApplication sharedApplication]];
}

- (void)sceneWillResignActive:(UIScene *)scene {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate applicationWillResignActive:[UIApplication sharedApplication]];
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate applicationWillEnterForeground:[UIApplication sharedApplication]];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate applicationDidEnterBackground:[UIApplication sharedApplication]];
}

@end
