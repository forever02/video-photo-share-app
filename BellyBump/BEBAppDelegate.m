#import "BEBAppDelegate.h"
#import "BEBDataManager.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import "BEBAppearanceManager.h"
#import "BEBStoryboard.h"
#import "BEBNotificationViewController.h"
#import "BEBSegueNames.h"
#import "UIViewController+Popup.h"
#import "BEBHomeViewController.h"
#import "BEBStoriesDetailViewController.h"
#import "BEBSettingsViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSS3/AWSS3.h>
#import "BEBTutorialViewController.h"

@interface BEBAppDelegate ()<UITabBarControllerDelegate>

@property (nonatomic) NSUserDefaults *prefs;

@end

@implementation BEBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
    self.prefs = [NSUserDefaults standardUserDefaults];
    // Register tracking tools
    [self registerTrackingTools];
    
    // Init Data Manager
    [BEBDataManager sharedManager];
    
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[BEBAppearanceManager sharedInstance] setupDefaultConfiguration];
    
    // Init credential provider and default service configuration
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                    identityPoolId:CognitoIdentityPoolId];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    self.localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = (UIUserNotificationTypeBadge |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeAlert);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else {
        UIRemoteNotificationType remoteTypes = (UIRemoteNotificationTypeBadge |
                                                UIRemoteNotificationTypeSound |
                                                UIRemoteNotificationTypeAlert);
        [application registerForRemoteNotificationTypes:remoteTypes];
    }
    
    UIStoryboard *storyboard = [BEBStoryboard storyboard];
    CGFloat insetX = IS_IPHONE_6 && iOS_Version >= 9.0 ? 0.5 : 0;
    CGFloat insetY = IS_IPHONE_6PLUS ? 2 : (IS_IPHONE_6 ? 4 : 6);
    NSString *imageName = IS_IPHONE_6 ? @"icon_home6" : @"icon_home";
    
    UIViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBHomeViewControllerIdentifier"];
    homeVC.title = @"HOME";
    homeVC.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeVC.tabBarItem.selectedImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(insetY, insetX, -insetY, -insetX);
    [homeVC.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, 15)];
    UINavigationController *homeNC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    imageName = IS_IPHONE_6 ? @"icon_new_story6" : @"icon_new_story";
    UIViewController *newStoryVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBNewStoryViewControllerIdentifier"];
    newStoryVC.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newStoryVC.tabBarItem.selectedImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newStoryVC.tabBarItem.imageInsets = UIEdgeInsetsMake(insetY, 0, -insetY, 0);
    
    imageName = IS_IPHONE_6 ? @"icon_settings6" : @"icon_settings";
    UIViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBSettingsViewControllerIdentifier"];
    settingsVC.title = @"SETTINGS";
    settingsVC.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingsVC.tabBarItem.selectedImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingsVC.tabBarItem.imageInsets = UIEdgeInsetsMake(insetY, 0, -insetY, 0);
    [settingsVC.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, 15)];
    UINavigationController *settingsNC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    // Hide top line tabbar
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    // Setup Main TabBarController
    _tabBarController = [[UITabBarController alloc] init];
    [self.tabBarController setViewControllers:@[homeNC, newStoryVC, settingsNC]];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.translucent = NO;
    
    // Show tutorial first time
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![[ud objectForKey:kSkipShowTutorial] boolValue]) {
        BEBTutorialViewController *tutorialVC = [storyboard instantiateViewControllerWithIdentifier:kTutorialViewControllerIdentifier];
        self.window.rootViewController = tutorialVC;
    }
    else {
        self.window.rootViewController = self.tabBarController;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application;
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        UIStoryboard *storyboard = [BEBStoryboard storyboard];
        BEBNotificationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kNotificationViewControllerIdentifier];
        vc.message = notification.alertBody;
        
        UIViewController *topVC = [BEBUtilities topViewController:self.window.rootViewController];
        if ([topVC isKindOfClass:[BEBNotificationViewController class]]) {
            vc.hideOverlay = YES;
        }
        else if ([topVC isKindOfClass:[UITabBarController class]]) {
            [topVC dismisPopupViewControllerAnimated:NO];
        }
        
        [topVC presentViewController:vc animated:NO completion:nil];
    }
    else {
        UINavigationController *nc = self.tabBarController.viewControllers[0];
        [nc popToRootViewControllerAnimated:NO];
        self.localNotification = notification;
        
        UIViewController *topVC = [BEBUtilities topViewController:self.window.rootViewController];
        if (topVC.presentingViewController) {
            [topVC.presentingViewController dismissViewControllerAnimated:NO completion:^{
                [self.tabBarController setSelectedIndex:0];
            }];
        }
    }
}

- (void)registerTrackingTools {
    
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** TabBarControllerDelegate **
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
{
    // Check if the current view is new story view controller <- The adding new story view controller
    if ([viewController isKindOfClass: [BEBNewStoryViewController class]]) {
        
        [self.prefs setObject:@"passed" forKey:@"tip1Name"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tip1Passed" object:nil];
        
        // Init the new story view controller
        UIStoryboard *storyboard = [BEBStoryboard storyboard];
        BEBNewStoryViewController *newStoryVC = [storyboard instantiateViewControllerWithIdentifier:@"BEBNewStoryViewControllerIdentifier"];
        newStoryVC.delegate = self;
        
        // Pop up view controller
        [self.window.rootViewController popupViewController:newStoryVC
                                                   animated:YES
                                     dimissedWhenTapOverlay:NO];
        return NO;
    }
    
    return YES;
}

- (void)bebNewStoryViewController:(BEBNewStoryViewController *)newStoryViewController
                 dismissWithStory:(BEBStory *)story;
{
    // Dismiss the add new story view controller
    [self.window.rootViewController dismisPopupViewControllerAnimated:YES];

    // If user create the new story -> back to list story for user show the new story
    if (story) {
        
        // Moving to the first tabbar
        [self.tabBarController setSelectedIndex:0];
        
        // Get the navigation controller in the first tab
        UINavigationController *selectedController = self.tabBarController.selectedViewController;
        
        if ([selectedController isKindOfClass:[UINavigationController class]]) {
            
            // Pop to root view controller
            [selectedController popToRootViewControllerAnimated:NO];
            
            if ([selectedController.topViewController isKindOfClass:[BEBHomeViewController class]]) {

                UIStoryboard *storyboard = [BEBStoryboard storyboard];

                BEBStoriesDetailViewController *storiesDetailVC = [storyboard instantiateViewControllerWithIdentifier:kStoriesDetailViewControllerIdentifier];
                storiesDetailVC.story = story;
                storiesDetailVC.needTakeImage = YES;
                [selectedController pushViewController:storiesDetailVC animated:NO];
                
            }
        }
    }
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
