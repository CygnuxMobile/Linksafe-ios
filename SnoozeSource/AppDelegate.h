//
//  AppDelegate.h
//  LinkSafe
//
//  Created by Hitesh Sarkheliya on 08/07/16.
//


#import <UIKit/UIKit.h>
#import "HomeVC.h"
#import "SideMenuVC.h"
#import "MFSideMenu.h"
#import "LoginVC.h"
#import "SiteConfig.h"
#import "LockVC.h"
#import "ContractorSignInSpotCheckVC.h"
//#import <TestFairy/TestFairy.h>
@import Firebase;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimer *checkJSONtimer;
    NSTimer *checkImageDownloadedTimer;
}
@property (nonatomic) BOOL isIpad;

@property (strong, nonatomic) UIWindow *window;

@property(strong,nonatomic)HomeVC   *homeVC;

@property(strong,nonatomic)ContractorSignInSpotCheckVC   *contractorSignInVC;

@property(strong, nonatomic)SideMenuVC *leftMenuViewController;

@property(strong, nonatomic)MFSideMenuContainerViewController *container;

@property (strong,nonatomic) NSDateFormatter *dateFormatter;

@property (strong,nonatomic) SiteConfig *config;


-(void)setUpSideMenu;
-(void)setUpSideMenuSpotCheck;
-(void)startApp;
-(void)downloadBackgroundImages;
-(void)setApplicationNavigationThemeColor;
@end

@interface InitialLaunchVC : UIViewController
@end

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow * window;
@end

