#import "BEBNewStoryViewController.h"

@interface BEBAppDelegate : UIResponder <UIApplicationDelegate, BEBNewStoryViewControllerProtocol>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILocalNotification *localNotification;
@property (nonatomic, strong) UITabBarController *tabBarController;

@end

